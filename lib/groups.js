'use strict';

/*
 * Group-level geo fields. Same shape as user fields, stored on the
 * `group:<groupName>` hash via NodeBB's groups module.
 *
 * No per-field privacy here yet — group profiles in NodeBB are already
 * gated by group privacy/membership. If you need finer control later,
 * mirror the privacy.js pattern.
 */

const groups = require.main.require('./src/groups');
const db = require.main.require('./src/database');
const winston = require.main.require('winston');

const FIELDS = [
	'geo:address',
	'geo:street',
	'geo:city',
	'geo:state',
	'geo:zip',
	'geo:neighborhood',
	'geo:country',
	'geo:lat',
	'geo:lng',
];

exports.FIELDS = FIELDS;

exports.read = async function (groupName) {
	if (!groupName) return null;
	const key = `group:${groupName}`;
	const data = await db.getObjectFields(key, FIELDS);
	if (!data) return null;
	const out = {};
	FIELDS.forEach((f) => {
		if (data[f] !== undefined && data[f] !== null && data[f] !== '') {
			out[f.replace(/^geo:/, '')] = f.endsWith('lat') || f.endsWith('lng')
				? parseFloat(data[f]) : data[f];
		}
	});
	return out;
};

exports.write = async function (groupName, values, settings) {
	if (!groupName || !values) return;
	const updates = {};
	FIELDS.forEach((f) => {
		if (values[f] !== undefined) {
			updates[f] = String(values[f]);
		}
	});

	// If a freeform `geo:address` was supplied (and Mapbox is configured),
	// re-geocode authoritatively for the same reasons we do for users.
	if (updates['geo:address'] && settings && settings.mapboxToken) {
		try {
			const geocode = require('./geocode');
			const result = await geocode.lookup(updates['geo:address'], settings);
			if (result) {
				updates['geo:street'] = result.street || '';
				updates['geo:city'] = result.city || '';
				updates['geo:state'] = result.state || '';
				updates['geo:zip'] = result.zip || '';
				updates['geo:neighborhood'] = result.neighborhood || '';
				updates['geo:country'] = result.country || '';
				updates['geo:lat'] = String(result.lat);
				updates['geo:lng'] = String(result.lng);
			}
		} catch (err) {
			winston.warn(`[plugin/waymker-geo] group geocode failed: ${err.message}`);
		}
	}

	if (Object.keys(updates).length === 0) return;
	await db.setObject(`group:${groupName}`, updates);
};
