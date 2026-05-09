'use strict';

/*
 * Thin Mapbox Geocoding API wrapper.
 *
 * Uses the v5/v6 forward-geocoding endpoint:
 *   https://api.mapbox.com/geocoding/v5/mapbox.places/{query}.json
 *
 * Returns a normalized object with the components we care about:
 *   { address, street, city, state, zip, neighborhood, country, lat, lng }
 *
 * No external HTTP library required; uses Node's https + URLSearchParams so
 * the plugin has zero runtime dependencies.
 */

const https = require('https');
const winston = require.main.require('winston');

const MAPBOX_BASE = 'api.mapbox.com';

function httpsGetJSON(url) {
	return new Promise((resolve, reject) => {
		const req = https.get(url, (res) => {
			let data = '';
			res.on('data', (chunk) => { data += chunk; });
			res.on('end', () => {
				if (res.statusCode >= 200 && res.statusCode < 300) {
					try { resolve(JSON.parse(data)); }
					catch (e) { reject(new Error(`mapbox: bad json (${e.message})`)); }
				} else {
					reject(new Error(`mapbox: HTTP ${res.statusCode}: ${data.slice(0, 200)}`));
				}
			});
		});
		req.on('error', reject);
		req.setTimeout(8000, () => {
			req.destroy(new Error('mapbox: timeout'));
		});
	});
}

// Walk Mapbox feature.context[] for the named place_type, return its text.
function pickContext(feature, type) {
	if (!feature || !Array.isArray(feature.context)) return '';
	const found = feature.context.find(c => c.id && c.id.startsWith(`${type}.`));
	return found ? (found.text || '') : '';
}

// Pick US-style state abbreviation if present, else state name.
function pickState(feature) {
	if (!feature || !Array.isArray(feature.context)) return '';
	const region = feature.context.find(c => c.id && c.id.startsWith('region.'));
	if (!region) return '';
	if (region.short_code) {
		// short_code e.g. "US-TX" — return just "TX"
		const m = region.short_code.match(/-([A-Z]{2,3})$/);
		if (m) return m[1];
	}
	return region.text || '';
}

function normalizeFeature(feature) {
	if (!feature) return null;

	// Build a "street" line: address number + street name.
	// Mapbox returns the street name in feature.text and the number in
	// feature.address for addresses returned at place_type=address.
	const placeType = (feature.place_type && feature.place_type[0]) || '';
	let street = '';
	if (placeType === 'address') {
		street = feature.address ?
			`${feature.address} ${feature.text}` :
			feature.text;
	} else if (placeType === 'poi') {
		// POI: prefer the formatted line if present
		street = feature.properties && feature.properties.address || feature.text;
	}

	const lng = feature.center && feature.center[0];
	const lat = feature.center && feature.center[1];

	return {
		address: feature.place_name || '',
		street: street.trim(),
		city: pickContext(feature, 'place') || pickContext(feature, 'locality'),
		state: pickState(feature),
		zip: pickContext(feature, 'postcode'),
		neighborhood: pickContext(feature, 'neighborhood'),
		country: pickContext(feature, 'country'),
		lat: typeof lat === 'number' ? lat : null,
		lng: typeof lng === 'number' ? lng : null,
		mapboxId: feature.id || '',
	};
}

exports.lookup = async function (query, settings) {
	if (!settings || !settings.mapboxToken) {
		throw new Error('mapbox: token not configured');
	}
	if (!query || typeof query !== 'string') return null;

	const params = new URLSearchParams({
		access_token: settings.mapboxToken,
		limit: '1',
		types: 'address,place,postcode,locality,neighborhood,poi',
	});
	if (settings.geocoderCountry) {
		params.set('country', String(settings.geocoderCountry).toLowerCase());
	}
	const path = `/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?${params.toString()}`;
	const url = `https://${MAPBOX_BASE}${path}`;

	const json = await httpsGetJSON(url);
	if (!json.features || !json.features.length) return null;
	return normalizeFeature(json.features[0]);
};

// For the autocomplete dropdown — returns several suggestions, not just one.
exports.suggest = async function (query, settings, opts = {}) {
	if (!settings || !settings.mapboxToken) {
		throw new Error('mapbox: token not configured');
	}
	if (!query || typeof query !== 'string') return [];

	const params = new URLSearchParams({
		access_token: settings.mapboxToken,
		limit: String(opts.limit || 5),
		autocomplete: 'true',
		types: opts.types || 'address,place,postcode,locality,neighborhood,poi',
	});
	if (settings.geocoderCountry) {
		params.set('country', String(settings.geocoderCountry).toLowerCase());
	}
	if (opts.proximity) {
		params.set('proximity', opts.proximity); // "lng,lat"
	}
	const path = `/geocoding/v5/mapbox.places/${encodeURIComponent(query)}.json?${params.toString()}`;
	const url = `https://${MAPBOX_BASE}${path}`;

	try {
		const json = await httpsGetJSON(url);
		return (json.features || []).map(normalizeFeature).filter(Boolean);
	} catch (err) {
		winston.warn(`[plugin/waymker-geo] mapbox suggest failed: ${err.message}`);
		return [];
	}
};
