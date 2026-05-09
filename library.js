'use strict';

/*
 * nodebb-plugin-waymker-geo
 *
 * Adds geo-aware profile fields (street, city, zip, neighborhood, state,
 * lat/lng) to users and groups, with per-field privacy toggles. A single
 * Mapbox-autocomplete address input populates all components at once.
 *
 * Designed to be the data + API layer. A separate plugin can render a
 * Leaflet map by consuming this plugin's HTTP API.
 *
 * Hook patterns target NodeBB v4.x. Async/await is used throughout.
 */

const winston = require.main.require('winston');
const meta = require.main.require('./src/meta');
const user = require.main.require('./src/user');
const routeHelpers = require.main.require('./src/routes/helpers');

const controllers = require('./lib/controllers');
const geocode = require('./lib/geocode');
const privacy = require('./lib/privacy');
const groupGeo = require('./lib/groups');

const plugin = module.exports;

// Field keys we manage. Kept in a single source of truth so hooks stay in sync.
plugin.GEO_FIELDS = [
	'geo:address',       // freeform formatted address (the searchable input)
	'geo:street',        // street + number
	'geo:city',
	'geo:state',
	'geo:zip',
	'geo:neighborhood',
	'geo:country',
	'geo:lat',
	'geo:lng',
];

// Privacy companion field for each above. Stored alongside the value.
// Allowed values: 'public' | 'registered' | 'followers' | 'private'
plugin.PRIVACY_FIELDS = plugin.GEO_FIELDS.map(f => `${f}:privacy`);

plugin.ALL_FIELDS = [...plugin.GEO_FIELDS, ...plugin.PRIVACY_FIELDS];

// Defaults users get if they've never saved privacy settings.
plugin.DEFAULT_PRIVACY = {
	'geo:address:privacy': 'private',
	'geo:street:privacy': 'private',
	'geo:city:privacy': 'registered',
	'geo:state:privacy': 'public',
	'geo:zip:privacy': 'private',
	'geo:neighborhood:privacy': 'registered',
	'geo:country:privacy': 'public',
	'geo:lat:privacy': 'private',
	'geo:lng:privacy': 'private',
};

// Settings cache populated on init from meta.settings.
plugin.settings = {
	mapboxToken: '',
	geocoderCountry: '',
	defaultZoom: 11,
	groupGeoEnabled: true,
	postGeoEnabled: true,
};

plugin.init = async function (params) {
	const { router, middleware } = params;

	// Pull settings from ACP store. meta.settings.get returns an object.
	const stored = await meta.settings.get('waymker-geo') || {};
	Object.assign(plugin.settings, stored);

	// Admin page. Signature is (router, path, middlewares, handler).
		// Settings save handler using setupAdminPageRoute for POST
	const acpRoute = '/admin/plugins/waymker-geo';
	routeHelpers.setupAdminPageRoute(router, acpRoute, [], controllers.renderAdminPage);
		router.post('/api/plugins/waymker-geo/save', [], controllers.saveSettings);

	// Public/private API endpoints. setupApiRoute does NOT auto-prefix —
	// the full path including /api/v3 is required (matches NodeBB's own
	// nodebb-plugin-emoji convention).
		routeHelpers.setupApiRoute(router, 'post', '/api/v3/plugins/waymker-geo/settings', [], controllers.saveSettings);
	routeHelpers.setupApiRoute(router, 'get', '/api/v3/plugins/waymker-geo/geocode',
		[middleware.ensureLoggedIn], controllers.geocodeProxy);

	routeHelpers.setupApiRoute(router, 'get', '/api/v3/plugins/waymker-geo/users-near',
		[middleware.ensureLoggedIn], controllers.usersNear);

	routeHelpers.setupApiRoute(router, 'get', '/api/v3/plugins/waymker-geo/user/:uid',
		[], controllers.getUserGeo);

	routeHelpers.setupApiRoute(router, 'get', '/api/v3/plugins/waymker-geo/group/:slug',
		[], controllers.getGroupGeo);

	routeHelpers.setupApiRoute(router, 'get', '/api/v3/plugins/waymker-geo/posts-near',
		[], controllers.postsNear);

	winston.verbose('[plugin/waymker-geo] Routes registered, settings loaded.');
};

plugin.addAdminNavigation = async function (header) {
	header.plugins.push({
		route: '/plugins/waymker-geo',
		icon: 'fa-map-marker-alt',
		name: 'Waymker Geo',
	});
	return header;
};

// ---------------------------------------------------------------------------
// User profile fields
// ---------------------------------------------------------------------------

// Tell NodeBB our custom fields are legal user-hash properties.
plugin.whitelistUserFields = async function (data) {
	data.whitelist.push(...plugin.ALL_FIELDS);
	return data;
};

// Tell NodeBB to allow these fields through user.updateProfile.
plugin.addUpdatableFields = async function (hookData) {
	const { fields } = hookData;
	plugin.ALL_FIELDS.forEach((f) => {
		if (!fields.includes(f)) fields.push(f);
	});
	hookData.fields = fields;

	// Server-side validation/sanitisation of any geo fields present in the
	// incoming payload. We don't trust client-supplied lat/lng; if the
	// client sent an address change, we re-geocode here authoritatively.
	if (plugin.settings.mapboxToken && hookData.data['geo:address']) {
		try {
			const result = await geocode.lookup(
				hookData.data['geo:address'],
				plugin.settings,
			);
			if (result) {
				// Overwrite client-sent components with geocoder truth.
				hookData.data['geo:street'] = result.street || '';
				hookData.data['geo:city'] = result.city || '';
				hookData.data['geo:state'] = result.state || '';
				hookData.data['geo:zip'] = result.zip || '';
				hookData.data['geo:neighborhood'] = result.neighborhood || '';
				hookData.data['geo:country'] = result.country || '';
				hookData.data['geo:lat'] = String(result.lat);
				hookData.data['geo:lng'] = String(result.lng);
			}
		} catch (err) {
			winston.warn(`[plugin/waymker-geo] geocode on save failed: ${err.message}`);
		}
	}

	// Coerce privacy values to allowed set; default if junk submitted.
	plugin.PRIVACY_FIELDS.forEach((pf) => {
		if (hookData.data[pf] !== undefined) {
			hookData.data[pf] = privacy.normalize(hookData.data[pf]);
		}
	});

	return hookData;
};

// Inject our fields into the edit page payload so the .tpl partial can render.
plugin.onUserAccountEdit = async function (data) {
	const uid = data.userData.uid;
	const stored = await user.getUserFields(uid, plugin.ALL_FIELDS);
	data.userData.waymkerGeo = privacy.buildEditPayload(stored, plugin);
	data.userData.waymkerMapboxToken = plugin.settings.mapboxToken || '';
	return data;
};

// Filter the public profile view to redact fields the viewer isn't allowed to see.
plugin.onUserAccountView = async function (data) {
	const callerUid = data.uid; // viewer
	const targetUid = data.userData.uid;
	const stored = await user.getUserFields(targetUid, plugin.ALL_FIELDS);
	data.userData.waymkerGeo = await privacy.buildViewPayload({
		stored,
		callerUid,
		targetUid,
		plugin,
	});
	return data;
};

// When other code calls user.getUserFields([...]) and our fields are included,
// run privacy redaction. Without this, plugins or templates that fetch fields
// directly would bypass the privacy layer.
plugin.filterUserFields = async function (data) {
	const requested = data.fields || [];
	const ourRequested = requested.filter(f => plugin.GEO_FIELDS.includes(f));
	if (!ourRequested.length || !data.uid) return data;

	const callerUid = (data && data.callerUid) || 0;
	if (Number(callerUid) === Number(data.uid)) return data; // owner sees own data

	// We can't always know the caller here (the hook signature doesn't always
	// carry it). Conservative behaviour: leave values intact and rely on the
	// view-time redaction in onUserAccountView and the API endpoints. Other
	// integrators wanting strict redaction at fetch time should pass
	// `callerUid` through.
	return data;
};

plugin.addUsersFields = async function (hookData) {
	// Some bulk fetch paths use this hook; ensure they ask for our fields when
	// callers explicitly request them. We don't unconditionally add — that
	// would add cost to every getUsers call.
	return hookData;
};

// ---------------------------------------------------------------------------
// Groups
// ---------------------------------------------------------------------------

plugin.onGroupGet = async function (data) {
	if (!plugin.settings.groupGeoEnabled) return data;
	if (!data.group || !data.group.name) return data;
	const geo = await groupGeo.read(data.group.name);
	data.group.waymkerGeo = geo;
	return data;
};

plugin.onGroupUpdate = async function (data) {
	if (!plugin.settings.groupGeoEnabled) return;
	// data: { groupName, values, uid }
	await groupGeo.write(data.groupName, data.values, plugin.settings);
};

// ---------------------------------------------------------------------------
// Posts / topics with attached coordinates
// ---------------------------------------------------------------------------

// Picks up `geoLat`, `geoLng`, `geoLabel` from the topic payload (the composer
// would set these via a separate composer plugin or future client extension)
// and stores them on the topic hash.
plugin.attachGeoToTopic = async function (data) {
	if (!plugin.settings.postGeoEnabled) return data;
	const t = data.topic;
	const src = data.data || {};
	if (src.geoLat && src.geoLng) {
		t['geo:lat'] = String(src.geoLat);
		t['geo:lng'] = String(src.geoLng);
		if (src.geoLabel) t['geo:label'] = String(src.geoLabel).slice(0, 255);
	}
	return data;
};

plugin.attachGeoToPost = async function (data) {
	if (!plugin.settings.postGeoEnabled) return data;
	const src = data.data || {};
	if (src.geoLat && src.geoLng) {
		data.post['geo:lat'] = String(src.geoLat);
		data.post['geo:lng'] = String(src.geoLng);
		if (src.geoLabel) data.post['geo:label'] = String(src.geoLabel).slice(0, 255);
	}
	return data;
};

// On topic page render, expose attached coords so themes/widgets can show them.
plugin.expandGeoOnTopicBuild = async function (hookData) {
	const t = hookData.templateData && hookData.templateData.topic;
	if (!t) return hookData;
	if (t['geo:lat'] && t['geo:lng']) {
		t.waymkerGeo = {
			lat: parseFloat(t['geo:lat']),
			lng: parseFloat(t['geo:lng']),
			label: t['geo:label'] || '',
		};
	}
	return hookData;
};
