const CACHE_NAME = 'lil-agents-v1';
const ASSETS_TO_CACHE = [
  './',
  './index.html',
  './style.css',
  './app.js',
  './manifest.json',
  './assets/apple-touch-icon.png',
  './assets/walk-bruce-01.mov',
  './assets/walk-jazz-01.mov',
  './assets/sounds/ping-aa.mp3',
  './assets/sounds/ping-bb.mp3',
  './assets/sounds/ping-cc.mp3',
  './assets/sounds/ping-dd.mp3',
  './assets/sounds/ping-ee.mp3',
  './assets/sounds/ping-ff.mp3',
  './assets/sounds/ping-gg.mp3',
  './assets/sounds/ping-hh.mp3'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(ASSETS_TO_CACHE).catch((err) => {
        console.warn('Some assets could not be cached immediately:', err);
      });
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (key !== CACHE_NAME) {
            return caches.delete(key);
          }
        })
      );
    })
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    caches.match(event.request).then((response) => {
      return response || fetch(event.request);
    })
  );
});
