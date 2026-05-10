<style>
#waymker-suggestions {
	position: absolute;
	top: 100%;
	left: 0;
	right: 0;
	background: white;
	border: 1px solid #ddd;
	border-radius: 4px;
	box-shadow: 0 2px 6px rgba(0,0,0,0.1);
	max-height: 200px;
	overflow-y: auto;
	z-index: 100;
	margin-top: 2px;
}

#waymker-suggestions div {
	padding: 10px 12px;
	border-bottom: 1px solid #f0f0f0;
	cursor: pointer;
	font-size: 13px;
}

#waymker-suggestions div:hover {
	background-color: #f5f5f5;
}

#waymker-suggestions div:last-child {
	border-bottom: none;
}

.waymker-geo-wrapper {
	position: relative;
}
</style>

<script>
document.addEventListener("DOMContentLoaded", async function() {
	const geoField = document.querySelector('input[name="waymkerGeo:address"]');
	if (!geoField) return;
	
	console.log('[waymker-geo] Starting - found address field');
	
	geoField.parentElement.classList.add('waymker-geo-wrapper');
	
	const res = await fetch('/api/v3/plugins/waymker-geo/settings');
	const data = await res.json();
	const mapboxToken = data.mapboxToken;
	
	if (!mapboxToken) return;
	
	const suggestionsDiv = document.createElement('div');
	suggestionsDiv.id = 'waymker-suggestions';
	suggestionsDiv.style.display = 'none';
	geoField.parentElement.appendChild(suggestionsDiv);
	
	let debounceTimer;
	geoField.addEventListener('input', function() {
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
						console.log('[waymker-geo] Got ' + data.features.length + ' features');
						
						data.features.forEach(function(feature) {
							const div = document.createElement('div');
							div.textContent = feature.place_name;
							
							div.addEventListener('click', function() {
								console.log('[waymker-geo] Feature clicked:', feature);
								console.log('[waymker-geo] Feature context:', feature.context);
								console.log('[waymker-geo] Coordinates:', feature.geometry.coordinates);
								
								// Fill main address field
								geoField.value = feature.place_name;
								
								// Parse Mapbox context to extract components
								let zipCode = '';
								let city = '';
								let state = '';
								let country = '';
								
								if (feature.context) {
									feature.context.forEach(function(ctx) {
										console.log('[waymker-geo] Context item:', ctx.id, ctx.text);
										if (ctx.id.indexOf('postcode') !== -1) zipCode = ctx.text;
										if (ctx.id.indexOf('place') !== -1) city = ctx.text;
										if (ctx.id.indexOf('region') !== -1) state = ctx.text;
										if (ctx.id.indexOf('country') !== -1) country = ctx.text;
									});
								}
								
								console.log('[waymker-geo] Parsed:', {zipCode, city, state, country});
								
								// Fill additional fields
								const zipField = document.querySelector('input[name="waymkerGeo:zipCode"]');
								const cityField = document.querySelector('input[name="waymkerGeo:city"]');
								const stateField = document.querySelector('input[name="waymkerGeo:state"]');
								const countryField = document.querySelector('input[name="waymkerGeo:country"]');
								const latField = document.querySelector('input[name="waymkerGeo:latitude"]');
								const lngField = document.querySelector('input[name="waymkerGeo:longitude"]');
								
								console.log('[waymker-geo] Found fields:', {
									zipField: !!zipField,
									cityField: !!cityField,
									stateField: !!stateField,
									countryField: !!countryField,
									latField: !!latField,
									lngField: !!lngField
								});
								
								if (zipField) zipField.value = zipCode;
								if (cityField) cityField.value = city;
								if (stateField) stateField.value = state;
								if (countryField) countryField.value = country;
								if (latField) latField.value = feature.geometry.coordinates[1];
								if (lngField) lngField.value = feature.geometry.coordinates[0];
								
								console.log('[waymker-geo] Fields filled');
								
								suggestionsDiv.style.display = 'none';
							});
							
							suggestionsDiv.appendChild(div);
						});
						suggestionsDiv.style.display = 'block';
					}
				});
		}, 300);
	});
	
	geoField.addEventListener('blur', function() {
		setTimeout(() => suggestionsDiv.style.display = 'none', 150);
	});
});
</script>
