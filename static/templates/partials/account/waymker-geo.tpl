<!--
	Geo profile fields partial.

	Themes can include this with:
	    <!-- IMPORT partials/account/waymker-geo.tpl -->
	inside their account/edit.tpl.

	If your theme is unmodified, the alternative is to inject this fragment
	via filter:user.account.edit and a small jQuery snippet that targets the
	right wrapper on the edit page.
-->
<div data-waymker-geo-root class="waymker-geo-edit card mb-3">
	<div class="card-header fw-bold">
		<i class="fa fa-map-marker-alt me-1"></i> Location
	</div>
	<div class="card-body">

		<div class="mb-3 position-relative">
			<label class="form-label" for="waymker-geo-address">Search address</label>
			<input type="text" id="waymker-geo-address" name="geo:address"
				class="form-control" autocomplete="off"
				value="{userData.waymkerGeo.fields.0.value}"
				placeholder="Start typing your address..." />
			<div data-waymker-geo-suggestions class="list-group position-absolute w-100 shadow-sm"
				style="z-index: 30; top: 100%; display: none;"></div>
			<div class="form-text">
				Pick a result to auto-fill the components below. Each component has its own privacy toggle.
			</div>
		</div>

		<!-- BEGIN userData.waymkerGeo.fields -->
		<!-- IF !@first -->
		<div class="row mb-2 align-items-center">
			<label class="col-sm-3 col-form-label" for="waymker-{./key}">{./label}</label>
			<div class="col-sm-6">
				<input type="text" id="waymker-{./key}" name="{./key}"
					class="form-control form-control-sm" value="{./value}" />
			</div>
			<div class="col-sm-3">
				<button type="button"
					class="btn btn-outline-secondary btn-sm w-100"
					data-waymker-privacy-cycle
					data-field="{./key}"
					data-current="{./privacy}">
					<i data-waymker-privacy-icon class="fa fa-lock me-1"></i>
					<span data-waymker-privacy-label>Only me</span>
				</button>
				<input type="hidden" name="{./key}:privacy" value="{./privacy}" />
			</div>
		</div>
		<!-- ENDIF !@first -->
		<!-- END userData.waymkerGeo.fields -->

	</div>
</div>
