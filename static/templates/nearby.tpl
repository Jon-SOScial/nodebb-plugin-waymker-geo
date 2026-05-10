<div class="waymker-nearby-page" style="max-width: 1200px; margin: 0 auto; padding: 20px;">
  <h1 style="margin-bottom: 30px; font-size: 32px;"><i class="fa fa-map-marker-alt"></i> Users Near Me</h1>

  <!-- Search Bar -->
  <div style="margin-bottom: 25px;">
    <input type="text" id="waymker-search" placeholder="Search by username..." style="width: 100%; padding: 14px 16px; font-size: 15px; border: 1px solid #ddd; border-radius: 6px; box-sizing: border-box; box-shadow: 0 1px 3px rgba(0,0,0,0.05);" />
  </div>

  <!-- Filter Section -->
  <div style="background: white; border: 1px solid #e0e0e0; border-radius: 8px; padding: 24px; margin-bottom: 25px;">
    <h3 style="margin: 0 0 20px 0; font-size: 16px; font-weight: 700;">Filters</h3>
    
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 18px; margin-bottom: 20px;">
      
      <!-- Radius -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #333;">Radius (miles)</label>
        <input type="number" id="waymker-radius" placeholder="Any distance" style="width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; font-size: 14px;" />
      </div>

      <!-- Limit -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #333;">Results Limit</label>
        <input type="number" id="waymker-limit" value="50" min="1" max="200" style="width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; font-size: 14px;" />
      </div>

      <!-- Min Reputation -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #333;">Min Reputation</label>
        <input type="number" id="waymker-minrep" placeholder="Any reputation" style="width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; font-size: 14px;" />
      </div>

      <!-- Role Type -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #333;">Role</label>
        <select id="waymker-role" style="width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; font-size: 14px;">
          <option value="">-- Any Role --</option>
          <option value="administrator">Administrator</option>
          <option value="moderator">Moderator</option>
          <option value="user">Regular User</option>
        </select>
      </div>

      <!-- Group Filter -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #333;">Group</label>
        <select id="waymker-group" style="width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; font-size: 14px;">
          <option value="">-- Any Group --</option>
          <option value="loading" disabled>Loading groups...</option>
        </select>
      </div>

      <!-- Friends Filter -->
      <div>
        <label style="display: block; font-weight: 600; margin-bottom: 8px; font-size: 13px; color: #333;">Friends</label>
        <select id="waymker-friends" style="width: 100%; padding: 10px 12px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; font-size: 14px;">
          <option value="all">All Users</option>
          <option value="friends">My Friends Only</option>
          <option value="nonfriends">Not My Friends</option>
        </select>
      </div>
    </div>

    <div style="display: flex; gap: 10px;">
      <button id="waymker-refresh" class="btn btn-primary" style="padding: 10px 24px; font-weight: 600;">Apply Filters</button>
      <button id="waymker-reset" class="btn btn-secondary" style="padding: 10px 24px; font-weight: 600;">Reset</button>
    </div>
  </div>

  <!-- Status -->
  <div id="waymker-nearby-status" style="margin-bottom: 20px; color: #555; font-size: 14px; font-weight: 500;"></div>

  <!-- Results Container -->
  <div id="waymker-nearby-results" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 16px;"></div>
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

  function loadGroups() {
    fetch('/api/v3/groups?truncate=true')
      .then(function(r) { return r.json(); })
      .then(function(data) {
        console.log('[waymker-geo] Groups response:', data);
        var groupsList = [];
        if (data.response && data.response.groups && Array.isArray(data.response.groups)) {
          groupsList = data.response.groups;
        } else if (data.response && Array.isArray(data.response)) {
          groupsList = data.response;
        } else if (data.groups && Array.isArray(data.groups)) {
          groupsList = data.groups;
        } else if (Array.isArray(data)) {
          groupsList = data;
        }
        
        if (groupsList && groupsList.length > 0) {
          groupSelect.innerHTML = '<option value="">-- Any Group --</option>';
          groupsList.forEach(function(g) {
            var name = typeof g === 'string' ? g : (g.displayName || g.name || '');
            var slug = typeof g === 'string' ? g : (g.slug || g.name || '');
            if (name && slug && name.toLowerCase() !== 'administrators') {
              var opt = document.createElement('option');
              opt.value = slug;
              opt.textContent = name;
              groupSelect.appendChild(opt);
            }
          });
          console.log('[waymker-geo] Groups loaded: ' + (groupSelect.options.length - 1));
        } else {
          groupSelect.innerHTML = '<option value="">-- No Groups Found --</option>';
        }
      })
      .catch(function(e) { 
        console.error('[waymker-geo] Error loading groups:', e);
        groupSelect.innerHTML = '<option value="">-- Error Loading --</option>';
      });
  }

  function loadUsers() {
    statusEl.textContent = 'Loading...';
    resultsEl.innerHTML = '';

    var params = [];
    if (radiusInput.value) params.push('radius=' + encodeURIComponent(radiusInput.value));
    if (limitInput.value) params.push('limit=' + encodeURIComponent(limitInput.value));
    if (minRepInput.value) params.push('minReputation=' + encodeURIComponent(minRepInput.value));
    if (roleSelect.value) params.push('roles=' + encodeURIComponent(roleSelect.value));
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
        statusEl.innerHTML = '<div style="color: #c00;">Error: ' + e.message + '</div>';
      });
  }

  function filterAndDisplay() {
    var searchTerm = searchInput.value.toLowerCase();
    displayedUsers = allData.users.filter(function(u) {
      return !searchTerm || u.username.toLowerCase().indexOf(searchTerm) !== -1;
    });

    if (displayedUsers.length === 0) {
      statusEl.textContent = 'No users found.';
      resultsEl.innerHTML = '<div style="grid-column: 1/-1; padding: 40px 20px; text-align: center; color: #888;">No matching users found.</div>';
      return;
    }

    statusEl.textContent = 'Found ' + displayedUsers.length + ' user' + (displayedUsers.length === 1 ? '' : 's');

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
        coordsStr = '<div style="font-size: 12px; color: #999; margin-top: 8px; padding-top: 8px; border-top: 1px solid #f0f0f0;">' + u.latitude.toFixed(4) + ', ' + u.longitude.toFixed(4) + '</div>';
      }

      var repStr = u.reputation !== undefined ? '<div style="font-size: 13px; color: #666; margin-top: 4px;">💎 ' + u.reputation + '</div>' : '';
      var roleStr = '';
      if (u.roles && u.roles.length > 0) {
        var roleNames = u.roles.map(function(role) {
          return typeof role === 'string' ? role : (role.displayName || role.name || role.slug || '');
        }).filter(function(name) { return name && name.length > 0; });
        if (roleNames.length > 0) {
          roleStr = '<div style="font-size: 12px; color: #0066cc; margin-top: 6px;">👥 ' + roleNames.join(', ') + '</div>';
        }
      }

      html += '<div style="background: white; border: 1px solid #e0e0e0; border-radius: 8px; padding: 16px;">';
      html += '<div style="display: flex; gap: 12px; margin-bottom: 12px;">';
      html += '<img src="' + picture + '" alt="" style="width: 48px; height: 48px; border-radius: 50%; object-fit: cover;" onerror="this.style.display=\'none\'" />';
      html += '<div style="flex: 1;">';
      html += '<div style="font-weight: 700;"><a href="/user/' + u.userslug + '" style="color: inherit; text-decoration: none;">' + u.username + '</a></div>';
      html += '<div style="color: #666; font-size: 13px;">📍 ' + locationStr + '</div>';
      html += '</div>';
      html += '</div>';
      html += repStr + roleStr + coordsStr;
      html += '<div style="margin-top: 12px; padding-top: 12px; border-top: 1px solid #f5f5f5; text-align: right;">';
      html += '<div style="font-weight: 700; color: #0066cc;">' + u.distance.toFixed(1) + ' mi</div>';
      html += '</div>';
      html += '</div>';
    });
    resultsEl.innerHTML = html;
  }

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
