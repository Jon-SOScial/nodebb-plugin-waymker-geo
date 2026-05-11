<div class="container" style="margin-top: 20px;">
	<div class="row">
		<div class="col-lg-12">
			<h1>
				<i class="fa fa-map-marker"></i> Nearby Members
				<span id="wg-count-badge" class="badge">0</span>
			</h1>
			<a href="/users" class="btn btn-link">← All Members</a>
		</div>
	</div>

	<!-- Filters -->
	<div class="row" style="margin: 20px 0; gap: 10px;">
		<div class="col-md-3">
			<input type="text" id="wg-search" class="form-control" placeholder="Search username, city, neighborhood...">
		</div>
		<div class="col-md-2">
			<select id="wg-role" class="form-control">
				<option value="">All roles</option>
			</select>
		</div>
		<div class="col-md-2">
			<select id="wg-group" class="form-control">
				<option value="">All groups</option>
			</select>
		</div>
		<div class="col-md-2">
			<button id="wg-reset" class="btn btn-secondary btn-block">Reset</button>
		</div>
	</div>

	<!-- Map -->
	<div id="wg-map" style="height: 450px; margin: 20px 0; border: 1px solid #ddd; border-radius: 4px;"></div>

	<!-- Results Grid -->
	<h3 id="wg-results-info" style="margin-top: 30px;">Members</h3>
	<div id="wg-results-grid" class="wg-grid"></div>
</div>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.Default.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/leaflet.markercluster.js"></script>

<style>
	/* ============================================================
	   CRITICAL: Prevent Bootstrap/theme img rules from squashing
	   Leaflet tiles. Without this, tiles render at 0px height.
	   ============================================================ */
	#wg-map img.leaflet-tile,
	#wg-map .leaflet-container img,
	.leaflet-container img.leaflet-tile,
	.leaflet-tile {
		max-width: none !important;
		max-height: none !important;
		width: 256px !important;
		height: 256px !important;
	}
	.leaflet-container img {
		max-width: none !important;
	}
	.leaflet-pane,
	.leaflet-tile,
	.leaflet-marker-icon,
	.leaflet-marker-shadow,
	.leaflet-tile-container,
	.leaflet-pane > svg,
	.leaflet-pane > canvas,
	.leaflet-zoom-box,
	.leaflet-image-layer,
	.leaflet-layer {
		position: absolute !important;
		left: 0 !important;
		top: 0 !important;
	}
	.leaflet-container {
		overflow: hidden !important;
	}
	.leaflet-marker-icon,
	.leaflet-marker-shadow {
		max-width: none !important;
	}

	.wg-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
		gap: 16px;
		margin-top: 16px;
	}
	.wg-card {
		background: #fff;
		border: 1px solid #e0e0e0;
		border-radius: 10px;
		padding: 16px;
		transition: box-shadow 0.2s, border-color 0.2s;
		display: flex;
		flex-direction: column;
		gap: 10px;
	}
	.wg-card:hover {
		box-shadow: 0 4px 12px rgba(0,0,0,0.08);
		border-color: #0066cc;
	}
	.wg-card.wg-highlight {
		border-color: #0066cc;
		box-shadow: 0 0 0 3px rgba(0,102,204,0.25);
	}
	.wg-card-header {
		display: flex;
		gap: 12px;
		align-items: center;
	}
	.wg-card-header .avatar {
		flex-shrink: 0;
	}
	.wg-card-id {
		flex: 1;
		min-width: 0;
	}
	.wg-card-name {
		font-size: 17px;
		font-weight: 600;
		margin: 0;
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}
	.wg-card-name a {
		color: #0066cc;
		text-decoration: none;
	}
	.wg-card-name a:hover {
		text-decoration: underline;
	}
	.wg-card-slug {
		font-size: 12px;
		color: #999;
	}
	.wg-distance-pill {
		display: inline-block;
		background: linear-gradient(135deg, #ff6600, #ff8833);
		color: #fff;
		font-size: 13px;
		font-weight: 700;
		padding: 6px 12px;
		border-radius: 16px;
		text-align: center;
	}
	.wg-approx-badge {
		display: inline-block;
		background: #fff3e0;
		color: #e65100;
		font-size: 10px;
		font-weight: 600;
		padding: 2px 6px;
		border-radius: 6px;
		margin-left: 6px;
		text-transform: uppercase;
		letter-spacing: 0.3px;
	}
	.wg-location-block {
		background: #f8f9fa;
		border-radius: 6px;
		padding: 10px 12px;
		font-size: 13px;
		line-height: 1.5;
	}
	.wg-location-row {
		display: flex;
		gap: 6px;
		align-items: flex-start;
	}
	.wg-location-row + .wg-location-row {
		margin-top: 3px;
	}
	.wg-location-icon {
		flex-shrink: 0;
		color: #888;
		width: 16px;
		text-align: center;
	}
	.wg-location-label {
		color: #666;
		font-weight: 500;
		min-width: 80px;
	}
	.wg-location-value {
		color: #333;
		flex: 1;
		word-break: break-word;
	}
	.wg-roles-row {
		display: flex;
		gap: 4px;
		flex-wrap: wrap;
	}
	.wg-role-badge {
		display: inline-block;
		background: #e8f0fe;
		color: #0066cc;
		font-size: 10px;
		font-weight: 600;
		padding: 3px 8px;
		border-radius: 8px;
		text-transform: uppercase;
		letter-spacing: 0.3px;
	}
	.wg-role-badge.admin { background: #fce4ec; color: #c2185b; }
	.wg-role-badge.mod   { background: #e8f5e9; color: #2e7d32; }
	.wg-card-hint {
		font-size: 11px;
		color: #999;
		text-align: center;
		font-style: italic;
		margin-top: 4px;
	}
	.wg-card-hint b {
		color: #0066cc;
		font-style: normal;
	}
	/* Cluster styles */
	.marker-cluster div {
		font-weight: 700;
		color: #fff;
	}
	@media (max-width: 768px) {
		.wg-grid { grid-template-columns: 1fr; }
	}
</style>

<script>
(function() {
	'use strict';

	const state = {
		allUsers: [],
		filteredUsers: [],
		groupsList: [],
		callerLocation: null,
		isPrivileged: false,
		searchTimer: null,
		map: null,
		markerCluster: null,
		markerMap: {},
	};

	function $(id) { return document.getElementById(id); }
	function esc(s) { return String(s == null ? '' : s).replace(/[&<>"']/g, function(c) { return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }

	function haversine(lat1, lon1, lat2, lon2) {
		var R = 3959;
		var dLat = (lat2 - lat1) * Math.PI / 180;
		var dLon = (lon2 - lon1) * Math.PI / 180;
		var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1*Math.PI/180) * Math.cos(lat2*Math.PI/180) * Math.sin(dLon/2) * Math.sin(dLon/2);
		var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
		return R * c;
	}

	function avatarColor(uid) {
		var colors = ['#0066cc', '#dc143c', '#ff4500', '#28a745', '#ffc107', '#17a2b8', '#9c27b0', '#795548'];
		return colors[uid % colors.length];
	}

	function avatarLetter(username) {
		return (username || 'U').charAt(0).toUpperCase();
	}

	// Build a real NodeBB avatar element - the hovercard plugin will auto-bind to data-uid
	function buildAvatarHtml(user, size) {
		size = size || 50;
		var color = avatarColor(user.uid);
		var letter = avatarLetter(user.username);
		if (user.picture) {
			return '<span title="' + esc(user.username) + '" data-uid="' + user.uid + '" class="avatar avatar-rounded" component="avatar/picture" style="--avatar-size: ' + size + 'px;">' +
				'<img src="' + esc(user.picture) + '" alt="' + esc(user.username) + '"/>' +
				'</span>';
		}
		return '<span title="' + esc(user.username) + '" data-uid="' + user.uid + '" class="avatar avatar-rounded" component="avatar/icon" style="--avatar-size: ' + size + 'px; background-color: ' + color + ';">' + esc(letter) + '</span>';
	}

	function initMap() {
		state.map = L.map('wg-map').setView([39.5, -98.35], 4);

		// CRITICAL: Build tile URL at runtime using hex escapes for { and }
		// Dust.js (NodeBB's template engine) strips literal {s}/{z}/{x}/{y}
		// from .tpl files, producing broken URLs like 'https://.tile.osm.org///.png'
		var lb = '\x7b', rb = '\x7d';
		var tileUrl = 'https://' + lb + 's' + rb + '.tile.openstreetmap.org/' +
			lb + 'z' + rb + '/' + lb + 'x' + rb + '/' + lb + 'y' + rb + '.png';

		L.tileLayer(tileUrl, {
			maxZoom: 19,
			attribution: '© OpenStreetMap'
		}).addTo(state.map);

		state.markerCluster = L.markerClusterGroup({
			iconCreateFunction: function(cluster) {
				var n = cluster.getChildCount();
				var bg = n >= 50 ? '#f44336' : (n >= 10 ? '#ff9800' : '#4caf50');
				var html = '<div style="background:' + bg + ';width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;font-weight:700;font-size:14px;border:3px solid rgba(255,255,255,0.85);box-shadow:0 2px 6px rgba(0,0,0,0.3);">' + n + '</div>';
				return L.divIcon({ html: html, className: 'marker-cluster', iconSize: L.point(36, 36) });
			}
		});
		state.map.addLayer(state.markerCluster);

		// CRITICAL: invalidate size multiple times to handle late layout
		[100, 300, 600, 1200, 2000].forEach(function(ms) {
			setTimeout(function() {
				if (state.map) state.map.invalidateSize();
			}, ms);
		});
		window.addEventListener('load', function() {
			if (state.map) state.map.invalidateSize();
		});
		window.addEventListener('resize', function() {
			if (state.map) state.map.invalidateSize();
		});
	}

	function renderMarkers() {
		if (!state.map || !state.markerCluster) return;
		state.markerCluster.clearLayers();
		state.markerMap = {};

		var bounds = [];

		// Caller location marker
		if (state.callerLocation && typeof state.callerLocation.latitude === 'number') {
			var caller = L.circleMarker(
				[state.callerLocation.latitude, state.callerLocation.longitude],
				{ radius: 10, fillColor: '#0066cc', color: '#000', weight: 3, fillOpacity: 0.9 }
			).bindTooltip('You are here', { permanent: false });
			state.markerCluster.addLayer(caller);
			bounds.push([state.callerLocation.latitude, state.callerLocation.longitude]);
		}

		state.filteredUsers.forEach(function(u) {
			var lat = u.mapLatitude || u.latitude;
			var lng = u.mapLongitude || u.longitude;
			if (typeof lat !== 'number' || typeof lng !== 'number') return;

			var fill = u.isApproximate ? '#ff4500' : '#dc143c';
			var marker = L.circleMarker([lat, lng], {
				radius: 8, fillColor: fill, color: '#fff', weight: 2, fillOpacity: 0.9
			});

			// Tooltip on hover shows username
			marker.bindTooltip(esc(u.username || 'Unknown'), { permanent: false, direction: 'top' });

			// Popup contains the native avatar element - clicking it (or the marker) triggers NodeBB's hovercard
			var popupHtml =
				'<div style="text-align:center; min-width:180px; padding:8px;">' +
					'<div style="margin-bottom:8px;">' + buildAvatarHtml(u, 60) + '</div>' +
					'<div style="font-weight:600; font-size:15px; margin-bottom:4px;">' +
						'<a href="/user/' + esc(u.userslug) + '" style="color:#0066cc; text-decoration:none;">' + esc(u.username) + '</a>' +
					'</div>' +
					'<div style="font-size:11px; color:#888;">Click the avatar above to see profile actions</div>' +
				'</div>';
			marker.bindPopup(popupHtml, { maxWidth: 240, minWidth: 200 });

			// On marker click: open popup AND highlight card below
			marker.on('click', function() {
				var cardEl = $('wg-user-' + u.uid);
				if (cardEl) {
					document.querySelectorAll('.wg-card.wg-highlight').forEach(function(el) {
						el.classList.remove('wg-highlight');
					});
					cardEl.classList.add('wg-highlight');
					cardEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
					setTimeout(function() { cardEl.classList.remove('wg-highlight'); }, 3000);
				}
			});

			// When the popup is opened, trigger NodeBB's hovercard binding on the inserted avatar
			marker.on('popupopen', function(ev) {
				var popupEl = ev.popup.getElement();
				if (!popupEl) return;
				var avatarEl = popupEl.querySelector('[data-uid]');
				if (avatarEl && typeof require !== 'undefined') {
					// Tell NodeBB's hovercard module to re-scan this DOM region
					try {
						require(['hover-card'], function(hoverCard) {
							if (hoverCard && hoverCard.attachHoverCard) {
								hoverCard.attachHoverCard(avatarEl);
							}
						});
					} catch (e) {
						// Fallback: dispatch mouseenter event which most hovercard plugins listen for
						var evt = new MouseEvent('mouseenter', { bubbles: true, cancelable: true });
						avatarEl.dispatchEvent(evt);
					}
				}
			});

			state.markerCluster.addLayer(marker);
			state.markerMap[u.uid] = marker;
			bounds.push([lat, lng]);
		});

		if (bounds.length > 1) {
			try { state.map.fitBounds(bounds, { padding: [40, 40], maxZoom: 12 }); } catch (e) {}
		}
	}

	function fetchUsers() {
		var params = ['radius=99999', 'limit=10000'];
		if ($('wg-role').value) params.push('roles=' + encodeURIComponent($('wg-role').value));
		if ($('wg-group').value) params.push('group=' + encodeURIComponent($('wg-group').value));

		return fetch('/api/v3/plugins/waymker-geo/users-near-me?' + params.join('&'),
			{ credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
			.then(function(r) { return r.json(); })
			.then(function(data) {
				state.allUsers = data.users || [];
				state.callerLocation = data.callerLocation || null;
				state.isPrivileged = !!data.isPrivileged;

				if (state.callerLocation) {
					state.allUsers.forEach(function(u) {
						if (typeof u.latitude === 'number' && typeof u.longitude === 'number') {
							u.distance = haversine(state.callerLocation.latitude, state.callerLocation.longitude, u.latitude, u.longitude);
						}
					});
					state.allUsers.sort(function(a, b) { return (a.distance || 999999) - (b.distance || 999999); });
				}

				applyFilters();
				fetchGroups();
			})
			.catch(function(err) {
				console.error('[waymker-geo] fetch failed', err);
				$('wg-results-grid').innerHTML = '<div class="alert alert-danger">Could not load nearby members.</div>';
			});
	}

	function fetchGroups() {
		fetch('/api/groups', { credentials: 'same-origin' })
			.then(function(r) { return r.json(); })
			.then(function(data) {
				state.groupsList = (data.groups || []).filter(function(g) { return g && g.name && !g.system && !g.hidden; });
				var sel = $('wg-group');
				var current = sel.value;
				sel.innerHTML = '<option value="">All groups</option>';
				state.groupsList.forEach(function(g) {
					var opt = document.createElement('option');
					opt.value = g.name;
					opt.textContent = g.displayName || g.name;
					sel.appendChild(opt);
				});
				sel.value = current;
			})
			.catch(function() {});
	}

	function applyFilters() {
		var q = ($('wg-search').value || '').trim().toLowerCase();
		var users = state.allUsers.slice();
		if (q) {
			users = users.filter(function(u) {
				var name = (u.username || '').toLowerCase();
				var city = (u.city || '').toLowerCase();
				var hood = (u.neighborhood || '').toLowerCase();
				var state_ = (u.state || '').toLowerCase();
				return name.indexOf(q) !== -1 || city.indexOf(q) !== -1 || hood.indexOf(q) !== -1 || state_.indexOf(q) !== -1;
			});
		}
		state.filteredUsers = users;
		$('wg-results-grid').innerHTML = '';
		renderMarkers();
		renderCards();
		$('wg-count-badge').textContent = users.length;
		$('wg-results-info').textContent = users.length + (users.length === 1 ? ' member found' : ' members found');
	}

	function buildRolesHtml(user) {
		if (!user.roles || !user.roles.length) return '';
		var html = '<div class="wg-roles-row">';
		user.roles.forEach(function(r) {
			var name = (r && (r.displayName || r.name)) || '';
			if (!name) return;
			var lname = name.toLowerCase();
			var cls = 'wg-role-badge';
			if (lname.indexOf('admin') !== -1) cls += ' admin';
			else if (lname.indexOf('moderator') !== -1 || lname.indexOf('mod') !== -1) cls += ' mod';
			html += '<span class="' + cls + '">' + esc(name) + '</span>';
		});
		html += '</div>';
		return html;
	}

	function buildLocationBlock(user) {
		var rows = [];

		if (user.neighborhood) {
			rows.push('<div class="wg-location-row"><span class="wg-location-icon">🏘️</span><span class="wg-location-label">Neighborhood:</span><span class="wg-location-value">' + esc(user.neighborhood) + '</span></div>');
		}
		if (user.city || user.state) {
			var cityState = [user.city, user.state].filter(Boolean).join(', ');
			rows.push('<div class="wg-location-row"><span class="wg-location-icon">🏙️</span><span class="wg-location-label">City/State:</span><span class="wg-location-value">' + esc(cityState) + '</span></div>');
		}
		if (user.zipCode) {
			rows.push('<div class="wg-location-row"><span class="wg-location-icon">📮</span><span class="wg-location-label">ZIP:</span><span class="wg-location-value">' + esc(user.zipCode) + '</span></div>');
		}
		if (user.country) {
			rows.push('<div class="wg-location-row"><span class="wg-location-icon">🌎</span><span class="wg-location-label">Country:</span><span class="wg-location-value">' + esc(user.country) + '</span></div>');
		}
		// Show exact address only if privileged
		if (state.isPrivileged && user.address) {
			rows.push('<div class="wg-location-row"><span class="wg-location-icon">📍</span><span class="wg-location-label">Address:</span><span class="wg-location-value">' + esc(user.address) + '</span></div>');
		}

		if (!rows.length) {
			rows.push('<div class="wg-location-row"><span class="wg-location-icon">📍</span><span class="wg-location-value" style="color:#999; font-style:italic;">Location not shared</span></div>');
		}

		return '<div class="wg-location-block">' + rows.join('') + '</div>';
	}

	function buildCardHtml(user) {
		var distanceStr = (typeof user.distance === 'number') ? user.distance.toFixed(1) + ' mi away' : '';
		var approxBadge = user.isApproximate ? '<span class="wg-approx-badge">approx</span>' : '';

		var html = '<div id="wg-user-' + user.uid + '" class="wg-card" data-uid="' + user.uid + '">';

		// Header: native avatar + name + slug
		html += '<div class="wg-card-header">';
		html += buildAvatarHtml(user, 50);
		html += '<div class="wg-card-id">';
		html += '<h4 class="wg-card-name"><a href="/user/' + esc(user.userslug || '') + '">' + esc(user.username || 'Unknown') + '</a></h4>';
		html += '<div class="wg-card-slug">@' + esc(user.userslug || '') + '</div>';
		html += '</div>';
		html += '</div>';

		// Distance (most prominent)
		if (distanceStr) {
			html += '<div style="text-align:center;"><span class="wg-distance-pill">📏 ' + distanceStr + '</span>' + approxBadge + '</div>';
		}

		// Location details block
		html += buildLocationBlock(user);

		// Roles
		html += buildRolesHtml(user);

		// Hint
		html += '<div class="wg-card-hint">Hover the <b>avatar</b> for profile actions (follow, chat, etc.)</div>';

		html += '</div>';
		return html;
	}

	function renderCards() {
		var grid = $('wg-results-grid');
		if (!state.filteredUsers.length) {
			grid.innerHTML = '<div class="alert alert-info" style="grid-column: 1 / -1;">No members found.</div>';
			return;
		}
		var html = '';
		state.filteredUsers.forEach(function(u) { html += buildCardHtml(u); });
		grid.innerHTML = html;

		// Add click handlers to cards to center map on marker
		grid.addEventListener('click', function(e) {
			var card = e.target.closest('.wg-card');
			if (!card) return;
			var uid = parseInt(card.getAttribute('data-uid'), 10);
			if (!uid || !state.markerMap[uid]) return;

			var marker = state.markerMap[uid];
			var latlng = marker.getLatLng();

			// Center map on this marker
			state.map.flyTo(latlng, 13, { duration: 0.8 });

			// Highlight the card
			document.querySelectorAll('.wg-card.wg-highlight').forEach(function(el) {
				el.classList.remove('wg-highlight');
			});
			card.classList.add('wg-highlight');
			setTimeout(function() { card.classList.remove('wg-highlight'); }, 2000);

			// Scroll map into view if needed
			var mapEl = document.querySelector('#wg-map');
			if (mapEl && mapEl.getBoundingClientRect().top < 0) {
				mapEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
			}
		});
	}

	function init() {
		initMap();

		$('wg-role').addEventListener('change', fetchUsers);
		$('wg-group').addEventListener('change', fetchUsers);
		$('wg-search').addEventListener('input', function() {
			clearTimeout(state.searchTimer);
			state.searchTimer = setTimeout(applyFilters, 200);
		});
		$('wg-reset').addEventListener('click', function() {
			$('wg-search').value = '';
			$('wg-role').value = '';
			$('wg-group').value = '';
			fetchUsers();
		});

		fetchUsers();
	}

	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', init);
	} else {
		init();
	}
})();
</script>
