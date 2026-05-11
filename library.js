'use strict';

const plugin = {};

plugin.loadGeoFeatures = function(data, callback) {
	// Inject Leaflet and MarkerCluster into the header so they load once globally
	const leafletCSS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.css';
	const leafletMarkerCSS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.css';
	const leafletMarkerDefaultCSS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/MarkerCluster.Default.css';
	const leafletJS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet/1.9.4/leaflet.min.js';
	const leafletMarkerJS = 'https://cdnjs.cloudflare.com/ajax/libs/leaflet.markercluster/1.4.1/leaflet.markercluster.js';

	// Add CSS links to header
	data.scripts = data.scripts || [];
	data.scripts.push({
		src: leafletCSS,
		link: true,
	});
	data.scripts.push({
		src: leafletMarkerCSS,
		link: true,
	});
	data.scripts.push({
		src: leafletMarkerDefaultCSS,
		link: true,
	});

	// Add JS scripts to header
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
