define('admin/plugins/waymker-geo/groups', ['jquery'], function($) {
	console.log('[waymker-geo-admin] Groups script loaded');
	
	// Wait for address field to be added to DOM
	var checkForAddressField = setInterval(function() {
		var addressField = document.querySelector('input[name="address"]');
		
		if (addressField) {
			clearInterval(checkForAddressField);
			console.log('[waymker-geo-admin] Found address field, adding autocomplete');
			initGroupAutocomplete(addressField);
		}
	}, 500);
	
	function initGroupAutocomplete(addressField) {
		// Fetch Mapbox token
		fetch('/api/v3/plugins/waymker-geo/settings')
			.then(r => r.json())
			.then(data => {
				const mapboxToken = data.mapboxToken;
				if (!mapboxToken) return;
				
				console.log('[waymker-geo-admin] Initializing group address autocomplete');
				
				// Wrap parent for positioning
				addressField.parentElement.style.position = 'relative';
				
				// Create suggestions div
				const suggestionsDiv = document.createElement('div');
				suggestionsDiv.id = 'waymker-group-suggestions';
				suggestionsDiv.style.cssText = 'position:absolute;top:100%;left:0;right:0;background:white;border:1px solid #ddd;border-radius:4px;box-shadow:0 2px 6px rgba(0,0,0,0.1);max-height:200px;overflow-y:auto;z-index:100;margin-top:2px;display:none;';
				addressField.parentElement.appendChild(suggestionsDiv);
				
				let debounceTimer;
				addressField.addEventListener('input', function() {
					clearTimeout(debounceTimer);
					const query = this.value.trim();
					
					if (query.length < 2) {
						suggestionsDiv.style.display = 'none';
						return;
					}
					
					debounceTimer = setTimeout(function() {
						const encodedQuery = encodeURIComponent(query);
						const url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/' + encodedQuery + '.json?access_token=' + mapboxToken + '&limit=5';
						
						fetch(url)
							.then(r => r.json())
							.then(data => {
								suggestionsDiv.innerHTML = '';
								
								if (data.features && data.features.length > 0) {
									console.log('[waymker-geo-admin] Got ' + data.features.length + ' suggestions');
									
									data.features.forEach(function(feature) {
										const div = document.createElement('div');
										div.textContent = feature.place_name;
										div.style.cssText = 'padding:10px 12px;border-bottom:1px solid #f0f0f0;cursor:pointer;font-size:13px;';
										
										div.addEventListener('mouseover', function() {
											this.style.backgroundColor = '#f5f5f5';
										});
										
										div.addEventListener('mouseout', function() {
											this.style.backgroundColor = 'transparent';
										});
										
										div.addEventListener('click', function() {
											addressField.value = feature.place_name;
											suggestionsDiv.style.display = 'none';
											console.log('[waymker-geo-admin] Selected:', feature.place_name);
										});
										
										suggestionsDiv.appendChild(div);
									});
									suggestionsDiv.style.display = 'block';
								}
							});
					}, 300);
				});
				
				addressField.addEventListener('blur', function() {
					setTimeout(() => suggestionsDiv.style.display = 'none', 150);
				});
			});
	}
});
