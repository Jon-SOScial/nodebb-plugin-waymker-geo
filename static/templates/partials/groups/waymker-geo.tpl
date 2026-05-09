<!--
	Group geo fields partial.

	Theme can IMPORT this inside groups/details.tpl or admin/manage/groups.tpl.
-->
<div data-waymker-geo-group-root class="waymker-geo-group-edit card mb-3">
	<div class="card-header fw-bold">
		<i class="fa fa-map-marker-alt me-1"></i> Group location
	</div>
	<div class="card-body">
		<div class="mb-3 position-relative">
			<label class="form-label" for="waymker-group-address">Search address</label>
			<input type="text" id="waymker-group-address" name="geo:address"
				class="form-control" autocomplete="off"
				value="{group.waymkerGeo.address}"
				placeholder="Start typing the group's address..." />
			<div data-waymker-geo-suggestions class="list-group position-absolute w-100 shadow-sm"
				style="z-index: 30; top: 100%; display: none;"></div>
		</div>

		<div class="row g-2">
			<div class="col-sm-4">
				<label class="form-label">City</label>
				<input type="text" name="geo:city" class="form-control form-control-sm" value="{group.waymkerGeo.city}" />
			</div>
			<div class="col-sm-4">
				<label class="form-label">State</label>
				<input type="text" name="geo:state" class="form-control form-control-sm" value="{group.waymkerGeo.state}" />
			</div>
			<div class="col-sm-4">
				<label class="form-label">Postal code</label>
				<input type="text" name="geo:zip" class="form-control form-control-sm" value="{group.waymkerGeo.zip}" />
			</div>
			<div class="col-sm-6">
				<input type="hidden" name="geo:lat" value="{group.waymkerGeo.lat}" />
			</div>
			<div class="col-sm-6">
				<input type="hidden" name="geo:lng" value="{group.waymkerGeo.lng}" />
			</div>
		</div>
	</div>
</div>
