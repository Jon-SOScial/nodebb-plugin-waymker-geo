<div class="waymker-nearby-page" style="max-width: 1000px; margin: 20px auto; padding: 0 15px;">
  <h1 style="margin-bottom: 25px;"><i class="fa fa-map-marker-alt"></i> Users Near Me</h1>

  <!-- Search Bar -->
  <div style="margin-bottom: 20px;">
    <input type="text" id="waymker-search" placeholder="Search by username..." style="width: 100%; padding: 12px; font-size: 14px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box;" />
  </div>

  <!-- Filter Controls -->
  <div id="waymker-filters" style="margin-bottom: 20px; padding: 15px; background: #f8f9fa; border-radius: 8px;">
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px;">
      
      <!-- Radius -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 5px;">Radius (miles)</label>
        <input type="number" id="waymker-radius" placeholder="Any" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;" />
      </div>

      <!-- Limit -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 5px;">Limit Results</label>
        <input type="number" id="waymker-limit" value="50" min="1" max="200" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;" />
      </div>

      <!-- Min Reputation -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 5px;">Min Reputation</label>
        <input type="number" id="waymker-minrep" placeholder="Any" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;" />
      </div>

      <!-- Role Type -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 5px;">Role Type</label>
        <select id="waymker-role" multiple style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
          <option value="">-- All Roles --</option>
          <option value="administrator">Administrator</option>
          <option value="moderator">Moderator</option>
          <option value="user">Regular User</option>
        </select>
      </div>

      <!-- Group Filter -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 5px;">Group</label>
        <select id="waymker-group" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
          <option value="">-- All Groups --</option>
        </select>
      </div>

      <!-- Friends Filter -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 5px;">Friends</label>
        <select id="waymker-friends" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box;">
          <option value="all">All Users</option>
          <option value="friends">My Friends Only</option>
          <option value="nonfriends">Not My Friends</option>
        </select>
      </div>
    </div>

    <button id="waymker-refresh" class="btn btn-primary" style="margin-top: 12px; padding: 8px 20px;">Apply Filters</button>
    <button id="waymker-reset" class="btn btn-secondary" style="margin-top: 12px; padding: 8px 20px; margin-left: 8px;">Reset</button>
  </div>

  <!-- Status -->
  <div id="waymker-nearby-status" style="margin-bottom: 15px; color: #666; font-size: 14px;"></div>

  <!-- Results -->
  <div id="waymker-nearby-results"></div>
</div>

<script>
(function() {
  var searchInput = document.getElementById('waymker-search');
  var statusEl = document.getElementById('waymker-nearby-status');
  var resultsEl = document.getElementById('waymker-nearby-results');
  var refreshBtn = document.getElementById('waymker-refresh');
  var resetBtn = document.getElementById('waymker-reset');
  var radiusInput = document.getElementById('waymker-radius');
  var limitInput = document.getElementById('waymker-limit');
  var minRepInput = document.getElementById('waymker-minrep');
  var roleSelect = document.getElementById('waymker-role');
  var groupSelect = document.getElementById('waymker-group');
  var friendsSelect = document.getElementById('waymker-friends');
  
  var allData = {};
  var displayedUsers = [];

  // Load groups on init
  function loadGroups() {
    fetch('/api/v3/groups')
      .then(function(r) { return r.json(); })
      .then(function(data) {
        if (data.groups) {
          data.groups.forEach(function(g) {
            var opt = document.createElement('option');
            opt.value = g.slug;
            opt.textContent = g.displayName || g.name;
            groupSelect.appendChild(opt);
          });
        }
      })
      .catch(function(e) { console.error('Error loading groups:', e); });
  }

  function loadUsers() {
    statusEl.textContent = 'Loading...';
    resultsEl.innerHTML = '';

    var params = [];
    if (radiusInput.value) params.push('radius=' + encodeURIComponent(radiusInput.value));
    if (limitInput.value) params.push('limit=' + encodeURIComponent(limitInput.value));
    if (minRepInput.value) params.push('minReputation=' + encodeURIComponent(minRepInput.value));
    
    var roles = [];
    for (var i = 0; i < roleSelect.options.length; i++) {
      if (roleSelect.options[i].selected && roleSelect.options[i].value) {
        roles.push(roleSelect.options[i].value);
      }
    }
    if (roles.length) params.push('roles=' + encodeURIComponent(roles.join(',')));
    
    if (groupSelect.value) params.push('group=' + encodeURIComponent(groupSelect.value));
    if (friendsSelect.value !== 'all') params.push('friends=' + encodeURIComponent(friendsSelect.value));

    var url = '/api/v3/plugins/waymker-geo/users-near-me' + (params.length ? '?' + params.join('&') : '');

    fetch(url)
      .then(function(r) { return r.json(); })
      .then(function(data) {
        if (data.error) {
          statusEl.innerHTML = '<div style="color: #c00;">' + data.error + '</div>';
          return;
        }

        allData = data;
        filterAndDisplay();
      })
      .catch(function(e) {
        statusEl.innerHTML = '<div style="color: #c00;">Error loading users: ' + e.message + '</div>';
      });
  }

  function filterAndDisplay() {
    var searchTerm = searchInput.value.toLowerCase();
    
    displayedUsers = allData.users.filter(function(u) {
      return !searchTerm || u.username.toLowerCase().indexOf(searchTerm) !== -1;
    });

    if (displayedUsers.length === 0) {
      statusEl.textContent = 'No users found matching your criteria.';
      resultsEl.innerHTML = '<div style="padding: 20px; text-align: center; color: #888;">Try adjusting your filters.</div>';
      return;
    }

    statusEl.textContent = 'Found ' + displayedUsers.length + ' user' + (displayedUsers.length === 1 ? '' : 's') + ' near you' + (allData.isPrivileged ? ' (showing exact details)' : '');

    var html = '';
    displayedUsers.forEach(function(u) {
      var picture = u.picture || '/assets/images/default-avatar.png';
      var locationParts = [];
      if (u.neighborhood) locationParts.push(u.neighborhood);
      if (u.city) locationParts.push(u.city);
      if (u.state) locationParts.push(u.state);
      var locationStr = locationParts.join(', ') || 'Unknown location';

      var coordsStr = '';
      if (allData.isPrivileged && u.latitude && u.longitude) {
        coordsStr = '<div style="font-size: 11px; color: #999;">' + u.latitude.toFixed(4) + ', ' + u.longitude.toFixed(4) + '</div>';
      }

      var repStr = '';
      if (u.reputation !== undefined) {
        repStr = '<div style="font-size: 12px; color: #888;">Reputation: ' + u.reputation + '</div>';
      }

      var roleStr = '';
      if (u.roles && u.roles.length > 0) {
        roleStr = '<div style="font-size: 11px; color: #0066cc;">' + u.roles.join(', ') + '</div>';
      }

      html += '<div style="display: flex; align-items: flex-start; padding: 12px; border-bottom: 1px solid #eee; gap: 15px;">';
      html += '<img src="' + picture + '" alt="" style="width: 48px; height: 48px; border-radius: 50%; object-fit: cover; flex-shrink: 0;" onerror="this.style.display=\'none\'" />';
      html += '<div style="flex: 1; min-width: 0;">';
      html += '<div style="font-weight: 600;"><a href="/user/' + u.userslug + '" style="color: inherit; text-decoration: none;">' + u.username + '</a></div>';
      html += '<div style="color: #666; font-size: 13px;">' + locationStr + '</div>';
      html += repStr;
      html += roleStr;
      html += coordsStr;
      html += '</div>';
      html += '<div style="text-align: right; flex-shrink: 0;">';
      html += '<div style="font-weight: 600; color: #0066cc; font-size: 16px;">' + u.distance.toFixed(1) + ' mi</div>';
      html += '</div>';
      html += '</div>';
    });
    resultsEl.innerHTML = html;
  }

  // Event listeners
  refreshBtn.addEventListener('click', loadUsers);
  resetBtn.addEventListener('click', function() {
    searchInput.value = '';
    radiusInput.value = '';
    limitInput.value = '50';
    minRepInput.value = '';
    roleSelect.value = '';
    groupSelect.value = '';
    friendsSelect.value = 'all';
    loadUsers();
  });

  searchInput.addEventListener('input', function() {
    if (allData.users) {
      filterAndDisplay();
    }
  });

  loadGroups();
  loadUsers();
})();
</script>
