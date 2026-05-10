<div class="acp-page-container">
	<form method="post" action="/api/plugins/waymker-geo/save" data-waymker-geo-form>
		<div class="row m-0">
			<div class="col-12 px-0 mb-4">
				<div class="d-flex border-bottom py-2 m-0 sticky-top acp-page-main-header align-items-center justify-content-between">
					<h4 class="fw-bold tracking-tight mb-0">Waymker Geo</h4>
					<div><button type="submit" class="btn btn-primary btn-sm fw-semibold">Save</button></div>
				</div>
			</div>
		</div>

		<div class="row waymker-geo-settings">
			<div class="col-sm-2 col-12 settings-header">Mapbox</div>
			<div class="col-sm-10 col-12">
				<div class="mb-3">
					<label class="form-label" for="mapboxToken">Mapbox access token</label>
					<input type="text" id="mapboxToken" name="mapboxToken" class="form-control" placeholder="pk.eyJ1Ij..." value="{mapboxToken}" />
				</div>
				<div class="mb-3">
					<label class="form-label" for="geocoderCountry">Restrict to country</label>
					<input type="text" id="geocoderCountry" name="geocoderCountry" class="form-control" placeholder="us" value="{geocoderCountry}" />
				</div>
				<div class="mb-3">
					<label class="form-label" for="defaultZoom">Default zoom</label>
					<input type="number" id="defaultZoom" name="defaultZoom" class="form-control" value="{defaultZoom}" min="1" max="22" />
				</div>
			</div>
		</div>

		<div class="row waymker-geo-settings">
			<div class="col-sm-2 col-12 settings-header">Features</div>
			<div class="col-sm-10 col-12">
				<div class="form-check form-switch">
					<input class="form-check-input" type="checkbox" id="groupGeoEnabled" name="groupGeoEnabled" value="on" data-group-enabled="{groupGeoEnabled}" />
					<label class="form-check-label" for="groupGeoEnabled">Enable group geo fields</label>
				</div>
				<div class="form-check form-switch">
					<input class="form-check-input" type="checkbox" id="postGeoEnabled" name="postGeoEnabled" value="on" data-post-enabled="{postGeoEnabled}" />
					<label class="form-check-label" for="postGeoEnabled">Allow coordinates on posts/topics</label>
				</div>
			</div>
		</div>
	</form>

	<script>
	document.addEventListener('DOMContentLoaded', function() {
		// Set checkboxes based on data attributes
		const groupCheckbox = document.getElementById('groupGeoEnabled');
		const postCheckbox = document.getElementById('postGeoEnabled');
		
		if (groupCheckbox && groupCheckbox.dataset.groupEnabled === 'true') {
			groupCheckbox.checked = true;
		}
		if (postCheckbox && postCheckbox.dataset.postEnabled === 'true') {
			postCheckbox.checked = true;
		}
	});
	</script>
</div>
