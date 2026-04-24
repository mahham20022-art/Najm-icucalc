// MedEvidence service worker.
// Strategy:
//   - Pre-cache the app shell so the PWA opens instantly and works offline.
//   - Network-first for HTML so new deploys pick up on first online visit.
//   - Cache-first for static assets (icons, manifest).
//   - Never cache the /api/* origin: clinical data must always go to the server.

const VERSION = "medevidence-v1";
const SHELL = [
  "/",
  "/index.html",
  "/manifest.webmanifest",
  "/icons/icon-192.png",
  "/icons/icon-512.png",
  "/icons/icon-maskable-512.png",
  "/icons/apple-touch-icon-180.png",
  "/icons/apple-touch-icon-152.png",
  "/icons/favicon-32.png",
];

self.addEventListener("install", (event) => {
  event.waitUntil(
    caches.open(VERSION).then((cache) => cache.addAll(SHELL)).then(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== VERSION).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (event) => {
  const req = event.request;
  if (req.method !== "GET") return;

  const url = new URL(req.url);

  // Never touch clinical API traffic.
  if (url.pathname.startsWith("/api/") || url.pathname.startsWith("/health")) return;

  // Network-first for HTML documents.
  const isHTML = req.mode === "navigate" || (req.headers.get("accept") || "").includes("text/html");
  if (isHTML) {
    event.respondWith(
      fetch(req)
        .then((resp) => {
          const copy = resp.clone();
          caches.open(VERSION).then((cache) => cache.put(req, copy));
          return resp;
        })
        .catch(() => caches.match(req).then((r) => r || caches.match("/index.html")))
    );
    return;
  }

  // Cache-first for everything else (icons, manifest, CDN scripts that are same-origin proxied).
  event.respondWith(
    caches.match(req).then(
      (cached) =>
        cached ||
        fetch(req).then((resp) => {
          if (resp && resp.status === 200 && resp.type === "basic") {
            const copy = resp.clone();
            caches.open(VERSION).then((cache) => cache.put(req, copy));
          }
          return resp;
        })
    )
  );
});
