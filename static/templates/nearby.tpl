<div class="container" style="margin-top: 20px;">
	<div class="row">
		<div class="col-lg-12">
			<h1>Nearby Members <span id="wg-count-badge" class="badge">0</span></h1>
			<a href="/users" class="btn btn-link">← All Members</a>
		</div>
	</div>

	<!-- Filters -->
	<div class="row" style="margin: 20px 0; gap: 10px;">
		<div class="col-md-3">
			<input type="text" id="wg-search" class="form-control" placeholder="Search username...">
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

	<!-- Native Cards Grid -->
	<h3 id="wg-results-info" style="margin-top: 30px;">Members</h3>
	<div id="wg-results-grid" class="users-list" style="display: grid; gap: 20px; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));"></div>
</div>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.Default.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/leaflet.markercluster.js"></script>

<style>
	.user-card {
		background: #fff;
		border: 1px solid #e9ecef;
		border-radius: 4px;
		overflow: hidden;
		transition: box-shadow 0.2s;
	}
	.user-card:hover {
		box-shadow: 0 2px 8px rgba(0,0,0,0.1);
	}
	.user-card.wg-highlight {
		box-shadow: 0 0 0 3px #0066cc !important;
	}
	.user-card > .user-card-image {
		background: #f8f9fa;
		height: 150px;
		position: relative;
	}
	.user-card > .user-card-image img {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}
	.user-card > .user-card-body {
		padding: 15px;
		position: relative;
	}
	.user-card > .user-card-body .user-picture {
		position: absolute;
		top: -35px;
		left: 15px;
		width: 70px;
		height: 70px;
		border-radius: 4px;
		border: 3px solid #fff;
		box-shadow: 0 2px 4px rgba(0,0,0,0.1);
		background: #f8f9fa;
		display: flex;
		align-items: center;
		justify-content: center;
		font-size: 24px;
		font-weight: bold;
		color: #fff;
	}
	.user-card .user-info {
		margin-top: 40px;
	}
	.user-card .user-info h4 {
		margin: 0 0 5px 0;
		font-size: 16px;
		font-weight: 600;
	}
	.user-card .user-info h4 a {
		color: #0066cc;
		text-decoration: none;
	}
	.user-card .user-info h4 a:hover {
		text-decoration: underline;
	}
	.user-card .user-info .user-slug {
		color: #999;
		font-size: 12px;
		margin-bottom: 5px;
	}
	.user-card .user-info .user-status {
		font-size: 12px;
		color: #666;
		margin-bottom: 10px;
	}
	.user-card .user-location {
		font-size: 12px;
		color: #666;
		margin: 5px 0;
	}
	.user-card .user-distance {
		font-size: 12px;
		color: #ff6600;
		font-weight: 600;
		margin: 5px 0;
	}
	.user-card .user-stats {
		display: flex;
		gap: 15px;
		margin: 10px 0;
		padding-top: 10px;
		border-top: 1px solid #f0f0f0;
		font-size: 12px;
	}
	.user-card .user-stats > div {
		text-align: center;
	}
	.user-card .user-stats .stat-value {
		display: block;
		font-size: 16px;
		font-weight: 600;
		color: #333;
	}
	.user-card .user-stats .stat-label {
		display: block;
		color: #999;
		margin-top: 2px;
	}
	.user-card .user-actions {
		margin-top: 10px;
		display: flex;
		gap: 8px;
	}
	.user-card .user-actions .btn {
		flex: 1;
		font-size: 12px;
		padding: 6px 10px;
	}

	.leaflet-popup-content-wrapper {
		border-radius: 4px;
	}
	.leaflet-popup-content {
		margin: 0;
		width: 320px !important;
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
		searchTimer: null,
		map: null,
		markerCluster: null,
		markerMap: {},
	};

	function $(id) { return document.getElementById(id); }
	function esc(s) { return String(s || '').replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c])); }
	
	function haversine(lat1, lon1, lat2, lon2) {
		const R = 3959;
		const dLat = (lat2 - lat1) * Math.PI / 180;
		const dLon = (lon2 - lon1) * Math.PI / 180;
		const a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos(lat1*Math.PI/180) * Math.cos(lat2*Math.PI/180) * Math.sin(dLon/2) * Math.sin(dLon/2);
		const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
		return R * c;
	}

	function initMap() {
		state.map = L.map('wg-map').setView([39, -95], 4);
		L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
			attribution: '© OpenStreetMap',
			maxZoom: 19
		}).addTo(state.map);
		state.markerCluster = L.markerClusterGroup();
		state.map.addLayer(state.markerCluster);
	}

	function buildNativePopupHtml(u) {
		const txt = (u.username || 'U')[0].toUpperCase();
		const col = ['#0066cc', '#dc143c', '#ff4500', '#28a745', '#ffc107', '#17a2b8'][u.uid % 6];
		const distStr = u.distance ? u.distance.toFixed(1) + ' mi away' : 'N/A';
		const locParts = [];
		if (u.neighborhood) locParts.push(u.neighborhood);
		if (u.city) locParts.push(u.city);
		if (u.state) locParts.push(u.state);
		const loc = locParts.join(', ') || u.country || '?';

		return '<div class="user-card" style="margin: 0; border: none; box-shadow: none;">' +
			'<div class="user-card-image" style="height: 100px;"><div style="background: ' + col + '; height: 100%; display: flex; align-items: center; justify-content: center;"><span style="font-size: 40px; color: white; font-weight: bold;">' + txt + '</span></div></div>' +
			'<div class="user-card-body" style="padding: 15px;">' +
			'<div style="margin-top: 0;">' +
			'<h4 style="margin: 0 0 5px 0;"><a href="/user/' + esc(u.userslug) + '" style="color: #0066cc; text-decoration: none;">' + esc(u.username) + '</a></h4>' +
			'<div style="font-size: 12px; color: #999;">@' + esc(u.userslug) + '</div>' +
			'<div class="user-location">📍 ' + esc(loc) + '</div>' +
			'<div class="user-distance">' + distStr + '</div>' +
			'<div class="user-stats" style="display: flex; gap: 10px; margin-top: 10px; font-size: 11px;">' +
			'<div style="text-align: center;"><span style="font-weight: 600; font-size: 14px;">' + (u.reputation || 0) + '</span><br>REPUTATION</div>' +
			'<div style="text-align: center;"><span style="font-weight: 600; font-size: 14px;">' + (u.postcount || 0) + '</span><br>POSTS</div>' +
			'<div style="text-align: center;"><span style="font-weight: 600; font-size: 14px;">' + (u.followerCount || 0) + '</span><br>FOLLOWERS</div>' +
			'</div>' +
			'<div style="margin-top: 10px; display: flex; gap: 8px;">' +
			'<a href="/user/' + esc(u.userslug) + '" class="btn btn-primary" style="flex: 1; font-size: 11px; padding: 6px 8px; text-decoration: none;">View Profile</a>' +
			'</div>' +
			'</div>' +
			'</div>' +
			'</div>';
	}

	function renderMarkers() {
		if (!state.map) return;
		state.markerCluster.clearLayers();
		state.markerMap = {};

		const bounds = [];
		if (state.callerLocation && typeof state.callerLocation.latitude === 'number') {
			const caller = L.circleMarker(
				[state.callerLocation.latitude, state.callerLocation.longitude],
				{ radius: 10, fillColor: '#0066cc', color: '#000', weight: 3, fillOpacity: 0.9 }
			);
			state.markerCluster.addLayer(caller);
			bounds.push([state.callerLocation.latitude, state.callerLocation.longitude]);
		}

		state.filteredUsers.forEach(u => {
			const lat = u.latitude;
			const lng = u.longitude;
			if (typeof lat !== 'number' || typeof lng !== 'number') return;

			const marker = L.circleMarker([lat, lng], {
				radius: 7,
				fillColor: '#ff4500',
				color: '#fff',
				weight: 2,
				fillOpacity: 0.9
			});

			marker.bindTooltip(esc(u.username || ''), { permanent: false });
			marker.bindPopup(buildNativePopupHtml(u), { maxWidth: 320 });
			
			// Click marker to:
			// 1. Open popup
			// 2. Highlight card below
			marker.on('click', function() {
				// Open popup
				marker.openPopup();

				// Highlight card below
				const cardEl = document.getElementById('wg-user-' + u.uid);
				if (cardEl) {
					// Remove highlight from all cards
					document.querySelectorAll('.user-card.wg-highlight').forEach(el => {
						el.classList.remove('wg-highlight');
					});
					// Add highlight to this card
					cardEl.classList.add('wg-highlight');
					// Scroll into view
					cardEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
					// Remove highlight after 3 seconds
					setTimeout(() => { cardEl.classList.remove('wg-highlight'); }, 3000);
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
		const params = ['radius=99999', 'limit=10000'];
		if ($('wg-role').value) params.push('roles=' + encodeURIComponent($('wg-role').value));
		if ($('wg-group').value) params.push('group=' + encodeURIComponent($('wg-group').value));

		return fetch('/api/v3/plugins/waymker-geo/users-near-me?' + params.join('&'), 
			{ credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
			.then(r => r.json())
			.then(data => {
				state.allUsers = data.users || [];
				state.callerLocation = data.callerLocation;

				if (state.callerLocation) {
					state.allUsers.forEach(u => {
						if (typeof u.latitude === 'number' && typeof u.longitude === 'number') {
							u.distance = haversine(state.callerLocation.latitude, state.callerLocation.longitude, u.latitude, u.longitude);
						}
					});
					state.allUsers.sort((a, b) => (a.distance || 999999) - (b.distance || 999999));
				}

				applyFilters();
				fetchGroups();
			})
			.catch(err => {
				console.error('Error:', err);
				$('wg-results-grid').innerHTML = '<div class="alert alert-danger">Could not load nearby members.</div>';
			});
	}

	function fetchGroups() {
		fetch('/api/groups', { credentials: 'same-origin' })
			.then(r => r.json())
			.then(data => {
				state.groupsList = (data.groups || []).filter(g => g && !g.system && !g.hidden);
				const sel = $('wg-group');
				const current = sel.value;
				sel.innerHTML = '<option value="">All groups</option>';
				state.groupsList.forEach(g => {
					const opt = document.createElement('option');
					opt.value = g.name;
					opt.textContent = g.displayName || g.name;
					sel.appendChild(opt);
				});
				sel.value = current;
			})
			.catch(() => {});
	}

	function applyFilters() {
		const q = ($('wg-search').value || '').toLowerCase().trim();
		let users = state.allUsers.slice();

		if (q) {
			users = users.filter(u => {
				const name = (u.username || '').toLowerCase();
				const city = (u.city || '').toLowerCase();
				const hood = (u.neighborhood || '').toLowerCase();
				return name.indexOf(q) !== -1 || city.indexOf(q) !== -1 || hood.indexOf(q) !== -1;
			});
		}

		state.filteredUsers = users;
		$('wg-results-grid').innerHTML = '';
		renderMarkers();
		renderCards();
		$('wg-count-badge').textContent = users.length;
		$('wg-results-info').textContent = users.length + (users.length === 1 ? ' member found' : ' members found');
	}

	function locStr(u) {
		const parts = [];
		if (u.neighborhood) parts.push(u.neighborhood);
		if (u.city) parts.push(u.city);
		if (u.state) parts.push(u.state);
		return parts.join(', ') || u.country || '?';
	}

	function buildCardHtml(u) {
		const txt = (u.username || 'U')[0].toUpperCase();
		const col = ['#0066cc', '#dc143c', '#ff4500', '#28a745', '#ffc107', '#17a2b8'][u.uid % 6];
		const distStr = u.distance ? u.distance.toFixed(1) + ' mi away' : 'N/A';

		return '<div id="wg-user-' + u.uid + '" class="user-card">' +
			'<div class="user-card-image" style="background: ' + col + '; display: flex; align-items: center; justify-content: center;"><span style="font-size: 48px; color: white; font-weight: bold;">' + txt + '</span></div>' +
			'<div class="user-card-body">' +
			'<div class="user-picture" style="background: ' + col + ';">' + txt + '</div>' +
			'<div class="user-info">' +
			'<h4><a href="/user/' + esc(u.userslug) + '">' + esc(u.username) + '</a></h4>' +
			'<div class="user-slug">@' + esc(u.userslug) + '</div>' +
			'<div class="user-status">' + (u.status || 'offline').charAt(0).toUpperCase() + (u.status || 'offline').slice(1) + '</div>' +
			'<div class="user-location">📍 ' + esc(locStr(u)) + '</div>' +
			'<div class="user-distance">' + distStr + '</div>' +
			'<div class="user-stats">' +
			'<div><span class="stat-value">' + (u.reputation || 0) + '</span><span class="stat-label">Reputation</span></div>' +
			'<div><span class="stat-value">' + (u.postcount || 0) + '</span><span class="stat-label">Posts</span></div>' +
			'<div><span class="stat-value">' + (u.followerCount || 0) + '</span><span class="stat-label">Followers</span></div>' +
			'</div>' +
			'<div class="user-actions">' +
			'<a href="/user/' + esc(u.userslug) + '" class="btn btn-primary">View Profile</a>' +
			'</div>' +
			'</div>' +
			'</div>' +
			'</div>';
	}

	function renderCards() {
		let html = '';
		state.filteredUsers.forEach(u => {
			html += buildCardHtml(u);
		});
		if (html === '') {
			html = '<div class="alert alert-info">No members found.</div>';
		}
		$('wg-results-grid').innerHTML = html;
	}

	function init() {
		initMap();

		$('wg-role').addEventListener('change', fetchUsers);
		$('wg-group').addEventListener('change', fetchUsers);
		$('wg-search').addEventListener('input', () => {
			clearTimeout(state.searchTimer);
			state.searchTimer = setTimeout(applyFilters, 200);
		});
		$('wg-reset').addEventListener('click', () => {
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
