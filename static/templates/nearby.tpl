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

<style>
	#wg-map img.leaflet-tile, #wg-map .leaflet-container img, .leaflet-container img.leaflet-tile, .leaflet-tile {
		max-width: none !important; max-height: none !important; width: 256px !important; height: 256px !important;
	}
	.leaflet-container img { max-width: none !important; }
	.leaflet-pane, .leaflet-tile, .leaflet-marker-icon, .leaflet-marker-shadow, .leaflet-tile-container, .leaflet-pane > svg, .leaflet-pane > canvas, .leaflet-zoom-box, .leaflet-image-layer, .leaflet-layer {
		position: absolute !important; left: 0 !important; top: 0 !important;
	}
	.leaflet-container { overflow: hidden !important; }
	.leaflet-marker-icon, .leaflet-marker-shadow { max-width: none !important; }
	.wg-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 16px; margin-top: 16px; }
	.wg-card { background: #fff; border: 1px solid #e0e0e0; border-radius: 10px; padding: 16px; transition: box-shadow 0.2s, border-color 0.2s; display: flex; flex-direction: column; gap: 10px; }
	.wg-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); border-color: #0066cc; }
	.wg-card.wg-highlight { border-color: #0066cc; box-shadow: 0 0 0 3px rgba(0,102,204,0.25); }
	.wg-card-header { display: flex; gap: 12px; align-items: center; }
	.wg-card-header .avatar { flex-shrink: 0; }
	.wg-card-id { flex: 1; min-width: 0; }
	.wg-card-name { font-size: 17px; font-weight: 600; margin: 0; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
	.wg-card-name a { color: #0066cc; text-decoration: none; }
	.wg-card-name a:hover { text-decoration: underline; }
	.wg-card-slug { font-size: 12px; color: #999; }
	.wg-distance-pill { display: inline-block; background: linear-gradient(135deg, #ff6600, #ff8833); color: #fff; font-size: 13px; font-weight: 700; padding: 6px 12px; border-radius: 16px; text-align: center; }
	.wg-approx-badge { display: inline-block; background: #fff3e0; color: #e65100; font-size: 10px; font-weight: 600; padding: 2px 6px; border-radius: 6px; margin-left: 6px; text-transform: uppercase; letter-spacing: 0.3px; }
	.wg-location-block { background: #f8f9fa; border-radius: 6px; padding: 10px 12px; font-size: 13px; line-height: 1.5; }
	.wg-location-row { display: flex; gap: 6px; align-items: flex-start; }
	.wg-location-row + .wg-location-row { margin-top: 3px; }
	.wg-location-icon { flex-shrink: 0; color: #888; width: 16px; text-align: center; }
	.wg-location-label { color: #666; font-weight: 500; min-width: 80px; }
	.wg-location-value { color: #333; flex: 1; word-break: break-word; }
	.wg-roles-row { display: flex; gap: 4px; flex-wrap: wrap; }
	.wg-role-badge { display: inline-block; background: #e8f0fe; color: #0066cc; font-size: 10px; font-weight: 600; padding: 3px 8px; border-radius: 8px; text-transform: uppercase; letter-spacing: 0.3px; }
	.wg-role-badge.admin { background: #fce4ec; color: #c2185b; }
	.wg-role-badge.mod { background: #e8f5e9; color: #2e7d32; }
	.wg-card-hint { font-size: 11px; color: #999; text-align: center; font-style: italic; margin-top: 4px; }
	.wg-card-hint b { color: #0066cc; font-style: normal; }
	.marker-cluster div { font-weight: 700; color: #fff; }
	@media (max-width: 768px) { .wg-grid { grid-template-columns: 1fr; } }
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
		initialized: false,
		pendingTimeouts: [],
		initId: 0,
	};

	function cleanup() {
		console.log('[waymker-geo] Cleaning up...');
		state.pendingTimeouts.forEach(clearTimeout);
		state.pendingTimeouts = [];
		if (state.searchTimer) clearTimeout(state.searchTimer);
		if (state.markerCluster) {
			try { state.markerCluster.clearLayers(); } catch (e) {}
			state.markerCluster = null;
		}
		if (state.map) {
			try { state.map.remove(); } catch (e) {}
			state.map = null;
		}
		state.markerMap = {};
		state.allUsers = [];
		state.filteredUsers = [];
		state.groupsList = [];
		state.callerLocation = null;
		state.isPrivileged = false;
		state.initialized = false;
	}

	window.addEventListener('beforeunload', cleanup);
	window.addEventListener('pagehide', cleanup);
	cleanup();

	function $(id) { return document.getElementById(id); }
	function esc(s) { return String(s == null ? '' : s).replace(/[&<>"']/g, function(c) { return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]; }); }
	function haversine(lat1, lon1, lat2, lon2) {
		var R = 3959, dLat = (lat2 - lat1) * Math.PI / 180, dLon = (lon2 - lon1) * Math.PI / 180;
		var a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1*Math.PI/180) * Math.cos(lat2*Math.PI/180) * Math.sin(dLon/2) * Math.sin(dLon/2);
		var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
		return R * c;
	}
	function avatarColor(uid) { var colors = ['#0066cc', '#dc143c', '#ff4500', '#28a745', '#ffc107', '#17a2b8', '#9c27b0', '#795548']; return colors[uid % colors.length]; }
	function avatarLetter(username) { return (username || 'U').charAt(0).toUpperCase(); }
	function buildAvatarHtml(user, size) {
		size = size || 50;
		var color = avatarColor(user.uid), letter = avatarLetter(user.username);
		if (user.picture) return '<span title="' + esc(user.username) + '" data-uid="' + user.uid + '" class="avatar avatar-rounded" component="avatar/picture" style="--avatar-size: ' + size + 'px;"><img src="' + esc(user.picture) + '" alt="' + esc(user.username) + '"/></span>';
		return '<span title="' + esc(user.username) + '" data-uid="' + user.uid + '" class="avatar avatar-rounded" component="avatar/icon" style="--avatar-size: ' + size + 'px; background-color: ' + color + ';">' + esc(letter) + '</span>';
	}

	function initMap() {
		var container = document.getElementById('wg-map');
		if (!container) { console.error('[waymker-geo] Map container #wg-map not found!'); return; }
		state.map = L.map('wg-map').setView([39.5, -98.35], 4);
		state.map.whenReady(function() { state.map.invalidateSize(); });
		var lb = '\x7b', rb = '\x7d';
		var tileUrl = 'https://' + lb + 's' + rb + '.tile.openstreetmap.org/' + lb + 'z' + rb + '/' + lb + 'x' + rb + '/' + lb + 'y' + rb + '.png';
		L.tileLayer(tileUrl, { maxZoom: 19, attribution: '© OpenStreetMap' }).addTo(state.map);
		state.markerCluster = L.markerClusterGroup({
			disableClusteringAtZoom: 12, spiderfyOnMaxZoom: false, maxClusterRadius: 60, showCoverageOnHover: false, zoomToBoundsOnClick: true,
			iconCreateFunction: function(cluster) {
				var n = cluster.getChildCount(), bg = n >= 50 ? '#f44336' : (n >= 10 ? '#ff9800' : '#4caf50');
				var html = '<div style="background:' + bg + ';width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;font-weight:700;font-size:14px;border:3px solid rgba(255,255,255,0.85);box-shadow:0 2px 6px rgba(0,0,0,0.3);">' + n + '</div>';
				return L.divIcon({ html: html, className: 'marker-cluster', iconSize: L.point(36, 36) });
			}
		});
		[100, 300, 600, 1200, 2000].forEach(function(ms) {
			var id = setTimeout(function() { if (state.map) state.map.invalidateSize(); }, ms);
			state.pendingTimeouts.push(id);
		});
		window.addEventListener('load', function() { if (state.map) state.map.invalidateSize(); });
		window.addEventListener('resize', function() { if (state.map) state.map.invalidateSize(); });
	}

	function renderMarkers() {
		if (!state.map || !state.markerCluster) return;
		try { state.markerCluster.clearLayers(); } catch (e) {}
		state.markerMap = {};
		var bounds = [];
		if (state.callerLocation && typeof state.callerLocation.latitude === 'number') {
			var caller = L.circleMarker([state.callerLocation.latitude, state.callerLocation.longitude], { radius: 10, fillColor: '#0066cc', color: '#000', weight: 3, fillOpacity: 0.9 }).bindTooltip('You are here', { permanent: false });
			state.markerCluster.addLayer(caller);
			bounds.push([state.callerLocation.latitude, state.callerLocation.longitude]);
		}
		state.filteredUsers.forEach(function(u) {
			var lat = u.mapLatitude || u.latitude, lng = u.mapLongitude || u.longitude;
			if (typeof lat !== 'number' || typeof lng !== 'number') return;
			var fill = u.isApproximate ? '#ff4500' : '#dc143c';
			var marker = L.circleMarker([lat, lng], { radius: 8, fillColor: fill, color: '#fff', weight: 2, fillOpacity: 0.9 });
			marker.bindTooltip(esc(u.username || 'Unknown'), { permanent: false, direction: 'top' });
			var popupHtml = '<div style="text-align:center; min-width:180px; padding:8px;"><div style="margin-bottom:8px;">' + buildAvatarHtml(u, 60) + '</div><div style="font-weight:600; font-size:15px; margin-bottom:4px;"><a href="/user/' + esc(u.userslug) + '" style="color:#0066cc; text-decoration:none;">' + esc(u.username) + '</a></div><div style="font-size:11px; color:#888;">Click the avatar above to see profile actions</div></div>';
			marker.bindPopup(popupHtml, { maxWidth: 240, minWidth: 200 });
			marker.on('click', function() {
				var cardEl = document.getElementById('wg-user-' + u.uid);
				if (cardEl) {
					document.querySelectorAll('.wg-card.wg-highlight').forEach(function(el) { el.classList.remove('wg-highlight'); });
					cardEl.classList.add('wg-highlight');
					cardEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
					setTimeout(function() { cardEl.classList.remove('wg-highlight'); }, 3000);
				}
			});
			marker.on('popupopen', function(ev) {
				var popupEl = ev.popup.getElement();
				if (!popupEl) return;
				var avatarEl = popupEl.querySelector('[data-uid]');
				if (avatarEl && typeof require !== 'undefined') {
					try {
						require(['hover-card'], function(hoverCard) {
							if (hoverCard && hoverCard.attachHoverCard) hoverCard.attachHoverCard(avatarEl);
						});
					} catch (e) {
						var evt = new MouseEvent('mouseenter', { bubbles: true, cancelable: true });
						avatarEl.dispatchEvent(evt);
					}
				}
			});
			state.markerCluster.addLayer(marker);
			state.markerMap[u.uid] = marker;
			bounds.push([lat, lng]);
		});
		try {
			if (!state.map.hasLayer(state.markerCluster)) {
				state.map.addLayer(state.markerCluster);
			}
		} catch (e) {}
		setTimeout(function() { if (state.map) state.map.invalidateSize(); }, 50);
		setTimeout(function() { if (state.map) state.map.invalidateSize(); }, 200);
		if (bounds.length > 1) {
			var boundsObj = L.latLngBounds(bounds);
			var boundsSize = boundsObj.getSouthWest().distanceTo(boundsObj.getNorthEast());
			if (boundsSize < 100) {
				state.map.setView(boundsObj.getCenter(), 13, { animate: false });
			} else {
				try { state.map.fitBounds(bounds, { padding: [40, 40], maxZoom: 15, animate: false }); } catch (e) {}
			}
		} else if (bounds.length === 1) {
			state.map.setView(bounds[0], 13, { animate: false });
		}
	}

	function fetchUsers() {
		var fetchInitId = state.initId;
		var params = ['radius=99999', 'limit=10000'];
		if ($('wg-role').value) params.push('roles=' + encodeURIComponent($('wg-role').value));
		if ($('wg-group').value) params.push('group=' + encodeURIComponent($('wg-group').value));
		var url = '/api/v3/plugins/waymker-geo/users-near-me?' + params.join('&');
		return fetch(url, { credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
			.then(function(r) { if (!r.ok) throw new Error('API returned ' + r.status); return r.json(); })
			.then(function(data) {
				if (state.initId !== fetchInitId) { console.log('[waymker-geo] Stale fetch, ignoring'); return; }
				if (!data || !data.users) throw new Error('Invalid response structure');
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
				if (state.initId !== fetchInitId) return;
				console.error('[waymker-geo] Fetch failed:', err);
				$('wg-results-grid').innerHTML = '<div class="alert alert-danger" style="grid-column: 1 / -1;"><strong>Error loading members:</strong> ' + esc(err.message) + '<br/><small style="opacity: 0.7;">Check browser console for details. Try <a href="#" onclick="location.reload(); return false;">refreshing the page</a>.</small></div>';
			});
	}

	function fetchGroups() {
		fetch('/api/groups', { credentials: 'same-origin' })
			.then(function(r) { return r.json(); })
			.then(function(data) {
				state.groupsList = (data.groups || []).filter(function(g) { return g && g.name && !g.system && !g.hidden; });
				var sel = $('wg-group'), current = sel.value;
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
				var name = (u.username || '').toLowerCase(), city = (u.city || '').toLowerCase(), hood = (u.neighborhood || '').toLowerCase(), state_ = (u.state || '').toLowerCase();
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
			var lname = name.toLowerCase(), cls = 'wg-role-badge';
			if (lname.indexOf('admin') !== -1) cls += ' admin';
			else if (lname.indexOf('moderator') !== -1 || lname.indexOf('mod') !== -1) cls += ' mod';
			html += '<span class="' + cls + '">' + esc(name) + '</span>';
		});
		html += '</div>';
		return html;
	}

	function buildLocationBlock(user) {
		var rows = [];
		if (user.neighborhood) rows.push('<div class="wg-location-row"><span class="wg-location-icon">🏘️</span><span class="wg-location-label">Neighborhood:</span><span class="wg-location-value">' + esc(user.neighborhood) + '</span></div>');
		if (user.city || user.state) {
			var cityState = [user.city, user.state].filter(Boolean).join(', ');
			rows.push('<div class="wg-location-row"><span class="wg-location-icon">🏙️</span><span class="wg-location-label">City/State:</span><span class="wg-location-value">' + esc(cityState) + '</span></div>');
		}
		if (user.zipCode) rows.push('<div class="wg-location-row"><span class="wg-location-icon">📮</span><span class="wg-location-label">ZIP:</span><span class="wg-location-value">' + esc(user.zipCode) + '</span></div>');
		if (user.country) rows.push('<div class="wg-location-row"><span class="wg-location-icon">🌎</span><span class="wg-location-label">Country:</span><span class="wg-location-value">' + esc(user.country) + '</span></div>');
		if (state.isPrivileged && user.address) rows.push('<div class="wg-location-row"><span class="wg-location-icon">📍</span><span class="wg-location-label">Address:</span><span class="wg-location-value">' + esc(user.address) + '</span></div>');
		if (!rows.length) rows.push('<div class="wg-location-row"><span class="wg-location-icon">📍</span><span class="wg-location-value" style="color:#999; font-style:italic;">Location not shared</span></div>');
		return '<div class="wg-location-block">' + rows.join('') + '</div>';
	}

	function buildCardHtml(user) {
		var distanceStr = (typeof user.distance === 'number') ? user.distance.toFixed(1) + ' mi away' : '', approxBadge = user.isApproximate ? '<span class="wg-approx-badge">approx</span>' : '';
		var html = '<div id="wg-user-' + user.uid + '" class="wg-card" data-uid="' + user.uid + '">';
		html += '<div class="wg-card-header">';
		html += buildAvatarHtml(user, 50);
		html += '<div class="wg-card-id"><h4 class="wg-card-name"><a href="/user/' + esc(user.userslug || '') + '">' + esc(user.username || 'Unknown') + '</a></h4><div class="wg-card-slug">@' + esc(user.userslug || '') + '</div></div></div>';
		if (distanceStr) html += '<div style="text-align:center;"><span class="wg-distance-pill">📏 ' + distanceStr + '</span>' + approxBadge + '</div>';
		html += buildLocationBlock(user) + buildRolesHtml(user);
		html += '<div class="wg-card-hint">Hover the <b>avatar</b> for profile actions (follow, chat, etc.)</div></div>';
		return html;
	}

	function renderCards() {
		var grid = $('wg-results-grid');
		if (!state.filteredUsers.length) { grid.innerHTML = '<div class="alert alert-info" style="grid-column: 1 / -1;">No members found.</div>'; return; }
		var html = '';
		state.filteredUsers.forEach(function(u) { html += buildCardHtml(u); });
		grid.innerHTML = html;
		grid.addEventListener('click', function(e) {
			var card = e.target.closest('.wg-card');
			if (!card) return;
			var uid = parseInt(card.getAttribute('data-uid'), 10);
			if (!uid || !state.markerMap[uid]) return;
			var marker = state.markerMap[uid];
			if (!marker || !state.map) return;
			try {
				var latlng = marker.getLatLng();
				if (!latlng || typeof latlng.lat !== 'number') return;
				state.map.flyTo(latlng, 14, { duration: 0.8 });
				document.querySelectorAll('.wg-card.wg-highlight').forEach(function(el) { el.classList.remove('wg-highlight'); });
				card.classList.add('wg-highlight');
				setTimeout(function() { card.classList.remove('wg-highlight'); }, 2000);
				var mapEl = document.querySelector('#wg-map');
				if (mapEl && mapEl.getBoundingClientRect().top < 0) mapEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
			} catch (err) {}
		});
	}

	function init() {
		// FIXED: Safe typeof checks for Leaflet
		if (typeof L === 'undefined' || typeof L.map === 'undefined' || typeof L.markerClusterGroup === 'undefined') {
			console.log('[waymker-geo] Leaflet not ready, retrying...');
			setTimeout(init, 200);
			return;
		}
		if (state.initialized) cleanup();
		state.initialized = true;
		state.initId++;
		console.log('[waymker-geo] init() starting, initId: ' + state.initId);
		initMap();
		$('wg-role').addEventListener('change', function() { if (state.initId && state.initialized) fetchUsers(); });
		$('wg-group').addEventListener('change', function() { if (state.initId && state.initialized) fetchUsers(); });
		$('wg-search').addEventListener('input', function() {
			clearTimeout(state.searchTimer);
			state.searchTimer = setTimeout(applyFilters, 200);
			state.pendingTimeouts.push(state.searchTimer);
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

	function registerAjaxifyHook() {
		if (typeof window.$ === 'function' && window.$.fn) {
			try {
				window.$(window).off('action:ajaxify.end.waymkerGeo');
				window.$(window).on('action:ajaxify.end.waymkerGeo', function(ev, data) {
					if (data && data.url && data.url.indexOf('directory/nearby') !== -1) {
						console.log('[waymker-geo] ajaxify.end detected on nearby page, re-initializing');
						setTimeout(function() { if (document.getElementById('wg-map')) init(); }, 50);
					}
				});
				return true;
			} catch (e) { return false; }
		}
		return false;
	}

	if (!registerAjaxifyHook()) {
		var retryCount = 0;
		var retryInterval = setInterval(function() {
			retryCount++;
			if (registerAjaxifyHook() || retryCount > 20) clearInterval(retryInterval);
		}, 100);
	}
})();
</script>
