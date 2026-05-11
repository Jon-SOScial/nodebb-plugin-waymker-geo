<!-- Leaflet & MarkerCluster assets -->
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" crossorigin=""/>
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.css"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet.markercluster@1.5.3/dist/MarkerCluster.Default.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" crossorigin=""></script>
<script src="https://unpkg.com/leaflet.markercluster@1.5.3/dist/leaflet.markercluster.js"></script>

<style>
	/* ============================================================
	   WAYMKER-GEO :: NEARBY DIRECTORY (Phase 4)
	   ============================================================ */

	.wg-page {
		max-width: 1400px;
		margin: 0 auto;
		padding: 16px;
		font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
	}

	/* ---------- Header ---------- */
	.wg-header {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 12px;
		margin-bottom: 12px;
		flex-wrap: wrap;
	}
	.wg-title {
		margin: 0;
		font-size: 22px;
		font-weight: 700;
		color: #1a1a1a;
		display: flex;
		align-items: center;
		gap: 8px;
	}
	.wg-title-icon {
		display: inline-block;
		width: 28px;
		height: 28px;
		background: linear-gradient(135deg, #0066cc 0%, #00aaff 100%);
		border-radius: 50%;
		position: relative;
	}
	.wg-title-icon::after {
		content: '';
		position: absolute;
		top: 50%; left: 50%;
		width: 10px; height: 10px;
		background: #fff;
		border-radius: 50%;
		transform: translate(-50%, -50%);
	}
	.wg-count-badge {
		background: #0066cc;
		color: #fff;
		font-size: 12px;
		font-weight: 600;
		padding: 4px 10px;
		border-radius: 12px;
	}

	/* ---------- Compact Filter Bar ---------- */
	.wg-filter-bar {
		display: flex;
		gap: 8px;
		align-items: center;
		background: #fff;
		border: 1px solid #e0e0e0;
		border-radius: 10px;
		padding: 8px;
		margin-bottom: 12px;
		box-shadow: 0 1px 3px rgba(0,0,0,0.04);
		flex-wrap: wrap;
	}
	.wg-search-wrap {
		flex: 2 1 220px;
		min-width: 180px;
		position: relative;
	}
	.wg-search-wrap::before {
		content: '';
		position: absolute;
		left: 10px;
		top: 50%;
		width: 14px; height: 14px;
		border: 2px solid #888;
		border-radius: 50%;
		transform: translateY(-60%);
		pointer-events: none;
	}
	.wg-search-wrap::after {
		content: '';
		position: absolute;
		left: 21px;
		top: 50%;
		width: 7px; height: 2px;
		background: #888;
		transform: translateY(2px) rotate(45deg);
		transform-origin: left center;
		pointer-events: none;
	}
	.wg-search-input {
		width: 100%;
		padding: 7px 10px 7px 32px;
		border: 1px solid #d0d0d0;
		border-radius: 6px;
		font-size: 13px;
		outline: none;
		transition: border-color 0.15s, box-shadow 0.15s;
		background: #fafafa;
	}
	.wg-search-input:focus {
		border-color: #0066cc;
		background: #fff;
		box-shadow: 0 0 0 3px rgba(0,102,204,0.12);
	}
	.wg-select {
		padding: 7px 10px;
		border: 1px solid #d0d0d0;
		border-radius: 6px;
		font-size: 13px;
		background: #fafafa;
		outline: none;
		cursor: pointer;
		flex: 1 1 110px;
		min-width: 100px;
		transition: border-color 0.15s, box-shadow 0.15s;
	}
	.wg-select:focus {
		border-color: #0066cc;
		background: #fff;
		box-shadow: 0 0 0 3px rgba(0,102,204,0.12);
	}
	.wg-reset-btn {
		padding: 7px 14px;
		background: transparent;
		color: #666;
		border: 1px solid #d0d0d0;
		border-radius: 6px;
		font-size: 12px;
		font-weight: 500;
		cursor: pointer;
		transition: all 0.15s;
		flex: 0 0 auto;
	}
	.wg-reset-btn:hover {
		background: #f0f0f0;
		color: #333;
		border-color: #aaa;
	}

	/* ---------- Map ---------- */
	.wg-map-wrap {
		position: relative;
		height: 480px;
		border-radius: 10px;
		overflow: hidden;
		border: 1px solid #e0e0e0;
		box-shadow: 0 1px 3px rgba(0,0,0,0.04);
		margin-bottom: 16px;
	}
	#wg-map {
		width: 100%;
		height: 100%;
	}
	.wg-map-overlay-btn {
		position: absolute;
		z-index: 1000;
		background: #fff;
		border: 1px solid #ccc;
		border-radius: 6px;
		padding: 6px 10px;
		font-size: 12px;
		font-weight: 500;
		cursor: pointer;
		box-shadow: 0 1px 3px rgba(0,0,0,0.2);
		transition: background 0.15s;
	}
	.wg-map-overlay-btn:hover {
		background: #f5f5f5;
	}
	.wg-fullscreen-btn {
		top: 10px;
		right: 10px;
	}
	.wg-mylocation-btn {
		top: 50px;
		right: 10px;
	}
	.wg-layer-switcher {
		bottom: 10px;
		right: 10px;
		display: flex;
		gap: 4px;
		flex-direction: column;
	}
	.wg-layer-switcher button {
		background: #fff;
		border: 1px solid #ccc;
		border-radius: 4px;
		padding: 4px 8px;
		font-size: 11px;
		cursor: pointer;
	}
	.wg-layer-switcher button.active {
		background: #0066cc;
		color: #fff;
		border-color: #0066cc;
	}

	/* ---------- Results Panel ---------- */
	.wg-results-header {
		display: flex;
		justify-content: space-between;
		align-items: center;
		margin-bottom: 10px;
		padding: 0 4px;
	}
	.wg-results-title {
		font-size: 14px;
		font-weight: 600;
		color: #333;
		margin: 0;
	}
	.wg-results-info {
		font-size: 12px;
		color: #666;
	}
	.wg-results-grid {
		display: grid;
		grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
		gap: 12px;
		margin-bottom: 16px;
	}

	/* ---------- User Card ---------- */
	.wg-card {
		background: #fff;
		border: 1px solid #e0e0e0;
		border-radius: 10px;
		padding: 14px;
		cursor: pointer;
		transition: transform 0.15s, box-shadow 0.15s, border-color 0.15s;
		position: relative;
		display: flex;
		flex-direction: column;
		min-height: 180px;
	}
	.wg-card:hover {
		transform: translateY(-2px);
		box-shadow: 0 4px 12px rgba(0,0,0,0.08);
		border-color: #0066cc;
	}
	.wg-card-top {
		display: flex;
		gap: 12px;
		align-items: flex-start;
	}
	.wg-avatar {
		width: 48px;
		height: 48px;
		border-radius: 50%;
		flex-shrink: 0;
		background: linear-gradient(135deg, #0066cc 0%, #00aaff 100%);
		display: flex;
		align-items: center;
		justify-content: center;
		color: #fff;
		font-weight: 700;
		font-size: 18px;
		overflow: hidden;
	}
	.wg-avatar img {
		width: 100%;
		height: 100%;
		object-fit: cover;
	}
	.wg-card-info {
		flex: 1;
		min-width: 0;
	}
	.wg-username-link {
		font-size: 15px;
		font-weight: 600;
		color: #0066cc;
		text-decoration: none;
		display: inline-block;
		max-width: calc(100% - 30px);
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
		vertical-align: middle;
	}
	.wg-username-link:hover {
		text-decoration: underline;
	}
	.wg-location-line {
		font-size: 12px;
		color: #666;
		margin-top: 2px;
		display: flex;
		align-items: center;
		gap: 4px;
	}
	.wg-distance-pill {
		display: inline-block;
		background: #f0f8ff;
		color: #0066cc;
		font-size: 11px;
		font-weight: 600;
		padding: 2px 8px;
		border-radius: 10px;
		margin-top: 6px;
	}
	.wg-approx-badge {
		display: inline-block;
		background: #fff3e0;
		color: #ff6600;
		font-size: 10px;
		font-weight: 600;
		padding: 2px 6px;
		border-radius: 8px;
		margin-top: 6px;
		margin-left: 4px;
	}

	/* Three-dot menu */
	.wg-menu-btn {
		position: absolute;
		top: 10px;
		right: 10px;
		width: 26px;
		height: 26px;
		border-radius: 50%;
		background: transparent;
		border: none;
		cursor: pointer;
		display: flex;
		align-items: center;
		justify-content: center;
		color: #999;
		font-size: 18px;
		line-height: 1;
		transition: background 0.15s, color 0.15s;
	}
	.wg-menu-btn:hover {
		background: #f0f0f0;
		color: #333;
	}
	.wg-menu-dropdown {
		position: absolute;
		top: 38px;
		right: 10px;
		background: #fff;
		border: 1px solid #e0e0e0;
		border-radius: 8px;
		box-shadow: 0 4px 12px rgba(0,0,0,0.12);
		z-index: 100;
		min-width: 160px;
		overflow: hidden;
	}
	.wg-menu-dropdown button {
		display: block;
		width: 100%;
		text-align: left;
		padding: 10px 14px;
		background: transparent;
		border: none;
		font-size: 13px;
		color: #333;
		cursor: pointer;
		transition: background 0.15s;
	}
	.wg-menu-dropdown button:hover {
		background: #f5f5f5;
	}

	/* Roles row */
	.wg-roles-row {
		margin-top: 8px;
		display: flex;
		flex-wrap: wrap;
		gap: 4px;
	}
	.wg-role-badge {
		display: inline-block;
		background: #e8f0fe;
		color: #0066cc;
		font-size: 10px;
		font-weight: 600;
		padding: 2px 7px;
		border-radius: 8px;
		text-transform: uppercase;
		letter-spacing: 0.3px;
	}
	.wg-role-badge.admin { background: #fce4ec; color: #c2185b; }
	.wg-role-badge.mod   { background: #e8f5e9; color: #2e7d32; }

	/* Stats row */
	.wg-stats-row {
		display: flex;
		justify-content: space-around;
		margin-top: 10px;
		padding: 8px 0;
		border-top: 1px solid #f0f0f0;
		border-bottom: 1px solid #f0f0f0;
	}
	.wg-stat {
		text-align: center;
		flex: 1;
	}
	.wg-stat-num {
		font-size: 14px;
		font-weight: 700;
		color: #333;
		line-height: 1;
	}
	.wg-stat-label {
		font-size: 10px;
		color: #888;
		text-transform: uppercase;
		letter-spacing: 0.3px;
		margin-top: 3px;
	}

	/* Action buttons */
	.wg-actions {
		display: flex;
		gap: 6px;
		margin-top: 10px;
	}
	.wg-action-btn {
		flex: 1;
		padding: 7px 10px;
		border-radius: 6px;
		font-size: 12px;
		font-weight: 600;
		cursor: pointer;
		border: none;
		transition: all 0.15s;
		display: flex;
		align-items: center;
		justify-content: center;
		gap: 4px;
	}
	.wg-follow-btn {
		background: #0066cc;
		color: #fff;
	}
	.wg-follow-btn:hover {
		background: #0052a3;
	}
	.wg-follow-btn.following {
		background: #e0e0e0;
		color: #555;
	}
	.wg-follow-btn.following:hover {
		background: #d0d0d0;
	}
	.wg-chat-btn {
		background: #f0f0f0;
		color: #333;
	}
	.wg-chat-btn:hover {
		background: #e0e0e0;
	}

	/* ---------- Loading / Empty States ---------- */
	.wg-loading {
		text-align: center;
		padding: 24px;
		color: #888;
		font-size: 13px;
	}
	.wg-spinner {
		display: inline-block;
		width: 24px;
		height: 24px;
		border: 3px solid #e0e0e0;
		border-top-color: #0066cc;
		border-radius: 50%;
		animation: wg-spin 0.8s linear infinite;
	}
	@keyframes wg-spin {
		to { transform: rotate(360deg); }
	}
	.wg-empty {
		grid-column: 1 / -1;
		text-align: center;
		padding: 40px 20px;
		color: #888;
		font-size: 14px;
		background: #fafafa;
		border: 1px dashed #ddd;
		border-radius: 10px;
	}
	.wg-empty-icon {
		font-size: 36px;
		margin-bottom: 8px;
		opacity: 0.4;
	}

	/* ---------- Footer ---------- */
	.wg-footer {
		display: grid;
		grid-template-columns: 1fr 1fr 1fr;
		gap: 12px;
		margin-top: 16px;
		padding-top: 16px;
		border-top: 1px solid #e8e8e8;
	}
	.wg-footer-card {
		background: #fff;
		border: 1px solid #e0e0e0;
		border-radius: 10px;
		padding: 14px;
	}
	.wg-footer-card h4 {
		margin: 0 0 10px 0;
		font-size: 13px;
		font-weight: 700;
		color: #333;
		text-transform: uppercase;
		letter-spacing: 0.5px;
		display: flex;
		align-items: center;
		gap: 6px;
	}
	.wg-footer-stat-row {
		display: flex;
		justify-content: space-between;
		padding: 4px 0;
		font-size: 13px;
	}
	.wg-footer-stat-row .label {
		color: #666;
	}
	.wg-footer-stat-row .value {
		font-weight: 600;
		color: #0066cc;
	}
	.wg-footer-link {
		display: block;
		padding: 6px 0;
		color: #0066cc;
		text-decoration: none;
		font-size: 13px;
		transition: color 0.15s;
	}
	.wg-footer-link:hover {
		color: #0052a3;
		text-decoration: underline;
	}
	.wg-legend-item {
		display: flex;
		align-items: center;
		gap: 8px;
		padding: 4px 0;
		font-size: 12px;
		color: #555;
	}
	.wg-legend-dot {
		width: 12px;
		height: 12px;
		border-radius: 50%;
		flex-shrink: 0;
	}

	/* ---------- Cluster styles ---------- */
	.marker-cluster {
		background-clip: padding-box;
		border-radius: 50%;
		font-weight: 900 !important;
	}
	.marker-cluster div {
		font-weight: 900 !important;
		color: #fff !important;
		text-shadow: 0 1px 2px rgba(0,0,0,0.3);
	}

	/* ---------- Map popup (rich card) ---------- */
	.leaflet-popup.wg-marker-popup .leaflet-popup-content-wrapper {
		border-radius: 10px;
		box-shadow: 0 4px 16px rgba(0,0,0,0.18);
		padding: 0;
	}
	.leaflet-popup.wg-marker-popup .leaflet-popup-content {
		margin: 12px 14px;
		font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
		line-height: 1.35;
	}
	.wg-popup-card {
		min-width: 220px;
	}
	.wg-popup-top {
		display: flex;
		gap: 10px;
		align-items: flex-start;
	}
	.wg-popup-avatar {
		width: 40px;
		height: 40px;
		font-size: 16px;
	}
	.wg-popup-info {
		flex: 1;
		min-width: 0;
	}
	.wg-popup-info .wg-username-link {
		font-size: 14px;
	}
	.wg-popup-info .wg-location-line {
		font-size: 11px;
	}
	.wg-popup-card .wg-stats-row {
		margin-top: 8px;
		padding: 6px 0;
	}
	.wg-popup-card .wg-stat-num { font-size: 13px; }
	.wg-popup-card .wg-stat-label { font-size: 9px; }
	.wg-popup-card .wg-actions { margin-top: 8px; }
	.wg-popup-card .wg-action-btn { padding: 6px 8px; font-size: 11px; }

	/* ---------- Responsive ---------- */
	@media (max-width: 768px) {
		.wg-page { padding: 10px; }
		.wg-title { font-size: 18px; }
		.wg-filter-bar { padding: 6px; gap: 6px; }
		.wg-search-wrap { flex: 1 1 100%; }
		.wg-select { flex: 1 1 calc(50% - 4px); min-width: 0; }
		.wg-reset-btn { flex: 1 1 100%; }
		.wg-map-wrap { height: 360px; }
		.wg-results-grid { grid-template-columns: 1fr; }
		.wg-footer { grid-template-columns: 1fr; }
	}
</style>

<div class="wg-page">

	<!-- Header -->
	<div class="wg-header">
		<h1 class="wg-title">
			<span class="wg-title-icon"></span>
			Nearby Members
			<span class="wg-count-badge" id="wg-count-badge">0</span>
		</h1>
		<a href="/users" class="wg-footer-link" style="font-size:13px;">← All Members</a>
	</div>

	<!-- Compact Filter Bar -->
	<div class="wg-filter-bar">
		<div class="wg-search-wrap">
			<input type="text" id="wg-search" class="wg-search-input" placeholder="Search username..." autocomplete="off"/>
		</div>
		<select id="wg-role" class="wg-select">
			<option value="">All roles</option>
			<option value="administrator">Admins</option>
			<option value="moderator">Mods</option>
			<option value="user">Members</option>
		</select>
		<select id="wg-group" class="wg-select">
			<option value="">All groups</option>
		</select>
		<button id="wg-reset" class="wg-reset-btn">Reset</button>
	</div>

	<!-- Map -->
	<div class="wg-map-wrap">
		<div id="wg-map"></div>
		<button id="wg-fullscreen" class="wg-map-overlay-btn wg-fullscreen-btn" title="Toggle fullscreen">⛶</button>
		<button id="wg-mylocation" class="wg-map-overlay-btn wg-mylocation-btn" title="Center on me">⊙</button>
		<div class="wg-layer-switcher">
			<button data-layer="osm" class="active">Street</button>
			<button data-layer="sat">Satellite</button>
			<button data-layer="light">Light</button>
		</div>
	</div>

	<!-- Results Header -->
	<div class="wg-results-header">
		<h3 class="wg-results-title">Members</h3>
		<span class="wg-results-info" id="wg-results-info">Loading...</span>
	</div>

	<!-- Results Grid -->
	<div class="wg-results-grid" id="wg-results-grid">
		<div class="wg-loading"><div class="wg-spinner"></div></div>
	</div>

	<!-- Infinite scroll sentinel + loader -->
	<div id="wg-scroll-sentinel" style="height:1px;"></div>
	<div id="wg-load-more-indicator" class="wg-loading" style="display:none;">
		<div class="wg-spinner"></div>
		<div style="margin-top:6px;">Loading more...</div>
	</div>

	<!-- Footer -->
	<div class="wg-footer">
		<div class="wg-footer-card">
			<h4>📊 Community Stats</h4>
			<div class="wg-footer-stat-row">
				<span class="label">Members nearby</span>
				<span class="value" id="wg-stat-nearby">—</span>
			</div>
			<div class="wg-footer-stat-row">
				<span class="label">Groups represented</span>
				<span class="value" id="wg-stat-groups">—</span>
			</div>
		</div>
		<div class="wg-footer-card">
			<h4>🔗 Quick Links</h4>
			<a href="/groups" class="wg-footer-link">Browse Groups</a>
			<a href="/users" class="wg-footer-link">All Members</a>
			<a href="/me/edit" class="wg-footer-link">Update My Location</a>
			<a href="/recent" class="wg-footer-link">Recent Activity</a>
		</div>
		<div class="wg-footer-card">
			<h4>🗺️ Map Legend</h4>
			<div class="wg-legend-item">
				<span class="wg-legend-dot" style="background:#0066cc;border:2px solid #000;"></span>
				Your location
			</div>
			<div class="wg-legend-item">
				<span class="wg-legend-dot" style="background:#dc143c;"></span>
				User (exact location)
			</div>
			<div class="wg-legend-item">
				<span class="wg-legend-dot" style="background:#ff4500;"></span>
				User (approximate)
			</div>
			<div class="wg-legend-item" style="margin-top:6px;font-size:11px;color:#888;">
				Tip: Click a card to center the map.
			</div>
		</div>
	</div>

</div>

<script>
(function () {
	'use strict';

	// ============================================================
	// STATE
	// ============================================================
	var state = {
		allUsers: [],          // full response from API
		filteredUsers: [],     // after client filters (search)
		visibleCount: 0,       // how many cards rendered
		pageSize: 20,
		isPrivileged: false,
		callerLocation: null,
		groupsList: [],
		map: null,
		baseLayers: {},
		currentLayer: 'osm',
		markerCluster: null,
		markerMap: {},         // uid -> marker
		callerMarker: null,
		searchDebounceTimer: null,
		openMenuUid: null,
		followingSet: {},      // uid -> true (best-effort cache)
	};

	// ============================================================
	// UTILS
	// ============================================================
	function $(id) { return document.getElementById(id); }
	function escapeHtml(s) {
		if (s === null || s === undefined) return '';
		return String(s).replace(/[&<>"']/g, function (c) {
			return { '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[c];
		});
	}
	function getCSRF() {
		return (typeof config !== 'undefined' && config.csrf_token) ? config.csrf_token : '';
	}
	function debounce(fn, ms) {
		return function () {
			var args = arguments, ctx = this;
			clearTimeout(state.searchDebounceTimer);
			state.searchDebounceTimer = setTimeout(function () { fn.apply(ctx, args); }, ms);
		};
	}

	// ============================================================
	// API
	// ============================================================
	function fetchUsersNearMe() {
		var role = $('wg-role').value || '';
		var group = $('wg-group').value || '';

		// No radius filter — request a very large radius so server returns every
		// locatable user. The API still sorts results by Haversine distance,
		// so cards/markers naturally appear nearest-first.
		var params = ['radius=99999', 'limit=10000'];
		if (role) params.push('roles=' + encodeURIComponent(role));
		if (group) params.push('group=' + encodeURIComponent(group));

		var url = '/api/v3/plugins/waymker-geo/users-near-me?' + params.join('&');

		$('wg-results-info').textContent = 'Loading...';
		$('wg-results-grid').innerHTML = '<div class="wg-loading"><div class="wg-spinner"></div></div>';

		return fetch(url, { credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
			.then(function (r) { return r.json(); })
			.then(function (data) {
				var payload = (data && data.response) ? data.response : data;
				state.allUsers = (payload && payload.users) ? payload.users : [];
				state.isPrivileged = !!(payload && payload.isPrivileged);
				state.callerLocation = (payload && payload.callerLocation) ? payload.callerLocation : null;
				applyClientFilters();
				renderMarkers();
				updateFooterStats();
			})
			.catch(function (err) {
				console.error('[waymker-geo] fetch failed', err);
				$('wg-results-grid').innerHTML = '<div class="wg-empty"><div class="wg-empty-icon">⚠️</div>Could not load nearby members. Try again.</div>';
				$('wg-results-info').textContent = '';
			});
	}

	function fetchGroupsList() {
		return fetch('/api/groups', { credentials: 'same-origin', headers: { 'Accept': 'application/json' } })
			.then(function (r) { return r.json(); })
			.then(function (data) {
				var groups = (data && data.groups) ? data.groups : [];
				state.groupsList = groups.filter(function (g) {
					return g && g.name && !g.system && !g.hidden && g.name !== 'registered-users';
				});
				populateGroupDropdown();
			})
			.catch(function () { /* non-fatal */ });
	}

	function populateGroupDropdown() {
		var sel = $('wg-group');
		if (!sel) return;
		var current = sel.value;
		sel.innerHTML = '<option value="">All groups</option>';
		state.groupsList.forEach(function (g) {
			var opt = document.createElement('option');
			opt.value = g.name;
			opt.textContent = g.displayName || g.name;
			sel.appendChild(opt);
		});
		if (current) sel.value = current;
	}

	// ============================================================
	// CLIENT FILTERING (search input)
	// ============================================================
	function applyClientFilters() {
		var q = ($('wg-search').value || '').trim().toLowerCase();
		var users = state.allUsers.slice();
		if (q) {
			users = users.filter(function (u) {
				var name = (u.username || '').toLowerCase();
				var city = (u.city || '').toLowerCase();
				return name.indexOf(q) !== -1 || city.indexOf(q) !== -1;
			});
		}
		state.filteredUsers = users;
		state.visibleCount = 0;
		$('wg-results-grid').innerHTML = '';
		renderNextBatch();
		$('wg-count-badge').textContent = users.length;
		$('wg-results-info').textContent = users.length + (users.length === 1 ? ' member found' : ' members found');
	}

	// ============================================================
	// CARD RENDERING
	// ============================================================
	function buildAvatarHtml(user) {
		if (user.picture) {
			return '<img src="' + escapeHtml(user.picture) + '" alt="' + escapeHtml(user.username) + '" onerror="this.style.display=\'none\';this.parentNode.textContent=\'' + escapeHtml((user.username || '?').charAt(0).toUpperCase()) + '\';"/>';
		}
		var letter = (user.username || '?').charAt(0).toUpperCase();
		return escapeHtml(letter);
	}

	function buildLocationLine(user) {
		var parts = [];
		if (user.neighborhood) parts.push(user.neighborhood);
		if (user.city) parts.push(user.city);
		if (user.state) parts.push(user.state);
		return parts.length ? parts.join(', ') : 'Location unknown';
	}

	function buildRolesHtml(user) {
		if (!user.roles || !user.roles.length) return '';
		var html = '<div class="wg-roles-row">';
		user.roles.forEach(function (r) {
			var name = (r && (r.displayName || r.name)) || '';
			if (!name) return;
			var lname = name.toLowerCase();
			var cls = 'wg-role-badge';
			if (lname.indexOf('admin') !== -1) cls += ' admin';
			else if (lname.indexOf('moderator') !== -1 || lname.indexOf('mod') !== -1) cls += ' mod';
			html += '<span class="' + cls + '">' + escapeHtml(name) + '</span>';
		});
		html += '</div>';
		return html;
	}

	function buildCardHtml(user) {
		var distanceStr = (typeof user.distance === 'number') ? user.distance.toFixed(1) + ' mi away' : '';
		var approxBadge = user.isApproximate ? '<span class="wg-approx-badge">~ ' + escapeHtml(user.approximateLevel || 'approx') + '</span>' : '';
		var followLabel = state.followingSet[user.uid] ? '✓ Following' : '+ Follow';
		var followClass = state.followingSet[user.uid] ? 'wg-action-btn wg-follow-btn following' : 'wg-action-btn wg-follow-btn';

		var html = '';
		html += '<div class="wg-card" data-uid="' + user.uid + '" data-userslug="' + escapeHtml(user.userslug || '') + '">';

			// menu button + dropdown
			html += '<button class="wg-menu-btn" data-menu-uid="' + user.uid + '" aria-label="Options">⋯</button>';

			// top row: avatar + info
			html += '<div class="wg-card-top">';
				html += '<div class="wg-avatar">' + buildAvatarHtml(user) + '</div>';
				html += '<div class="wg-card-info">';
					html += '<a class="wg-username-link" href="/user/' + escapeHtml(user.userslug || '') + '" data-stop="1">' + escapeHtml(user.username || 'Unknown') + '</a>';
					html += '<div class="wg-location-line">📍 ' + escapeHtml(buildLocationLine(user)) + '</div>';
					if (distanceStr) {
						html += '<span class="wg-distance-pill">' + escapeHtml(distanceStr) + '</span>' + approxBadge;
					}
				html += '</div>';
			html += '</div>';

			// roles
			html += buildRolesHtml(user);

			// stats row
			html += '<div class="wg-stats-row">';
				html += '<div class="wg-stat"><div class="wg-stat-num">' + (user.reputation || 0) + '</div><div class="wg-stat-label">Rep</div></div>';
				html += '<div class="wg-stat"><div class="wg-stat-num">' + (user.postcount || 0) + '</div><div class="wg-stat-label">Posts</div></div>';
				html += '<div class="wg-stat"><div class="wg-stat-num">' + (user.followerCount || 0) + '</div><div class="wg-stat-label">Followers</div></div>';
			html += '</div>';

			// actions
			html += '<div class="wg-actions">';
				html += '<button class="' + followClass + '" data-follow-uid="' + user.uid + '">' + followLabel + '</button>';
				html += '<button class="wg-action-btn wg-chat-btn" data-chat-uid="' + user.uid + '">💬 Chat</button>';
			html += '</div>';

		html += '</div>';
		return html;
	}

	// Rich popup card shown when a map marker is clicked.
	// Same info density as the bottom cards, condensed for the popup width.
	function buildPopupHtml(user) {
		var distanceStr = (typeof user.distance === 'number') ? user.distance.toFixed(1) + ' mi away' : '';
		var approxBadge = user.isApproximate ? '<span class="wg-approx-badge">~ ' + escapeHtml(user.approximateLevel || 'approx') + '</span>' : '';
		var followLabel = state.followingSet[user.uid] ? '\u2713 Following' : '+ Follow';
		var followClass = state.followingSet[user.uid] ? 'wg-action-btn wg-follow-btn following' : 'wg-action-btn wg-follow-btn';

		var html = '';
		html += '<div class="wg-popup-card">';
			html += '<div class="wg-popup-top">';
				html += '<div class="wg-avatar wg-popup-avatar">' + buildAvatarHtml(user) + '</div>';
				html += '<div class="wg-popup-info">';
					html += '<a class="wg-username-link" href="/user/' + escapeHtml(user.userslug || '') + '">' + escapeHtml(user.username || 'Unknown') + '</a>';
					html += '<div class="wg-location-line">\ud83d\udccd ' + escapeHtml(buildLocationLine(user)) + '</div>';
					if (distanceStr) {
						html += '<span class="wg-distance-pill">' + escapeHtml(distanceStr) + '</span>' + approxBadge;
					}
				html += '</div>';
			html += '</div>';

			html += buildRolesHtml(user);

			html += '<div class="wg-stats-row">';
				html += '<div class="wg-stat"><div class="wg-stat-num">' + (user.reputation || 0) + '</div><div class="wg-stat-label">Rep</div></div>';
				html += '<div class="wg-stat"><div class="wg-stat-num">' + (user.postcount || 0) + '</div><div class="wg-stat-label">Posts</div></div>';
				html += '<div class="wg-stat"><div class="wg-stat-num">' + (user.followerCount || 0) + '</div><div class="wg-stat-label">Followers</div></div>';
			html += '</div>';

			html += '<div class="wg-actions">';
				html += '<button class="' + followClass + '" data-popup-follow data-follow-uid="' + user.uid + '">' + followLabel + '</button>';
				html += '<button class="wg-action-btn wg-chat-btn" data-popup-chat data-chat-uid="' + user.uid + '">\ud83d\udcac Chat</button>';
			html += '</div>';
		html += '</div>';
		return html;
	}

	function renderNextBatch() {
		var grid = $('wg-results-grid');
		var users = state.filteredUsers;

		if (state.visibleCount === 0 && users.length === 0) {
			grid.innerHTML = '<div class="wg-empty"><div class="wg-empty-icon">\ud83d\udd0d</div>No members found matching your filters.<br/><small>Try clearing filters or check your search term.</small></div>';
			$('wg-load-more-indicator').style.display = 'none';
			return;
		}

		var end = Math.min(state.visibleCount + state.pageSize, users.length);
		var chunk = '';
		for (var i = state.visibleCount; i < end; i++) {
			chunk += buildCardHtml(users[i]);
		}
		grid.insertAdjacentHTML('beforeend', chunk);
		state.visibleCount = end;

		if (state.visibleCount >= users.length) {
			$('wg-load-more-indicator').style.display = 'none';
		} else {
			$('wg-load-more-indicator').style.display = 'block';
		}
	}

	// ============================================================
	// MAP
	// ============================================================
	function initMap() {
		state.map = L.map('wg-map', {
			zoomControl: true,
			attributionControl: true,
		}).setView([39.5, -98.35], 4); // continental US default

		// Build tile URLs piece-by-piece; literal Leaflet placeholders would be stripped by Dust.js
		var lb = '\x7b', rb = '\x7d';
		var osmUrl = 'https://\x7bs\x7d.tile.openstreetmap.org/' + lb + 'z' + rb + '/' + lb + 'x' + rb + '/' + lb + 'y' + rb + '.png';
		var satUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/' + lb + 'z' + rb + '/' + lb + 'y' + rb + '/' + lb + 'x' + rb;
		var lightUrl = 'https://\x7bs\x7d.basemaps.cartocdn.com/light_all/' + lb + 'z' + rb + '/' + lb + 'x' + rb + '/' + lb + 'y' + rb + '.png';

		state.baseLayers.osm = L.tileLayer(osmUrl, { maxZoom: 19, attribution: '© OpenStreetMap' });
		state.baseLayers.sat = L.tileLayer(satUrl, { maxZoom: 19, attribution: '© Esri' });
		state.baseLayers.light = L.tileLayer(lightUrl, { maxZoom: 19, attribution: '© CartoDB' });

		state.baseLayers.osm.addTo(state.map);

		state.markerCluster = L.markerClusterGroup({
			iconCreateFunction: function (cluster) {
				var n = cluster.getChildCount();
				var size = 'small', bg = '#4caf50';
				if (n >= 10) { size = 'medium'; bg = '#ff9800'; }
				if (n >= 50) { size = 'large'; bg = '#f44336'; }
				var html = '<div style="background:' + bg + ';width:36px;height:36px;border-radius:50%;display:flex;align-items:center;justify-content:center;color:#fff;font-weight:900;font-size:14px;border:3px solid rgba(255,255,255,0.85);box-shadow:0 2px 6px rgba(0,0,0,0.3);">' + n + '</div>';
				return L.divIcon({ html: html, className: 'marker-cluster marker-cluster-' + size, iconSize: L.point(36, 36) });
			},
		});
		state.map.addLayer(state.markerCluster);

		// Layer switcher
		var switcher = document.querySelectorAll('.wg-layer-switcher button');
		switcher.forEach(function (btn) {
			btn.addEventListener('click', function () {
				var key = btn.getAttribute('data-layer');
				if (!state.baseLayers[key] || state.currentLayer === key) return;
				state.map.removeLayer(state.baseLayers[state.currentLayer]);
				state.map.addLayer(state.baseLayers[key]);
				state.currentLayer = key;
				switcher.forEach(function (b) { b.classList.toggle('active', b === btn); });
			});
		});

		// Fullscreen
		$('wg-fullscreen').addEventListener('click', function () {
			var wrap = document.querySelector('.wg-map-wrap');
			if (!document.fullscreenElement) {
				if (wrap.requestFullscreen) wrap.requestFullscreen();
				else if (wrap.webkitRequestFullscreen) wrap.webkitRequestFullscreen();
			} else {
				if (document.exitFullscreen) document.exitFullscreen();
				else if (document.webkitExitFullscreen) document.webkitExitFullscreen();
			}
			setTimeout(function () { state.map.invalidateSize(); }, 250);
		});

		// My location
		$('wg-mylocation').addEventListener('click', function () {
			if (state.callerLocation && state.callerLocation.latitude) {
				state.map.flyTo([state.callerLocation.latitude, state.callerLocation.longitude], 12);
			}
		});
	}

	function renderMarkers() {
		if (!state.map || !state.markerCluster) return;
		state.markerCluster.clearLayers();
		state.markerMap = {};
		if (state.callerMarker) {
			state.map.removeLayer(state.callerMarker);
			state.callerMarker = null;
		}

		// Caller marker
		if (state.callerLocation && state.callerLocation.latitude) {
			state.callerMarker = L.circleMarker(
				[state.callerLocation.latitude, state.callerLocation.longitude],
				{ radius: 10, fillColor: '#0066cc', color: '#000', weight: 3, fillOpacity: 0.9 }
			).bindTooltip('You are here', { permanent: false }).addTo(state.map);
		}

		var bounds = [];
		if (state.callerMarker) bounds.push(state.callerMarker.getLatLng());

		state.filteredUsers.forEach(function (u) {
			var lat = u.mapLatitude || u.latitude;
			var lng = u.mapLongitude || u.longitude;
			if (typeof lat !== 'number' || typeof lng !== 'number') return;
			var fill = state.isPrivileged ? '#dc143c' : '#ff4500';
			var marker = L.circleMarker([lat, lng], {
				radius: 7, fillColor: fill, color: '#fff', weight: 2, fillOpacity: 0.9,
			});

			// Hover tooltip — shows just the username
			marker.bindTooltip(escapeHtml(u.username || ''), { 
				permanent: false, 
				direction: 'top',
				offset: [0, -12]
			});

			marker.bindPopup(buildPopupHtml(u), {
				maxWidth: 280, minWidth: 240, className: 'wg-marker-popup', closeButton: true,
			});

			// Wire popup action buttons each time the popup opens
			(function (user) {
				marker.on('popupopen', function (ev) {
					var popupEl = ev.popup.getElement();
					if (!popupEl) return;
					var fBtn = popupEl.querySelector('[data-popup-follow]');
					if (fBtn) {
						fBtn.addEventListener('click', function (e) {
							e.stopPropagation();
							followUser(user.uid, fBtn);
							// also reflect in the card below if present
							var cardBtn = document.querySelector('[data-follow-uid="' + user.uid + '"]');
							if (cardBtn && cardBtn !== fBtn) {
								// state.followingSet is updated by followUser on success
								setTimeout(function () {
									if (state.followingSet[user.uid]) {
										cardBtn.classList.add('following');
										cardBtn.textContent = '\u2713 Following';
									} else {
										cardBtn.classList.remove('following');
										cardBtn.textContent = '+ Follow';
									}
								}, 350);
							}
						});
					}
					var cBtn = popupEl.querySelector('[data-popup-chat]');
					if (cBtn) {
						cBtn.addEventListener('click', function (e) {
							e.stopPropagation();
							startChat(user.uid);
						});
					}
				});
			})(u);

			state.markerCluster.addLayer(marker);
			state.markerMap[u.uid] = marker;
			bounds.push([lat, lng]);
		});

		if (bounds.length > 1) {
			try { state.map.fitBounds(bounds, { padding: [40, 40], maxZoom: 12 }); } catch (e) {}
		} else if (state.callerMarker) {
			state.map.setView(state.callerMarker.getLatLng(), 10);
		}
	}

	function focusMarker(uid) {
		var marker = state.markerMap[uid];
		if (!marker) return;
		var latlng = marker.getLatLng();
		// If clustered, zoom to it first
		state.markerCluster.zoomToShowLayer(marker, function () {
			marker.openPopup();
			state.map.panTo(latlng);
		});
		// Scroll map into view if needed
		var mapEl = document.querySelector('.wg-map-wrap');
		if (mapEl && mapEl.getBoundingClientRect().top < 0) {
			mapEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
		}
	}

	// ============================================================
	// FOLLOW / CHAT ACTIONS
	// ============================================================
	function followUser(uid, btn) {
		var alreadyFollowing = state.followingSet[uid];
		var endpoint = '/api/v3/users/' + uid + '/follow';
		// Both follow and unfollow use PUT; NodeBB determines action based on current state
		var method = 'PUT';

		btn.disabled = true;
		console.log('[waymker-geo] followUser: PUT ' + endpoint);
		fetch(endpoint, {
			method: method,
			credentials: 'same-origin',
			headers: {
				'Accept': 'application/json',
				'Content-Type': 'application/json',
				'x-csrf-token': getCSRF(),
			},
		})
			.then(function (r) {
				btn.disabled = false;
				console.log('[waymker-geo] follow response status:', r.status);
				if (r.ok) {
					state.followingSet[uid] = !alreadyFollowing;
					if (state.followingSet[uid]) {
						btn.classList.add('following');
						btn.textContent = '\u2713 Following';
					} else {
						btn.classList.remove('following');
						btn.textContent = '+ Follow';
					}
				} else if (typeof app !== 'undefined' && app.alertError) {
					app.alertError('Could not update follow status.');
				}
			})
			.catch(function (err) {
				btn.disabled = false;
				console.error('[waymker-geo] follow fetch error:', err);
				if (typeof app !== 'undefined' && app.alertError) {
					app.alertError('Network error.');
				}
			});
	}

	function startChat(uid) {
		if (!uid) {
			console.warn('[waymker-geo] startChat: uid is missing', uid);
			return;
		}
		
		console.log('[waymker-geo] startChat called with uid:', uid);
		console.log('[waymker-geo] attempting POST /api/v3/chats with uids=[' + uid + ']');

		// Modern NodeBB v4 way: POST to /api/v3/chats with uids array
		fetch('/api/v3/chats', {
			method: 'POST',
			credentials: 'same-origin',
			headers: {
				'Accept': 'application/json',
				'Content-Type': 'application/json',
				'x-csrf-token': getCSRF(),
			},
			body: JSON.stringify({ uids: [parseInt(uid, 10)] }),
		})
			.then(function (r) {
				console.log('[waymker-geo] POST /api/v3/chats response status:', r.status);
				if (!r.ok) {
					console.error('[waymker-geo] POST /api/v3/chats failed with status', r.status);
					if (typeof app !== 'undefined' && app.alertError) {
						app.alertError('Could not open chat.');
					}
					return;
				}
				return r.json();
			})
			.then(function (data) {
				if (!data) return; // error case already handled
				var roomId = (data && data.response && data.response.roomId) ? data.response.roomId : null;
				if (!roomId) {
					console.warn('[waymker-geo] POST /api/v3/chats returned no roomId, full response:', data);
					if (typeof app !== 'undefined' && app.alertError) {
						app.alertError('Could not create chat room.');
					}
					return;
				}
				console.log('[waymker-geo] chat room opened, roomId:', roomId);
				window.location.href = '/chats/' + roomId;
			})
			.catch(function (err) {
				console.error('[waymker-geo] startChat fetch error:', err);
				if (typeof app !== 'undefined' && app.alertError) {
					app.alertError('Network error opening chat.');
				}
			});
	}

	// ============================================================
	// FOOTER STATS
	// ============================================================
	function updateFooterStats() {
		$('wg-stat-nearby').textContent = state.allUsers.length;

		// Count unique groups
		var groupSet = {};
		state.allUsers.forEach(function (u) {
			if (!u.roles) return;
			u.roles.forEach(function (g) {
				var name = (g && (g.displayName || g.name)) || '';
				if (name) groupSet[name] = true;
			});
		});
		$('wg-stat-groups').textContent = Object.keys(groupSet).length;
	}

	// ============================================================
	// EVENT DELEGATION
	// ============================================================
	function attachGridDelegation() {
		var grid = $('wg-results-grid');
		grid.addEventListener('click', function (e) {
			var t = e.target;

			// Menu button click
			var menuBtn = t.closest && t.closest('.wg-menu-btn');
			if (menuBtn) {
				e.stopPropagation();
				toggleMenu(menuBtn);
				return;
			}

			// Follow button
			var followBtn = t.closest && t.closest('[data-follow-uid]');
			if (followBtn) {
				e.stopPropagation();
				var fuid = parseInt(followBtn.getAttribute('data-follow-uid'), 10);
				followUser(fuid, followBtn);
				return;
			}

			// Chat button
			var chatBtn = t.closest && t.closest('[data-chat-uid]');
			if (chatBtn) {
				e.stopPropagation();
				var chatUid = parseInt(chatBtn.getAttribute('data-chat-uid'), 10);
				startChat(chatUid);
				return;
			}

			// Username link — let default navigation happen
			if (t.closest && t.closest('[data-stop]')) {
				e.stopPropagation();
				return;
			}

			// Card body click → focus marker
			var card = t.closest && t.closest('.wg-card');
			if (card) {
				var uid = parseInt(card.getAttribute('data-uid'), 10);
				if (uid) focusMarker(uid);
			}
		});

		// Hover-to-tooltip on markers was removed in Phase 4.1 — popup carries all the info now.
	}

	function toggleMenu(menuBtn) {
		var card = menuBtn.closest('.wg-card');
		if (!card) return;
		var uid = parseInt(card.getAttribute('data-uid'), 10);
		var existing = card.querySelector('.wg-menu-dropdown');

		// Close any open menu first
		document.querySelectorAll('.wg-menu-dropdown').forEach(function (d) { d.remove(); });

		if (existing || state.openMenuUid === uid) {
			state.openMenuUid = null;
			return;
		}
		state.openMenuUid = uid;

		var userslug = card.getAttribute('data-userslug') || '';
		var dropdown = document.createElement('div');
		dropdown.className = 'wg-menu-dropdown';
		dropdown.innerHTML =
			'<button data-action="profile">View profile</button>' +
			'<button data-action="chat">Send message</button>' +
			'<button data-action="copy">Copy profile link</button>';
		dropdown.addEventListener('click', function (e) {
			var action = e.target.getAttribute('data-action');
			if (action === 'profile') {
				window.location.href = '/user/' + encodeURIComponent(userslug);
			} else if (action === 'chat') {
				startChat(uid);
			} else if (action === 'copy') {
				var url = window.location.origin + '/user/' + userslug;
				if (navigator.clipboard) navigator.clipboard.writeText(url);
				if (typeof app !== 'undefined' && app.alertSuccess) app.alertSuccess('Profile link copied');
			}
			dropdown.remove();
			state.openMenuUid = null;
		});
		card.appendChild(dropdown);
	}

	// Close menu when clicking outside
	document.addEventListener('click', function (e) {
		if (e.target.closest && (e.target.closest('.wg-menu-btn') || e.target.closest('.wg-menu-dropdown'))) return;
		document.querySelectorAll('.wg-menu-dropdown').forEach(function (d) { d.remove(); });
		state.openMenuUid = null;
	});

	// ============================================================
	// INFINITE SCROLL
	// ============================================================
	function setupInfiniteScroll() {
		var sentinel = $('wg-scroll-sentinel');
		if (!sentinel || !('IntersectionObserver' in window)) {
			// fallback: scroll listener
			window.addEventListener('scroll', function () {
				if ((window.innerHeight + window.scrollY) >= document.body.offsetHeight - 400) {
					if (state.visibleCount < state.filteredUsers.length) renderNextBatch();
				}
			});
			return;
		}
		var observer = new IntersectionObserver(function (entries) {
			entries.forEach(function (entry) {
				if (entry.isIntersecting && state.visibleCount < state.filteredUsers.length) {
					renderNextBatch();
				}
			});
		}, { rootMargin: '300px' });
		observer.observe(sentinel);
	}

	// ============================================================
	// FILTERS — auto-apply
	// ============================================================
	function attachFilterHandlers() {
		var searchInput = $('wg-search');
		var debouncedSearch = debounce(function () {
			applyClientFilters();
		}, 200);
		searchInput.addEventListener('input', debouncedSearch);

		['wg-role', 'wg-group'].forEach(function (id) {
			$(id).addEventListener('change', function () { fetchUsersNearMe(); });
		});

		$('wg-reset').addEventListener('click', function () {
			$('wg-search').value = '';
			$('wg-role').value = '';
			$('wg-group').value = '';
			fetchUsersNearMe();
		});
	}

	// ============================================================
	// INIT
	// ============================================================
	function init() {
		initMap();
		attachGridDelegation();
		attachFilterHandlers();
		setupInfiniteScroll();
		fetchGroupsList();
		fetchUsersNearMe();
	}

	if (document.readyState === 'loading') {
		document.addEventListener('DOMContentLoaded', init);
	} else {
		init();
	}

})();
</script>
