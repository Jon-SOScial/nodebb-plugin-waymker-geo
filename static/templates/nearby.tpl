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
	<div id="wg-results-grid" style="display: grid; gap: 20px; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); grid-auto-rows: max-content;"></div>
</div>

<style>
	#wg-results-grid {
		display: grid !important;
		gap: 20px !important;
		grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)) !important;
		grid-auto-rows: max-content !important;
		width: 100% !important;
	}
	.profile-card-cover-container {
		height: auto !important;
		display: flex !important;
		flex-direction: column !important;
		overflow: visible !important;
	}
	.profile-card-cover-container .profile-card-info {
		display: block !important;
		height: auto !important;
		overflow: visible !important;
	}
	.profile-card-cover {
		height: 150px !important;
		min-height: 150px !important;
		overflow: visible !important;
		position: relative !important;
	}
	.profile-card-avatar {
		position: absolute !important;
		bottom: -25px !important;
		left: 15px !important;
		z-index: 10 !important;
	}
	.card-fab {
		position: absolute !important;
		top: 10px !important;
		right: 10px !important;
		z-index: 11 !important;
	}
	.account-stats {
		display: flex !important;
		gap: 15px !important;
		text-align: center !important;
		margin-top: 10px !important;
		padding-top: 10px !important;
		border-top: 1px solid #f0f0f0 !important;
	}
	.account-stats .stat {
		flex: 1 !important;
		font-size: 12px !important;
	}
</style>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.css">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.Default.css">
<script src="https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/leaflet.markercluster.js"></script>

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

		return '<div class="profile-card-cover-container mb-2" style="max-width: 320px; border: 1px solid #e9ecef; border-radius: 4px;">' +
			'<div class="profile-card-cover rounded-top" style="background-image: url(/assets/images/cover-default.png); background-position: 50% 50%; height: auto; min-height: 100px; position: relative;">' +
			'<div class="profile-card-avatar">' +
			'<a href="/user/' + esc(u.userslug) + '">' +
			'<span title="' + esc(u.username) + '" data-uid="' + u.uid + '" class="avatar avatar-rounded" style="--avatar-size: 50px; background-color: ' + col + ';">' + txt + '</span>' +
			'</a>' +
			'</div>' +
			'</div>' +
			'<div class="profile-card-info" style="padding: 15px; padding-top: 50px;">' +
			'<h1 class="fullname" style="margin: 0 0 5px 0; text-align: center;">' + esc(u.username) + '</h1>' +
			'<div style="font-size: 12px; color: #666; text-align: center; margin: 5px 0;">📍 ' + esc(loc) + '</div>' +
			'<div style="font-size: 12px; color: #ff6600; text-align: center; font-weight: 600; margin: 8px 0 12px 0;">' + distStr + '</div>' +
			'<div class="text-center">' +
			'<a component="account/follow" href="#" class="btn btn-success btn-sm hide">Follow</a>' +
			'<a component="account/unfollow" href="#" class="btn btn-warning btn-sm">Unfollow</a>' +
			'<a component="account/chat" href="#" class="btn btn-primary btn-sm">Chat</a>' +
			'</div>' +
			'<div class="account-stats" style="margin-top: 10px;">' +
			'<div class="stat"><div class="human-readable-number" title="' + (u.reputation || 0) + '">' + (u.reputation || 0) + '</div><span class="stat-label">Reputation</span></div>' +
			'<div class="stat"><div class="human-readable-number" title="' + (u.postcount || 0) + '">' + (u.postcount || 0) + '</div><span class="stat-label">Posts</span></div>' +
			'<div class="stat"><div class="human-readable-number" title="' + (u.followerCount || 0) + '">' + (u.followerCount || 0) + '</div><span class="stat-label">Followers</span></div>' +
			'</div>' +
			'</div>' +
			'</div>';
	}

	function renderMarkers() {
		if (!state.map) return;
		state.markerCluster.clearLayers();

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
			marker.bindPopup(buildNativePopupHtml(u), { maxWidth: 350 });
			
			marker.on('click', function() {
				marker.openPopup();
				const cardEl = document.getElementById('wg-user-' + u.uid);
				if (cardEl) {
					document.querySelectorAll('[data-wg-highlight]').forEach(el => {
						el.removeAttribute('data-wg-highlight');
						el.style.boxShadow = '';
					});
					cardEl.setAttribute('data-wg-highlight', 'true');
					cardEl.style.boxShadow = '0 0 0 3px #0066cc';
					cardEl.scrollIntoView({ behavior: 'smooth', block: 'center' });
					setTimeout(() => {
						cardEl.style.boxShadow = '';
						cardEl.removeAttribute('data-wg-highlight');
					}, 3000);
				}
			});

			state.markerCluster.addLayer(marker);
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
		const locParts = [];
		if (u.neighborhood) locParts.push(u.neighborhood);
		if (u.city) locParts.push(u.city);
		if (u.state) locParts.push(u.state);
		const loc = locParts.join(', ') || u.country || '?';

		return '<div id="wg-user-' + u.uid + '" class="profile-card-cover-container mb-2">' +
			'<div class="profile-card-cover rounded-top" style="background-image: url(/assets/images/cover-default.png); background-position: 50% 50%; height: auto; min-height: 150px; position: relative;">' +
			'<div class="profile-card-avatar"><a href="/user/' + esc(u.userslug) + '"><span title="' + esc(u.username) + '" data-uid="' + u.uid + '" class="avatar avatar-rounded" style="--avatar-size: 50px; background-color: ' + col + ';">' + txt + '</span></a></div>' +
			'<div class="dropdown card-fab">' +
			'<button type="button" class="btn btn-light btn-sm rounded-circle fab dropdown-toggle" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false"><i class="fa fa-ellipsis-v"></i></button>' +
			'<ul class="dropdown-menu dropdown-menu-end p-1">' +
			'<li><a class="dropdown-item rounded-1" component="account/chat" href="#">Continue chat with ' + esc(u.username) + '</a></li>' +
			'<li class="dropdown-divider"></li>' +
			'<li><a class="dropdown-item rounded-1" href="/user/' + esc(u.userslug) + '">Profile</a></li>' +
			'<li class="dropdown-divider"></li>' +
			'<li><a class="dropdown-item rounded-1" href="/user/' + esc(u.userslug) + '/following">Following</a></li>' +
			'<li><a class="dropdown-item rounded-1" href="/user/' + esc(u.userslug) + '/followers">Followers</a></li>' +
			'<li class="dropdown-divider"></li>' +
			'<li><a class="dropdown-item rounded-1" href="/user/' + esc(u.userslug) + '/topics">Topics</a></li>' +
			'<li><a class="dropdown-item rounded-1" href="/user/' + esc(u.userslug) + '/posts">Posts</a></li>' +
			'<li><a class="dropdown-item rounded-1" href="/user/' + esc(u.userslug) + '/groups">Groups</a></li>' +
			'</ul></div></div>' +
			'<div class="profile-card-info" style="padding: 15px; padding-top: 50px;">' +
			'<h1 class="fullname" style="margin: 0 0 5px 0;">' + esc(u.username) + '</h1>' +
			'<div style="font-size: 12px; color: #666; margin: 5px 0;">📍 ' + esc(loc) + '</div>' +
			'<div style="font-size: 12px; color: #ff6600; font-weight: 600; margin: 8px 0 12px 0;">' + distStr + '</div>' +
			'<div class="text-center">' +
			'<a component="account/follow" href="#" class="btn btn-success btn-sm hide">Follow</a>' +
			'<a component="account/unfollow" href="#" class="btn btn-warning btn-sm">Unfollow</a>' +
			'<a component="account/chat" href="#" class="btn btn-primary btn-sm">Chat</a>' +
			'</div>' +
			'<div class="account-stats">' +
			'<div class="stat"><div class="human-readable-number" title="' + (u.reputation || 0) + '">' + (u.reputation || 0) + '</div><span class="stat-label">Reputation</span></div>' +
			'<div class="stat"><div class="human-readable-number" title="' + (u.postcount || 0) + '">' + (u.postcount || 0) + '</div><span class="stat-label">Posts</span></div>' +
			'<div class="stat"><div class="human-readable-number" title="' + (u.followerCount || 0) + '">' + (u.followerCount || 0) + '</div><span class="stat-label">Followers</span></div>' +
			'</div><div class="text-center profile-meta"></div>' +
			'</div></div>';
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
