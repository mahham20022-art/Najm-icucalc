/* Najm ICUCalc — Production Service Worker
   v15 · offline-first · versioned caches · graceful fallback.
   Split caches:
     PRECACHE  = app-shell that MUST be there for offline first-paint
     RUNTIME   = network-first HTML (updates land instantly on refresh)
     ASSETS    = cache-first for icons/CSS/JS/manifest (stable)
     FONTS     = stale-while-revalidate for Google Fonts
     IMAGES    = cache-first with size cap for user-added images
*/
const VERSION  = "v15";
const PRECACHE = `najm-precache-${VERSION}`;
const RUNTIME  = `najm-runtime-${VERSION}`;
const ASSETS   = `najm-assets-${VERSION}`;
const FONTS    = `najm-fonts-${VERSION}`;
const IMAGES   = `najm-images-${VERSION}`;
const ALL_CACHES = [PRECACHE, RUNTIME, ASSETS, FONTS, IMAGES];

// App shell — loaded on first install so the app opens offline immediately.
const APP_SHELL = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./privacy-policy.html",
  "./icons/favicon.ico",
  "./icons/favicon-32.png",
  "./icons/apple-touch.png",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/icon-maskable-192.png",
  "./icons/icon-maskable-512.png",
];

/* ── install ── */
self.addEventListener("install", event => {
  event.waitUntil(
    caches.open(PRECACHE)
      .then(cache => cache.addAll(APP_SHELL).catch(() => {}))
      .then(() => self.skipWaiting())
  );
});

/* ── activate ── purge every older Najm cache, take control of open pages ── */
self.addEventListener("activate", event => {
  event.waitUntil(
    caches.keys().then(keys => Promise.all(
      keys.filter(k => k.startsWith("najm-") && !ALL_CACHES.includes(k))
          .map(k => caches.delete(k))
    )).then(() => self.clients.claim())
  );
});

/* ── message ── skipWaiting handshake for silent auto-update ── */
self.addEventListener("message", event => {
  if (event.data && event.data.type === "SKIP_WAITING") self.skipWaiting();
});

/* ── helpers ── */
async function networkFirstHTML(req) {
  const cache = await caches.open(RUNTIME);
  try {
    const res = await fetch(req);
    if (res && res.status === 200 && res.type === "basic") cache.put(req, res.clone());
    return res;
  } catch (_) {
    return (await cache.match(req)) ||
           (await caches.match("./index.html")) ||
           new Response(offlinePage(), { status: 200, headers: { "Content-Type": "text/html; charset=utf-8" } });
  }
}
async function cacheFirst(req, cacheName) {
  const cache = await caches.open(cacheName);
  const hit = await cache.match(req);
  if (hit) return hit;
  try {
    const res = await fetch(req);
    if (res && res.status === 200) cache.put(req, res.clone());
    return res;
  } catch (_) {
    return hit || Response.error();
  }
}
async function staleWhileRevalidate(req, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(req);
  const fetchPromise = fetch(req).then(res => {
    if (res && res.status === 200) cache.put(req, res.clone());
    return res;
  }).catch(() => null);
  return cached || fetchPromise || Response.error();
}

/* ── minimal offline fallback if index.html itself isn't cached yet ── */
function offlinePage() {
  return `<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Najm ICUCalc — offline</title>
<style>body{margin:0;font-family:system-ui,-apple-system,sans-serif;background:#071A2F;color:#eaf1fb;display:grid;place-items:center;min-height:100vh;text-align:center;padding:24px}h1{font-size:22px;margin:0 0 8px;color:#22d3ee}p{color:#8aa0bd;line-height:1.6;max-width:32ch}</style>
<h1>You're offline</h1><p>Najm ICUCalc needs one online load to install. Reconnect and reload to install the offline app-shell.</p>`;
}

/* ── fetch router ── */
self.addEventListener("fetch", event => {
  const req = event.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);

  // Google Fonts — SWR
  if (url.origin === "https://fonts.googleapis.com" || url.origin === "https://fonts.gstatic.com") {
    event.respondWith(staleWhileRevalidate(req, FONTS));
    return;
  }

  // Never intercept analytics or 3rd-party APIs — let them go to network.
  if (url.origin !== self.location.origin) return;

  // Navigations / HTML → network-first with offline fallback
  const isHTML = req.destination === "document" || req.mode === "navigate" ||
                 url.pathname.endsWith(".html") || url.pathname.endsWith("/");
  if (isHTML) {
    event.respondWith(networkFirstHTML(req));
    return;
  }

  // Icons / images → cache-first
  if (req.destination === "image" || /\.(png|jpg|jpeg|gif|webp|svg|ico)$/i.test(url.pathname)) {
    event.respondWith(cacheFirst(req, IMAGES));
    return;
  }

  // Everything else (JS, CSS, manifest, JSON) → cache-first with revalidate
  event.respondWith(cacheFirst(req, ASSETS));
});
