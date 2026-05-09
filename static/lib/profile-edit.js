'use strict';

/*
 * Client script — hooks into the user account edit page.
 *
 * Listens for the ajaxify content-loaded event. When the user is on
 * /user/:slug/edit, we:
 *   1. Inject our partial template's fields if the theme didn't render them
 *      (we ship the partial but themes vary).
 *   2. Bind Mapbox geocoder autocomplete to the address input.
 *   3. On selection, populate street/city/state/zip/neighborhood/country/lat/lng.
 *   4. Wire per-field privacy toggles, posting changes via socket.
 *
 * No bundler — this file is loaded via plugin.json `scripts` and runs in the
 * standard NodeBB client environment (jQuery + AMD `require`/`define` are
 * available; we keep it dependency-light and use `fetch` for the geocode
 * proxy call).
 */

(function () {
	if (typeof $ === 'undefined') return; // not in browser

	const ENDPOINT = '/api/v3/plugins/waymker-geo/geocode';
	const COMPONENT_KEYS = [
		'geo:street',
		'geo:city',
		'geo:state',
		'geo:zip',
		'geo:neighborhood',
		'geo:country',
		'geo:lat',
		'geo:lng',
	];

	let suggestionTimer = null;
	let lastQuery = '';

	$(window).on('action:ajaxify.end', function (e, data) {
		// Only act on user edit page templates.
		if (!data || !data.tpl || !data.tpl.includes('account/edit')) return;
		init();
	});

	function init() {
		const $root = $('[data-waymker-geo-root]');
		if (!$root.length) return; // template partial not present

		const $address = $root.find('input[name="geo:address"]');
		const $suggestions = $root.find('[data-waymker-geo-suggestions]');

		if ($address.length) {
			$address.on('input.waymker', onAddressInput);
			// Hide suggestions when clicking outside.
			$(document).on('click.waymker', function (e) {
				if (!$.contains($root[0], e.target)) {
					$suggestions.hide().empty();
				}
			});
		}

		// Privacy toggle buttons cycle through the four levels.
		$root.on('click', '[data-waymker-privacy-cycle]', function (e) {
			e.preventDefault();
			const $btn = $(this);
			const order = ['public', 'registered', 'followers', 'private'];
			const current = $btn.attr('data-current') || 'private';
			const next = order[(order.indexOf(current) + 1) % order.length];
			$btn.attr('data-current', next);
			$btn.find('[data-waymker-privacy-label]').text(labelFor(next));
			$btn.find('[data-waymker-privacy-icon]')
				.attr('class', 'fa ' + iconFor(next) + ' me-1');
			// Sync the hidden input so it's submitted with the form.
			const fieldKey = $btn.attr('data-field');
			$root.find(`input[name="${fieldKey}:privacy"]`).val(next);
		});
	}

	function labelFor(level) {
		switch (level) {
			case 'public': return 'Public';
			case 'registered': return 'Registered';
			case 'followers': return 'Mutual follows';
			default: return 'Only me';
		}
	}
	function iconFor(level) {
		switch (level) {
			case 'public': return 'fa-globe';
			case 'registered': return 'fa-users';
			case 'followers': return 'fa-user-friends';
			default: return 'fa-lock';
		}
	}

	function onAddressInput() {
		const $input = $(this);
		const q = ($input.val() || '').trim();
		if (q === lastQuery) return;
		lastQuery = q;
		clearTimeout(suggestionTimer);
		if (q.length < 3) {
			$('[data-waymker-geo-suggestions]').hide().empty();
			return;
		}
		// 250ms debounce — typical for autocomplete.
		suggestionTimer = setTimeout(function () { runQuery(q); }, 250);
	}

	function runQuery(q) {
		const url = ENDPOINT + '?q=' + encodeURIComponent(q) + '&limit=5';
		fetch(url, { credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
			.then(r => r.json())
			.then(payload => {
				const results = (payload && payload.response && payload.response.results) || [];
				renderSuggestions(results);
			})
			.catch(function (err) {
				console.warn('[waymker-geo] geocode error', err);
			});
	}

	function renderSuggestions(results) {
		const $box = $('[data-waymker-geo-suggestions]').empty();
		if (!results.length) {
			$box.hide();
			return;
		}
		results.forEach(function (r) {
			const $item = $('<button type="button" class="list-group-item list-group-item-action" />')
				.text(r.address)
				.on('click', function (e) {
					e.preventDefault();
					applySelection(r);
					$box.hide().empty();
				});
			$box.append($item);
		});
		$box.show();
	}

	function applySelection(r) {
		const $root = $('[data-waymker-geo-root]');
		// Map our normalized response back onto the form fields.
		const map = {
			'geo:address': r.address,
			'geo:street': r.street,
			'geo:city': r.city,
			'geo:state': r.state,
			'geo:zip': r.zip,
			'geo:neighborhood': r.neighborhood,
			'geo:country': r.country,
			'geo:lat': r.lat == null ? '' : r.lat,
			'geo:lng': r.lng == null ? '' : r.lng,
		};
		Object.keys(map).forEach(function (k) {
			const $f = $root.find(`input[name="${k}"]`);
			if ($f.length) $f.val(map[k]);
		});
		// Notify any listeners (e.g. a live mini-map preview) that we picked a place.
		$(window).trigger('waymker-geo:place-selected', [r]);
	}
}());
