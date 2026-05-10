'use strict';

const meta = require.main.require('./src/meta');
const user = require.main.require('./src/user');
const db = require.main.require('./src/database');
const groups = require.main.require('./src/groups');
const fs = require('fs');

const EARTH_RADIUS_MILES = 3959;
const DEBUG_FILE = '/tmp/waymker-geo-debug.log';

function logDebug(msg) {
	console.log('[waymker-geo]', msg);
	try {
		fs.appendFileSync(DEBUG_FILE, '[' + new Date().toISOString() + '] ' + msg + '\n');
	} catch (e) {}
}

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

exports.getSettings = async function (req, res) {
	const settings1 = await meta.settings.getOne('waymker-geo');
	const settings2 = await meta.settings.get('waymker-geo');
	const settings = settings1 && Object.keys(settings1).length > 0 ? settings1 : settings2;

	res.json({
		mapboxToken: settings.mapboxToken || '',
		geocoderCountry: settings.geocoderCountry || '',
	});
};

exports.geocodeProxy = async (req, res) => res.json({});

exports.getUsersNearMe = async function (req, res) {
	try {
		const callerUid = parseInt(req.uid, 10);
		if (!callerUid) {
			return res.status(401).json({ error: 'Login required' });
		}

		const isAdmin = await user.isAdministrator(callerUid);
		const isGlobalMod = await user.isGlobalModerator(callerUid);
		const isPrivileged = isAdmin || isGlobalMod;

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

		// Get caller's friends
		let callerFriends = [];
		try {
			let friendsKey = 'uid:' + callerUid + ':friends';
			callerFriends = await db.getSetMembers(friendsKey);
			callerFriends = callerFriends.map((f) => parseInt(f, 10));
			logDebug('Caller ' + callerUid + ' friendsKey: ' + friendsKey + ' friends: ' + JSON.stringify(callerFriends));
		} catch (e) {
			logDebug('Error getting friends: ' + e.message);
		}

		const limit = Math.min(parseInt(req.query.limit, 10) || 50, 200);
		const radius = req.query.radius ? parseFloat(req.query.radius) : null;
		const minReputation = req.query.minReputation ? parseInt(req.query.minReputation, 10) : null;
		const roleFilter = req.query.roles ? req.query.roles.trim() : null;
		const groupFilter = req.query.group ? req.query.group.trim() : null;
		const friendsFilter = req.query.friends || 'all';

		const uids = await db.getSortedSetRange('users:joindate', 0, -1);

		const userFields = await user.getUsersFields(uids, [
			'uid',
			'username',
			'userslug',
			'picture',
			'reputation',
			'waymkerGeo:latitude',
			'waymkerGeo:longitude',
			'waymkerGeo:address',
			'waymkerGeo:neighborhood',
			'waymkerGeo:zipCode',
			'waymkerGeo:city',
			'waymkerGeo:state',
			'waymkerGeo:country',
		]);

		// Fetch user groups
		const userGroupMap = {};
		try {
			for (const uid of uids) {
				const userGroups = await groups.getUserGroups([uid]);
				userGroupMap[uid] = (userGroups && Array.isArray(userGroups) && userGroups.length > 0 && Array.isArray(userGroups[0])) 
					? userGroups[0] 
					: [];
			}
		} catch (e) {
			logDebug('Error fetching groups: ' + e.message);
		}

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
				const uid = parseInt(u.uid, 10);

				const userData = {
					uid: uid,
					username: u.username,
					userslug: u.userslug,
					picture: u.picture,
					distance: parseFloat(distance.toFixed(2)),
					reputation: parseInt(u.reputation, 10) || 0,
					neighborhood: u['waymkerGeo:neighborhood'] || '',
					city: u['waymkerGeo:city'] || '',
					state: u['waymkerGeo:state'] || '',
					country: u['waymkerGeo:country'] || '',
					roles: userGroupMap[uid] || [],
				};

				if (isPrivileged) {
					userData.latitude = lat;
					userData.longitude = lng;
					userData.address = u['waymkerGeo:address'] || '';
					userData.zipCode = u['waymkerGeo:zipCode'] || '';
				}

				return userData;
			})
			.filter((u) => (!radius || isNaN(radius) ? true : u.distance <= radius))
			.filter((u) => (!minReputation ? true : u.reputation >= minReputation))
			.filter((u) => {
				if (!roleFilter) return true;
				const groupNames = u.roles.map(g => typeof g === 'string' ? g : (g.name || g.slug || ''));
				logDebug('Checking role filter: ' + roleFilter + ' for user ' + u.username + ' groups: ' + JSON.stringify(groupNames));
				if (roleFilter === 'administrator') {
					return groupNames.indexOf('administrators') !== -1;
				}
				if (roleFilter === 'moderator') {
					return groupNames.indexOf('Global Moderators') !== -1;
				}
				if (roleFilter === 'user') {
					return groupNames.indexOf('administrators') === -1 && groupNames.indexOf('Global Moderators') === -1;
				}
				return false;
			})
			.filter((u) => {
				if (!groupFilter) return true;
				return u.roles && u.roles.some(function(role) {
					if (typeof role === 'string') {
						return role === groupFilter;
					}
					return (role.slug === groupFilter || role.name === groupFilter);
				});
			})
			.filter((u) => {
				if (friendsFilter === 'all') return true;
				const uid = u.uid;
				const isFriend = callerFriends.indexOf(uid) !== -1;
				logDebug('Checking friend filter for ' + u.username + ' uid=' + uid + ' isFriend=' + isFriend + ' callerFriends=' + JSON.stringify(callerFriends));
				if (friendsFilter === 'friends') return isFriend;
				if (friendsFilter === 'nonfriends') return !isFriend;
				return true;
			})
			.sort((a, b) => a.distance - b.distance)
			.slice(0, limit);

		logDebug('Query: roleFilter=' + roleFilter + ' groupFilter=' + groupFilter + ' friendsFilter=' + friendsFilter + ' Results=' + results.length);

		res.json({
			count: results.length,
			isPrivileged: isPrivileged,
			callerLocation: { latitude: callerLat, longitude: callerLng },
			users: results,
		});
	} catch (err) {
		logDebug('ERROR: ' + err.message);
		res.status(500).json({ error: err.message });
	}
};

exports.renderNearbyPage = async function (req, res) {
	res.render('nearby', {
		title: 'Users Near Me',
	});
};
