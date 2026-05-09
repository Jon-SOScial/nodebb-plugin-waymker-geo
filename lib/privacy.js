'use strict';

/*
 * Per-field privacy logic.
 *
 * Each geo field has a companion "<field>:privacy" value, one of:
 *   public      — anyone, including guests
 *   registered  — any logged-in user
 *   followers   — users the target follows back (mutual)
 *   private     — only the user themselves (and admins/global mods)
 *
 * canSee() takes (level, callerUid, targetUid) and resolves to a boolean.
 * buildEditPayload() returns an object the edit template can iterate.
 * buildViewPayload() returns the same shape but with redacted values.
 */

const user = require.main.require('./src/user');

const ALLOWED = new Set(['public', 'registered', 'followers', 'private']);

exports.normalize = function (val) {
	const s = String(val || '').toLowerCase();
	return ALLOWED.has(s) ? s : 'private';
};

exports.canSee = async function (level, callerUid, targetUid) {
	const ownerViewing = Number(callerUid) === Number(targetUid) && Number(targetUid) > 0;
	if (ownerViewing) return true;

	// Admins and global mods always see everything.
	if (Number(callerUid) > 0) {
		const isPriv = await user.isAdminOrGlobalMod(callerUid);
		if (isPriv) return true;
	}

	switch (level) {
		case 'public':
			return true;
		case 'registered':
			return Number(callerUid) > 0;
		case 'followers': {
			if (!Number(callerUid)) return false;
			// Mutual-follow: target follows caller AND caller follows target.
			const [a, b] = await Promise.all([
				user.isFollowing(targetUid, callerUid),
				user.isFollowing(callerUid, targetUid),
			]);
			return a && b;
		}
		case 'private':
		default:
			return false;
	}
};

// Always-visible companion for editing — owner sees their own data, raw.
exports.buildEditPayload = function (stored, plugin) {
	const out = { fields: [] };
	plugin.GEO_FIELDS.forEach((f) => {
		const privacyKey = `${f}:privacy`;
		out.fields.push({
			key: f,
			label: friendlyLabel(f),
			value: stored[f] || '',
			privacy: stored[privacyKey] || plugin.DEFAULT_PRIVACY[privacyKey] || 'private',
			privacyOptions: [
				{ value: 'public', label: 'Public' },
				{ value: 'registered', label: 'Registered users' },
				{ value: 'followers', label: 'Mutual follows' },
				{ value: 'private', label: 'Only me' },
			],
		});
	});
	return out;
};

exports.buildViewPayload = async function ({ stored, callerUid, targetUid, plugin }) {
	const out = { fields: [] };
	for (const f of plugin.GEO_FIELDS) {
		const level = stored[`${f}:privacy`] || plugin.DEFAULT_PRIVACY[`${f}:privacy`] || 'private';
		// eslint-disable-next-line no-await-in-loop
		const allowed = await exports.canSee(level, callerUid, targetUid);
		out.fields.push({
			key: f,
			label: friendlyLabel(f),
			value: allowed ? (stored[f] || '') : '',
			redacted: !allowed,
		});
	}
	// Also expose a convenience flag for "we can show a marker for this user"
	const lat = stored['geo:lat'];
	const lng = stored['geo:lng'];
	const latLevel = stored['geo:lat:privacy'] || plugin.DEFAULT_PRIVACY['geo:lat:privacy'];
	const lngLevel = stored['geo:lng:privacy'] || plugin.DEFAULT_PRIVACY['geo:lng:privacy'];
	const canShowLat = await exports.canSee(latLevel, callerUid, targetUid);
	const canShowLng = await exports.canSee(lngLevel, callerUid, targetUid);
	out.mappable = !!(lat && lng && canShowLat && canShowLng);
	if (out.mappable) {
		out.lat = parseFloat(lat);
		out.lng = parseFloat(lng);
	}
	return out;
};

function friendlyLabel(key) {
	switch (key) {
		case 'geo:address': return 'Address';
		case 'geo:street': return 'Street';
		case 'geo:city': return 'City';
		case 'geo:state': return 'State / Region';
		case 'geo:zip': return 'Postal code';
		case 'geo:neighborhood': return 'Neighborhood';
		case 'geo:country': return 'Country';
		case 'geo:lat': return 'Latitude';
		case 'geo:lng': return 'Longitude';
		default: return key;
	}
}
