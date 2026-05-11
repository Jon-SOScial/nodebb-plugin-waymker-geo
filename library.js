'use strict';

const fs = require('fs');
const path = require('path');
const plugin = {};

plugin.init = function(params, callback) {
	const app = params.app;
	app.get('/directory/nearby', plugin.nearbyController);
	callback();
};

plugin.nearbyController = function(req, res) {
	// Read the template file directly
	const templatePath = path.join(__dirname, 'static/templates/nearby.tpl');
	
	try {
		const html = fs.readFileSync(templatePath, 'utf8');
		res.send(html);
	} catch (err) {
		console.error('[waymker-geo] Failed to read template:', err);
		res.status(500).send('Failed to load nearby page: ' + err.message);
	}
};

plugin.loadGeoFeatures = function(data, callback) {
	const leafletCSS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css';
	const leafletMarkerCSS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.css';
	const leafletMarkerDefaultCSS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.Default.css';
	const leafletJS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js';
	const leafletMarkerJS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/leaflet.markercluster.js';

	data.scripts = data.scripts || [];
	data.scripts.push({ src: leafletCSS, attribute: 'rel="stylesheet"' });
	data.scripts.push({ src: leafletMarkerCSS, attribute: 'rel="stylesheet"' });
	data.scripts.push({ src: leafletMarkerDefaultCSS, attribute: 'rel="stylesheet"' });
	data.scripts.push({ src: leafletJS, async: false });
	data.scripts.push({ src: leafletMarkerJS, async: false });

	callback(null, data);
};

module.exports = plugin;
