<div class="waymker-nearby-page" style="max-width: 900px; margin: 20px auto; padding: 0 15px;">
  <h1 style="margin-bottom: 20px;"><i class="fa fa-map-marker-alt"></i> Users Near Me</h1>

  <div id="waymker-nearby-controls" style="margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
    <label style="margin-right: 10px;">Radius (miles):
      <input type="number" id="waymker-radius" value="" placeholder="Any" style="width: 80px; padding: 5px;" />
    </label>
    <label style="margin-right: 10px;">Limit:
      <input type="number" id="waymker-limit" value="50" min="1" max="200" style="width: 80px; padding: 5px;" />
    </label>
    <button id="waymker-refresh" class="btn btn-primary" style="padding: 6px 16px;">Refresh</button>
  </div>

  <div id="waymker-nearby-status" style="margin-bottom: 15px; color: #666;">Loading...</div>

  <div id="waymker-nearby-results"></div>
</div>

<script>
(function() {
  var statusEl = document.getElementById('waymker-nearby-status');
  var resultsEl = document.getElementById('waymker-nearby-results');
  var refreshBtn = document.getElementById('waymker-refresh');
  var radiusInput = document.getElementById('waymker-radius');
  var limitInput = document.getElementById('waymker-limit');

  function loadUsers() {
    statusEl.textContent = 'Loading...';
    resultsEl.innerHTML = '';

    var params = [];
    if (radiusInput.value) params.push('radius=' + encodeURIComponent(radiusInput.value));
    if (limitInput.value) params.push('limit=' + encodeURIComponent(limitInput.value));
    var url = '/api/v3/plugins/waymker-geo/users-near-me' + (params.length ? '?' + params.join('&') : '');

    fetch(url)
      .then(function(r) { return r.json(); })
      .then(function(data) {
        if (data.error) {
          statusEl.innerHTML = '<div style="color: #c00;">' + data.error + '</div>';
          return;
        }

        statusEl.textContent = 'Found ' + data.count + ' user' + (data.count === 1 ? '' : 's') + ' near you' + (data.isPrivileged ? ' (showing exact details)' : ' (showing neighborhood-level)');

        if (data.count === 0) {
          resultsEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #888;">No users found with location data.</div>';
          return;
        }

        var html = '';
        data.users.forEach(function(u) {
          var picture = u.picture || '/assets/images/default-avatar.png';
          var locationParts = [];
          if (u.neighborhood) locationParts.push(u.neighborhood);
          if (u.city) locationParts.push(u.city);
          if (u.state) locationParts.push(u.state);
          var locationStr = locationParts.join(', ') || 'Unknown location';

          var coordsStr = '';
          if (data.isPrivileged && u.latitude && u.longitude) {
            coordsStr = '<div style="font-size: 11px; color: #999;">' + u.latitude.toFixed(4) + ', ' + u.longitude.toFixed(4) + '</div>';
          }

          html += '<div style="display: flex; align-items: center; padding: 12px; border-bottom: 1px solid #eee; gap: 15px;">';
          html += '<img src="' + picture + '" alt="" style="width: 48px; height: 48px; border-radius: 50%; object-fit: cover;" onerror="this.style.display=\'none\'" />';
          html += '<div style="flex: 1;">';
          html += '<div style="font-weight: 600;"><a href="/user/' + u.userslug + '" style="color: inherit; text-decoration: none;">' + u.username + '</a></div>';
          html += '<div style="color: #666; font-size: 14px;">' + locationStr + '</div>';
          html += coordsStr;
          html += '</div>';
          html += '<div style="text-align: right;">';
          html += '<div style="font-weight: 600; color: #0066cc;">' + u.distance.toFixed(1) + ' mi</div>';
          html += '</div>';
          html += '</div>';
        });
        resultsEl.innerHTML = html;
      })
      .catch(function(e) {
        statusEl.innerHTML = '<div style="color: #c00;">Error loading users: ' + e.message + '</div>';
      });
  }

  refreshBtn.addEventListener('click', loadUsers);
  loadUsers();
})();
</script>
