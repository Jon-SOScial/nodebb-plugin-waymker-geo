'use strict';

const meta = require.main.require('./src/meta');

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
		geocoderCountry: settings.geocoderCountry || ''
	});
};

exports.geocodeProxy = async (req, res) => res.json({});
