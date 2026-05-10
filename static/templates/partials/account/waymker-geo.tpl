<div class="form-group">
  <label for="waymkerGeo:address">Address</label>
  <input type="text" id="waymkerGeo:address" name="waymkerGeo:address" class="form-control" placeholder="Enter your address" />
  <div id="waymkerGeo-suggestions" style="position: absolute; background: white; border: 1px solid #ccc; max-height: 300px; overflow-y: auto; width: 100%; z-index: 1000; display: none;"></div>
</div>

<div class="form-group">
  <label for="waymkerGeo:neighborhood">Neighborhood</label>
  <input type="text" id="waymkerGeo:neighborhood" name="waymkerGeo:neighborhood" class="form-control" placeholder="Auto-filled" readonly />
</div>

<div class="form-group">
  <label for="waymkerGeo:zipCode">Zip Code</label>
  <input type="text" id="waymkerGeo:zipCode" name="waymkerGeo:zipCode" class="form-control" placeholder="Auto-filled" readonly />
</div>

<div class="form-group">
  <label for="waymkerGeo:city">City</label>
  <input type="text" id="waymkerGeo:city" name="waymkerGeo:city" class="form-control" placeholder="Auto-filled" readonly />
</div>

<div class="form-group">
  <label for="waymkerGeo:state">State</label>
  <input type="text" id="waymkerGeo:state" name="waymkerGeo:state" class="form-control" placeholder="Auto-filled" readonly />
</div>

<div class="form-group">
  <label for="waymkerGeo:country">Country</label>
  <input type="text" id="waymkerGeo:country" name="waymkerGeo:country" class="form-control" placeholder="Auto-filled" readonly />
</div>

<div class="form-group">
  <label for="waymkerGeo:latitude">Latitude</label>
  <input type="text" id="waymkerGeo:latitude" name="waymkerGeo:latitude" class="form-control" placeholder="Auto-filled" readonly />
</div>

<div class="form-group">
  <label for="waymkerGeo:longitude">Longitude</label>
  <input type="text" id="waymkerGeo:longitude" name="waymkerGeo:longitude" class="form-control" placeholder="Auto-filled" readonly />
</div>

<script>
(function() {
  var mapboxToken = null;
  var suggestionContainer = document.getElementById('waymkerGeo-suggestions');
  var addressInput = document.querySelector('input[name="waymkerGeo:address"]');

  if (!addressInput) return;

  fetch('/api/v3/plugins/waymker-geo/settings')
    .then(function(r) { return r.json(); })
    .then(function(data) {
      mapboxToken = data.mapboxToken;
    });

  addressInput.addEventListener('input', function(e) {
    var query = e.target.value;
    if (!query || !mapboxToken) {
      suggestionContainer.style.display = 'none';
      return;
    }

    var url = 'https://api.mapbox.com/geocoding/v5/mapbox.places/' + encodeURIComponent(query) + '.json?token=' + mapboxToken + '&limit=5';

    fetch(url)
      .then(function(r) { return r.json(); })
      .then(function(data) {
        suggestionContainer.innerHTML = '';
        data.features.forEach(function(feature) {
          var div = document.createElement('div');
          div.textContent = feature.place_name;
          div.style.cssText = 'padding: 10px; cursor: pointer; border-bottom: 1px solid #eee;';
          div.addEventListener('mouseover', function() {
            this.style.backgroundColor = '#f0f0f0';
          });
          div.addEventListener('mouseout', function() {
            this.style.backgroundColor = 'transparent';
          });
          div.addEventListener('click', function() {
            selectResult(feature);
          });
          suggestionContainer.appendChild(div);
        });
        suggestionContainer.style.display = 'block';
      });
  });

  function selectResult(feature) {
    addressInput.value = feature.place_name;
    suggestionContainer.style.display = 'none';

    var coords = feature.geometry.coordinates;
    document.querySelector('input[name="waymkerGeo:latitude"]').value = coords[1];
    document.querySelector('input[name="waymkerGeo:longitude"]').value = coords[0];

    var neighborhood = '';
    var zipCode = '';
    var city = '';
    var state = '';
    var country = '';

    if (feature.context) {
      feature.context.forEach(function(ctx) {
        console.log('[waymker-geo] Context item:', ctx.id, ctx.text);
        if (ctx.id.indexOf('neighborhood') !== -1) neighborhood = ctx.text;
        if (ctx.id.indexOf('postcode') !== -1) zipCode = ctx.text;
        if (ctx.id.indexOf('place') !== -1) city = ctx.text;
        if (ctx.id.indexOf('region') !== -1) state = ctx.text;
        if (ctx.id.indexOf('country') !== -1) country = ctx.text;
      });
    }

    var neighborhoodField = document.querySelector('input[name="waymkerGeo:neighborhood"]');
    var zipField = document.querySelector('input[name="waymkerGeo:zipCode"]');
    var cityField = document.querySelector('input[name="waymkerGeo:city"]');
    var stateField = document.querySelector('input[name="waymkerGeo:state"]');
    var countryField = document.querySelector('input[name="waymkerGeo:country"]');

    console.log('[waymker-geo] Found fields:', {
      neighborhoodField: !!neighborhoodField,
      zipField: !!zipField,
      cityField: !!cityField,
      stateField: !!stateField,
      countryField: !!countryField
    });

    if (neighborhoodField) neighborhoodField.value = neighborhood;
    if (zipField) zipField.value = zipCode;
    if (cityField) cityField.value = city;
    if (stateField) stateField.value = state;
    if (countryField) countryField.value = country;

    console.log('[waymker-geo] Fields filled');
  }

  document.addEventListener('click', function(e) {
    if (e.target !== addressInput) {
      suggestionContainer.style.display = 'none';
    }
  });
})();
</script>
