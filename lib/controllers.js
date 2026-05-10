'use strict';

const meta = require.main.require('./src/meta');
const user = require.main.require('./src/user');
const db = require.main.require('./src/database');

// Earth radius in miles (use 6371 for km)
const EARTH_RADIUS_MILES = 3959;

// Haversine formula for distance between two coordinates
function haversineDistance(lat1, lng1, lat2, lng2) {
	const toRad = (deg) => deg * Math.PI / 180;
	const dLat = toRad(lat2 - lat1);
	const dLng = toRad(lng2 - lng1);
	const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
		Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
		Math.sin(dLng / 2) * Math.sin(dLng / 2);
	const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
	return EARTH_RADIUS_MILES * c;
}

exports.renderAdminPage = async function (req, res) {
	const settings1 = await meta.settings.getOne('waymker-geo');
	const settings2 = await meta.settings.get('waymker-geo');
	const settings = settings1 && Object.keys(settings1).length > 0 ? settings1 : settings2;

	const data = {
		title: 'Waymker Geo',
		mapboxToken: settings.mapboxToken || '',
		geocoderCountry: settings.geocoderCountry || '',
		defaultZoom: settings.defaultZoom || 11,
		groupGeoEnabled: settings.groupGeoEnabled || false,
		postGeoEnabled: settings.postGeoEnabled || false,
	};

	res.render('admin/plugins/waymker-geo', data);
};

exports.saveSettings = async function (req, res) {
	try {
		const settings = {
			mapboxToken: String(req.body.mapboxToken || '').trim(),
			geocoderCountry: String(req.body.geocoderCountry || '').trim(),
			defaultZoom: Math.max(1, Math.min(22, parseInt(req.body.defaultZoom, 10) || 11)),
			groupGeoEnabled: req.body.groupGeoEnabled === 'on',
			postGeoEnabled: req.body.postGeoEnabled === 'on',
		};

		await meta.settings.set('waymker-geo', settings);
		res.redirect('/admin/plugins/waymker-geo?saved=1');
	} catch (err) {
		res.redirect('/admin/plugins/waymker-geo?error=1');
	}
};

// Return Mapbox token to frontend for geocoding
exports.getSettings = async function (req, res) {
	const settings1 = await meta.settings.getOne('waymker-geo');
	const settings2 = await meta.settings.get('waymker-geo');
	const settings = settings1 && Object.keys(settings1).length > 0 ? settings1 : settings2;

	console.log('[waymker-geo] getSettings called, returning token');
	res.json({
		mapboxToken: settings.mapboxToken || '',
		geocoderCountry: settings.geocoderCountry || '',
	});
};

exports.geocodeProxy = async (req, res) => res.json({});

// NEW: Get users sorted by distance from current user
exports.getUsersNearMe = async function (req, res) {
	try {
		const callerUid = parseInt(req.uid, 10);
		if (!callerUid) {
			return res.status(401).json({ error: 'Login required' });
		}

		// Permission check
		const isAdmin = await user.isAdministrator(callerUid);
		const isGlobalMod = await user.isGlobalModerator(callerUid);
		const isPrivileged = isAdmin || isGlobalMod;

		// Get caller's location
		const callerFields = await user.getUserFields(callerUid, [
			'waymkerGeo:latitude',
			'waymkerGeo:longitude',
		]);

		const callerLat = parseFloat(callerFields['waymkerGeo:latitude']);
		const callerLng = parseFloat(callerFields['waymkerGeo:longitude']);

		if (isNaN(callerLat) || isNaN(callerLng)) {
			return res.status(400).json({
				error: 'Your profile does not have a location set. Please add your address first.',
			});
		}

		// Parse query params
		const limit = Math.min(parseInt(req.query.limit, 10) || 50, 200);
		const radius = req.query.radius ? parseFloat(req.query.radius) : null;

		// Get all users
		const uids = await db.getSortedSetRange('users:joindate', 0, -1);

		// Fetch geo fields for all users in bulk
		const userFields = await user.getUsersFields(uids, [
			'uid',
			'username',
			'userslug',
			'picture',
			'waymkerGeo:latitude',
			'waymkerGeo:longitude',
			'waymkerGeo:address',
			'waymkerGeo:neighborhood',
			'waymkerGeo:zipCode',
			'waymkerGeo:city',
			'waymkerGeo:state',
			'waymkerGeo:country',
		]);

		// Build results: filter, calculate distance, apply permissions
		const results = userFields
			.filter((u) => {
				if (parseInt(u.uid, 10) === callerUid) return false;
				const lat = parseFloat(u['waymkerGeo:latitude']);
				const lng = parseFloat(u['waymkerGeo:longitude']);
				return !isNaN(lat) && !isNaN(lng);
			})
			.map((u) => {
				const lat = parseFloat(u['waymkerGeo:latitude']);
				const lng = parseFloat(u['waymkerGeo:longitude']);
				const distance = haversineDistance(callerLat, callerLng, lat, lng);

				// Public-level data (always visible)
				const userData = {
					uid: u.uid,
					username: u.username,
					userslug: u.userslug,
					picture: u.picture,
					distance: parseFloat(distance.toFixed(2)),
					neighborhood: u['waymkerGeo:neighborhood'] || '',
					city: u['waymkerGeo:city'] || '',
					state: u['waymkerGeo:state'] || '',
					country: u['waymkerGeo:country'] || '',
				};

				// Privileged data (admins/mods only)
				if (isPrivileged) {
					userData.latitude = lat;
					userData.longitude = lng;
					userData.address = u['waymkerGeo:address'] || '';
					userData.zipCode = u['waymkerGeo:zipCode'] || '';
				}

				return userData;
			})
			.filter((u) => !radius || isNaN(radius) ? true : u.distance <= radius)
			.sort((a, b) => a.distance - b.distance)
			.slice(0, limit);

		res.json({
			count: results.length,
			isPrivileged: isPrivileged,
			callerLocation: { latitude: callerLat, longitude: callerLng },
			users: results,
		});
	} catch (err) {
		console.error('[waymker-geo] users-near-me error:', err);
		res.status(500).json({ error: err.message });
	}
};
