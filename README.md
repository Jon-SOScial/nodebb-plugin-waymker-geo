# nodebb-plugin-waymker-geo

Adds **geo-aware profile fields** to NodeBB users and groups, powered by
Mapbox geocoding, with **per-field privacy toggles**. A single address
input autocompletes via Mapbox; selecting a suggestion populates street,
city, state, zip, neighborhood, country, and lat/lng — each with its
own visibility level (`public` / `registered` / `followers` / `private`).

This plugin is the **data + API layer**. A separate plugin renders a
Leaflet map by consuming the JSON API exposed here (see "Companion map
plugin" below).

Compatibility: NodeBB **^4.0.0**.

---

## What this plugin does

1. Adds these whitelisted user fields:
   `geo:address`, `geo:street`, `geo:city`, `geo:state`, `geo:zip`,
   `geo:neighborhood`, `geo:country`, `geo:lat`, `geo:lng`.
2. Adds a per-field privacy companion: `geo:address:privacy`,
   `geo:city:privacy`, etc.
3. Authoritatively re-geocodes any submitted `geo:address` server-side
   so the lat/lng on file always matches the address (clients can't
   forge coordinates).
4. Mirrors the same fields on **groups** (single visibility — group
   profiles are already gated by group privacy/membership).
5. Lets a future composer extension attach `geoLat` / `geoLng` /
   `geoLabel` to topics and posts.
6. Exposes a JSON API for the map plugin to query users-near-point,
   posts-near-point, and individual user/group geo data.

It does **not** ship a map UI. That's intentional — see the companion
plugin section.

---

## Install

You're running NodeBB inside a Frappe-style Docker compose on Hostinger,
so the install path is slightly different than vanilla NodeBB:

### From inside your NodeBB container

```bash
# enter the NodeBB container
docker exec -it <your-nodebb-container> bash

cd /usr/src/nodebb   # or wherever NodeBB lives in your image
npm install /path/to/nodebb-plugin-waymker-geo
```

### Or by URL (recommended for production)

```bash
npm install https://github.com/your-org/nodebb-plugin-waymker-geo
```

### Activate

1. `./nodebb build && ./nodebb restart` (inside the container).
2. Go to **ACP → Extend → Plugins**, find **nodebb-plugin-waymker-geo**,
   click **Activate**.
3. Rebuild + restart again so client assets pick up.
4. Go to **ACP → Plugins → Waymker Geo** and paste a Mapbox public token
   (`pk....`). Optionally restrict the geocoder to a country code.

### Mapbox token

Create a public token at https://account.mapbox.com/access-tokens. In
the token settings, set a URL allow-list to `https://crm.waymker.com/*`
so the token can't be reused off-domain. The token is held server-side
by this plugin and used via the `/api/v3/plugins/waymker-geo/geocode`
proxy — the browser never sees it directly.

---

## How users get their geo fields

After activation, the partial template
`partials/account/waymker-geo.tpl` ships with the plugin. Themes can
include it like:

```html
<!-- IMPORT partials/account/waymker-geo.tpl -->
```

inside `account/edit.tpl`. The default Persona/Harmony themes don't
import third-party partials automatically, so you have two paths:

**Option A — fork the theme.** Add the IMPORT line in your theme's
`account/edit.tpl`. This is the cleanest path if you already maintain
a custom theme.

**Option B — DOM injection from a small theme tweak.** Create a tiny
companion plugin (or use `nodebb-plugin-customize`) that runs after
ajaxify on the edit page and inserts the rendered fragment near the
existing form. The fragment has `data-waymker-geo-root` so the JS
binds to it wherever it lands.

The same pattern applies to group fields and
`partials/groups/waymker-geo.tpl`.

---

## API endpoints (for the map plugin to consume)

All endpoints follow NodeBB's v3 API envelope: responses come back as
`{ status, response }`.

### `GET /api/v3/plugins/waymker-geo/geocode?q=<query>&limit=5`
Auth: requires login (used by autocomplete). Server-side proxy to
Mapbox forward geocoding.

```json
{ "response": { "results": [
  { "address": "123 Main St, Conroe, TX 77301, USA",
    "street": "123 Main St", "city": "Conroe", "state": "TX",
    "zip": "77301", "neighborhood": "", "country": "United States",
    "lat": 30.31, "lng": -95.46, "mapboxId": "address.123..." }
] } }
```

### `GET /api/v3/plugins/waymker-geo/users-near?lat=&lng=&radius=&limit=`
Auth: requires login. Returns users with mappable coordinates
(respecting per-user privacy) within `radius` km of the point. `radius`
default 50, max 500. `limit` default 100, max 500.

### `GET /api/v3/plugins/waymker-geo/user/:uid`
Auth: optional. Returns the privacy-redacted geo payload for a single
user, as the caller is allowed to see it.

### `GET /api/v3/plugins/waymker-geo/group/:slug`
Auth: optional. Returns geo data for a group.

### `GET /api/v3/plugins/waymker-geo/posts-near?lat=&lng=&radius=&limit=`
Auth: optional. Returns topics (with attached coordinates) within
range. Each result is privilege-checked — callers only see topics in
categories they can read.

---

## Privacy model

Each geo field has a companion `<field>:privacy` value:

| Level        | Visible to                               |
|--------------|------------------------------------------|
| `public`     | Everyone, including guests               |
| `registered` | Any logged-in user                       |
| `followers`  | Mutual follows (caller follows target AND target follows caller) |
| `private`    | Only the owner (and admins / global mods) |

Defaults are conservative: street and exact lat/lng default to
`private`; city/neighborhood default to `registered`; state and country
default to `public`. Owners can change any of these.

Admins and global mods always see everything — this is consistent with
how NodeBB handles other PII.

---

## Companion map plugin

The map renderer should be a separate plugin
(suggested name: `nodebb-plugin-waymker-map`). Its job:

1. Load Leaflet (npm: `leaflet`, `leaflet.markercluster`).
2. Add a `/map` route + template.
3. Call `/api/v3/plugins/waymker-geo/users-near` and
   `/api/v3/plugins/waymker-geo/posts-near` to populate markers.
4. Fall back gracefully if this plugin isn't activated (feature-detect
   the endpoint).

That separation matters: this plugin is hard to break (no UI surface
besides ACP + a partial), and the map plugin can be redesigned or
swapped (Leaflet → MapLibre → Mapbox GL) without touching the data
layer.

---

## Scaling notes

`users-near` and `posts-near` currently scan the most-recent N records
(5000 users, 2000 topics) and filter in Node. That's fine for forums up
to ~10k active users. Past that, add a secondary geo index:

- On user save, also write to a sorted set per latitude bucket:
  `users:geo:lat:30` → `<uid>` scored by lng (or use geohash buckets).
- Then `users-near` only scans the relevant 1–4 buckets around the
  query point.

Hook up via `action:user.set` and `action:user.updateProfile`. The same
pattern applies to topics with `action:topic.save`.

If you outgrow that, push lat/lng to a real geo index (Postgres + PostGIS,
or Redis 6.2+ `GEOADD`) and have the controllers query that instead.

---

## Hooks used

| Hook                          | Why                                              |
|-------------------------------|--------------------------------------------------|
| `static:app.load`             | Register routes, load settings                   |
| `filter:admin.header.build`   | ACP nav entry                                    |
| `filter:user.whitelistFields` | Permit our fields on the user hash               |
| `filter:user.updateProfile`   | Allow + validate + re-geocode on save            |
| `filter:user.account.edit`    | Inject edit-page payload                         |
| `filter:user.account`         | Inject view-page payload (privacy redacted)      |
| `filter:user.getFields`       | Hook point for further redaction (passthrough)   |
| `filter:group.get`            | Attach group geo to group payload                |
| `action:group.update`         | Save group geo on update                         |
| `filter:topic.create`         | Attach coords to a new topic                     |
| `filter:post.create`          | Attach coords to a new post                      |
| `filter:topic.build`          | Expose attached coords to the topic template     |

---

## Files

```
nodebb-plugin-waymker-geo/
├── package.json
├── plugin.json
├── library.js                       # main entry, hook orchestration
├── lib/
│   ├── controllers.js               # HTTP handlers
│   ├── geocode.js                   # Mapbox API wrapper (no extra deps)
│   ├── privacy.js                   # privacy levels + redaction
│   └── groups.js                    # group geo storage
├── static/
│   ├── lib/
│   │   ├── profile-edit.js          # client: address autocomplete + privacy cycle
│   │   ├── group-edit.js            # client: group address autocomplete
│   │   └── admin.js                 # ACP page handler
│   └── templates/
│       ├── admin/plugins/waymker-geo.tpl
│       └── partials/
│           ├── account/waymker-geo.tpl
│           └── groups/waymker-geo.tpl
└── languages/en-US/mapbox-geo.json
```

---

## License

MIT.
