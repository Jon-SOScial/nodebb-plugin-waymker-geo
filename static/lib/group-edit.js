'use strict';

/*
 * Group edit page — minimal hook so admins/owners can set a group address.
 * Reuses the same /geocode endpoint. Kept separate so the binding logic is
 * triggered only on the group route.
 */

(function () {
	if (typeof $ === 'undefined') return;
	const ENDPOINT = '/api/v3/plugins/waymker-geo/geocode';

	$(window).on('action:ajaxify.end', function (e, data) {
		if (!data || !data.tpl) return;
		// Match groups/details and admin group manage page.
		if (!data.tpl.includes('groups/details') && !data.tpl.includes('admin/manage/groups')) return;
		bindGroup();
	});

	function bindGroup() {
		const $root = $('[data-waymker-geo-group-root]');
		if (!$root.length) return;
		const $address = $root.find('input[name="geo:address"]');
		const $suggestions = $root.find('[data-waymker-geo-suggestions]');
		if (!$address.length) return;

		let timer = null;
		$address.on('input', function () {
			const q = ($(this).val() || '').trim();
			clearTimeout(timer);
			if (q.length < 3) { $suggestions.hide().empty(); return; }
			timer = setTimeout(function () {
				fetch(ENDPOINT + '?q=' + encodeURIComponent(q) + '&limit=5',
					{ credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
					.then(r => r.json())
					.then(payload => {
						const results = (payload && payload.response && payload.response.results) || [];
						$suggestions.empty();
						if (!results.length) { $suggestions.hide(); return; }
						results.forEach(r => {
							$('<button type="button" class="list-group-item list-group-item-action" />')
								.text(r.address)
								.on('click', function (ev) {
									ev.preventDefault();
									$root.find('input[name="geo:address"]').val(r.address);
									$root.find('input[name="geo:lat"]').val(r.lat || '');
									$root.find('input[name="geo:lng"]').val(r.lng || '');
									$root.find('input[name="geo:city"]').val(r.city || '');
									$root.find('input[name="geo:state"]').val(r.state || '');
									$root.find('input[name="geo:zip"]').val(r.zip || '');
									$suggestions.hide().empty();
								})
								.appendTo($suggestions);
						});
						$suggestions.show();
					});
			}, 250);
		});
	}
}());
