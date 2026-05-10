'use strict';

define('forum/plugins/waymker-geo', [], function () {
	const GeoInject = {};

	GeoInject.init = function () {
		console.log('[waymker-geo] Client-side injector running');
		
		// Check if we're on the profile edit page
		if (!window.app || !document.querySelector('[data-template="account/edit"]')) {
			console.log('[waymker-geo] Not on profile edit page');
			return;
		}

		console.log('[waymker-geo] *** On profile edit page, injecting location fields ***');
		
		// Find the form and insert our geo card before the signature field
		const aboutMeField = document.querySelector('[data-field="about:me"]') || 
							  document.querySelector('.card-body')?.closest('.card');
		
		if (aboutMeField) {
			console.log('[waymker-geo] Found about me field, injecting after it');
			
			const geoHTML = `
				<div data-waymker-geo-root class="waymker-geo-edit card mb-3">
					<div class="card-header fw-bold">
						<i class="fa fa-map-marker-alt me-1"></i> Location
					</div>
					<div class="card-body">
						<div class="mb-3">
							<label class="form-label" for="waymker-geo-address">Search address</label>
							<input type="text" id="waymker-geo-address" name="geo:address"
								class="form-control" autocomplete="off"
								placeholder="Start typing your address..." />
							<div class="form-text">
								Enter your location to enable geo-based features.
							</div>
						</div>
					</div>
				</div>
			`;
			
			aboutMeField.insertAdjacentHTML('afterend', geoHTML);
			console.log('[waymker-geo] *** GEO FIELDS INJECTED ***');
		} else {
			console.log('[waymker-geo] Could not find insertion point');
		}
	};

	return GeoInject;
});
