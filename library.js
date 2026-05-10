'use strict';

console.log('\n[waymker-geo] *** LIBRARY.JS LOADED ***\n');

const fs = require('fs');
const plugin = {};
plugin.settings = {};

plugin.init = async (params) => {
	console.log('\n\n[waymker-geo] *** INIT HOOK FIRING ***\n\n');
	fs.appendFileSync('/tmp/waymker-geo-debug.log', `[${new Date().toISOString()}] init() called\n`);

	const { router, middleware } = params;
	const meta = require.main.require('./src/meta');
	const routeHelpers = require.main.require('./src/routes/helpers');
	const controllers = require('./lib/controllers.js');

	const stored = await meta.settings.get('waymker-geo') || {};
	Object.assign(plugin.settings, stored);

	// Admin page
	routeHelpers.setupAdminPageRoute(router, '/admin/plugins/waymker-geo', [], controllers.renderAdminPage);
	router.post('/api/plugins/waymker-geo/save', [], controllers.saveSettings);

	// API routes for frontend
	routeHelpers.setupApiRoute(router, 'get', '/api/v3/plugins/waymker-geo/settings', [], controllers.getSettings);
	routeHelpers.setupApiRoute(router, 'get', '/api/v3/plugins/waymker-geo/geocode', [middleware.ensureLoggedIn], controllers.geocodeProxy);
	routeHelpers.setupApiRoute(router, 'get', '/api/v3/plugins/waymker-geo/users-near-me', [middleware.ensureLoggedIn], controllers.getUsersNearMe);

	console.log('[waymker-geo] Routes registered (including users-near-me)');
	fs.appendFileSync('/tmp/waymker-geo-debug.log', `[${new Date().toISOString()}] Routes registered\n`);
};

plugin.addAdminNavigation = (header) => {
	header.plugins.push({
		route: '/plugins/waymker-geo',
		icon: 'fa-map-marker-alt',
		name: 'Waymker Geo',
	});
	return header;
};

plugin.whitelistUserFields = (fields) => {
	fields.push('waymkerGeo:address');
	fields.push('waymkerGeo:neighborhood');
	fields.push('waymkerGeo:zipCode');
	fields.push('waymkerGeo:city');
	fields.push('waymkerGeo:state');
	fields.push('waymkerGeo:country');
	fields.push('waymkerGeo:latitude');
	fields.push('waymkerGeo:longitude');
	return fields;
};

exports.init = plugin.init;
exports.addAdminNavigation = plugin.addAdminNavigation;
exports.whitelistUserFields = plugin.whitelistUserFields;

module.exports = exports;
