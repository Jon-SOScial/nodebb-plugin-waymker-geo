'use strict';

const plugin = {};

plugin.init = function(params, callback) {
	const app = params.app;
	const controllers = params.controllers;
	
	// Register the /directory/nearby route
	app.get('/directory/nearby', plugin.nearbyController);
	
	callback();
};

plugin.nearbyController = function(req, res) {
	res.render('plugins/nodebb-plugin-waymker-geo/nearby');
};

plugin.loadGeoFeatures = function(data, callback) {
	// Inject Leaflet and MarkerCluster into the header so they load once globally
	const leafletCSS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css';
	const leafletMarkerCSS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.css';
	const leafletMarkerDefaultCSS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.Default.css';
	const leafletJS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js';
	const leafletMarkerJS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/leaflet.markercluster.js';

	data.scripts = data.scripts || [];
	
	// Add CSS
	data.scripts.push({
		src: leafletCSS,
		attribute: 'rel="stylesheet"',
	});
	data.scripts.push({
		src: leafletMarkerCSS,
		attribute: 'rel="stylesheet"',
	});
	data.scripts.push({
		src: leafletMarkerDefaultCSS,
		attribute: 'rel="stylesheet"',
	});

	// Add JS (async: false ensures they load in order before our plugin code)
	data.scripts.push({
		src: leafletJS,
		async: false,
	});
	data.scripts.push({
		src: leafletMarkerJS,
		async: false,
	});

	callback(null, data);
};

module.exports = plugin;
