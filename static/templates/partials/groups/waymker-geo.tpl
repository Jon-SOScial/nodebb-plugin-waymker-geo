<style>
#waymker-group-suggestions {
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

#waymker-group-suggestions div {
	padding: 10px 12px;
	border-bottom: 1px solid #f0f0f0;
	cursor: pointer;
	font-size: 13px;
}

#waymker-group-suggestions div:hover {
	background-color: #f5f5f5;
}

#waymker-group-suggestions div:last-child {
	border-bottom: none;
}

.waymker-group-geo-wrapper {
	position: relative;
}
</style>

<script>
document.addEventListener("DOMContentLoaded", async function() {
	const addressField = document.querySelector('input[name="address"]');
	if (!addressField) return;
	
	console.log('[waymker-geo-groups] Starting - found group address field');
	
	// Wrap parent
	if (addressField.parentElement) {
		addressField.parentElement.classList.add('waymker-group-geo-wrapper');
	}
	
	// Get Mapbox token
	const res = await fetch('/api/v3/plugins/waymker-geo/settings');
	const data = await res.json();
	const mapboxToken = data.mapboxToken;
	
	if (!mapboxToken) return;
	
	const suggestionsDiv = document.createElement('div');
	suggestionsDiv.id = 'waymker-group-suggestions';
	suggestionsDiv.style.display = 'none';
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
						console.log('[waymker-geo-groups] Got ' + data.features.length + ' results');
						
						data.features.forEach(function(feature) {
							const div = document.createElement('div');
							div.textContent = feature.place_name;
							
							div.addEventListener('click', function() {
								addressField.value = feature.place_name;
								suggestionsDiv.style.display = 'none';
								console.log('[waymker-geo-groups] Selected:', feature.place_name);
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
	
	console.log('[waymker-geo-groups] Group address autocomplete ready');
});
</script>
