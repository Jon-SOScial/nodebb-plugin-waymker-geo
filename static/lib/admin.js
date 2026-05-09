'use strict';

define('admin/plugins/waymker-geo', [], function () {
	const ACP = {};

	ACP.init = function () {
		$('#save').on('click', function (e) {
			e.preventDefault();
			$('form[data-waymker-geo-form]').submit();
		});
	};

	return ACP;
});
