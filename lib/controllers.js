'use strict';

const meta = require.main.require('./src/meta');

exports.renderAdminPage = async function (req, res) {
	console.log('[waymker-geo] *** renderAdminPage CALLED ***');
	try {
		const allSettings = await meta.settings.get('waymker-geo') || {};
		console.log('[waymker-geo] All settings from meta.settings.get:', JSON.stringify(allSettings));
		
		const oneSettings = await meta.settings.getOne('waymker-geo') || {};
		console.log('[waymker-geo] Settings from meta.settings.getOne:', JSON.stringify(oneSettings));
		
		const settings = Object.assign({}, allSettings, oneSettings);
		console.log('[waymker-geo] Final settings to render:', JSON.stringify(settings));
		
		res.render('admin/plugins/waymker-geo', {
			title: 'Waymker Geo',
			mapboxToken: settings.mapboxToken || '',
			geocoderCountry: settings.geocoderCountry || '',
			defaultZoom: settings.defaultZoom || 11,
			groupGeoEnabled: settings.groupGeoEnabled === true || settings.groupGeoEnabled === 'true',
			postGeoEnabled: settings.postGeoEnabled === true || settings.postGeoEnabled === 'true',
		});
	} catch (err) {
		console.error('[waymker-geo] renderAdminPage ERROR:', err);
		res.status(500).send('Error: ' + err.message);
	}
};

exports.saveSettings = async function (req, res) {
	console.log('[waymker-geo] *** saveSettings CALLED ***');
	console.log('[waymker-geo] req.body:', JSON.stringify(req.body));
	try {
		const settings = {
			mapboxToken: String(req.body.mapboxToken || '').trim(),
			geocoderCountry: String(req.body.geocoderCountry || '').trim(),
			defaultZoom: Math.max(1, Math.min(22, parseInt(req.body.defaultZoom, 10) || 11)),
			groupGeoEnabled: req.body.groupGeoEnabled === 'on',
			postGeoEnabled: req.body.postGeoEnabled === 'on',
		};
		console.log('[waymker-geo] About to save:', JSON.stringify(settings));
		await meta.settings.set('waymker-geo', settings);
		console.log('[waymker-geo] *** SAVE SUCCESSFUL ***');
		res.redirect('/admin/plugins/waymker-geo?saved=1');
	} catch (err) {
		console.error('[waymker-geo] *** SAVE FAILED ***:', err);
		res.redirect('/admin/plugins/waymker-geo?error=1');
	}
};

exports.geocodeProxy = async (req, res) => res.json({});
exports.usersNear = async (req, res) => res.json({});
exports.getUserGeo = async (req, res) => res.json({});
exports.getGroupGeo = async (req, res) => res.json({});
exports.postsNear = async (req, res) => res.json({});
