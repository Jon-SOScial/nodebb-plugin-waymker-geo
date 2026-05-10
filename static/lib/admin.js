'use strict';

define('admin/plugins/waymker-geo', [], function () {
	const ACP = {};

	ACP.init = function () {
		console.log('[waymker-geo] ACP init');
		const $save = $('#save');
		
		$save.on('click', function (e) {
			e.preventDefault();
			
			const data = {
				mapboxToken: $('#mapboxToken').val() || '',
				geocoderCountry: $('#geocoderCountry').val() || '',
				defaultZoom: parseInt($('#defaultZoom').val(), 10) || 11,
				groupGeoEnabled: $('#groupGeoEnabled').is(':checked'),
				postGeoEnabled: $('#postGeoEnabled').is(':checked'),
			};
			
			$save.prop('disabled', true).text('Saving...');
			
			$.post('/api/plugins/waymker-geo/save', data, function () {
				window.location.reload();
			}).fail(function (xhr) {
				alert('Failed to save: HTTP ' + xhr.status);
				$save.prop('disabled', false).text('Save');
			});
		});
	};

	return ACP;
});
