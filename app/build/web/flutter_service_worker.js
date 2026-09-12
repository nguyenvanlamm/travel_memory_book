'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"manifest.json": "d41d8cd98f00b204e9800998ecf8427e",
"favicon.png": "a7e6427cbd15f4b8f08b0f22fdee8bc1",
"icons/Icon-maskable-512.png": "ad689a1a0d117846dfd1f7c885dffa56",
"icons/Icon-192.png": "f45dc0e7f7a19bb06976f44515837efb",
"icons/Icon-maskable-192.png": "f45dc0e7f7a19bb06976f44515837efb",
"icons/Icon-512.png": "ad689a1a0d117846dfd1f7c885dffa56",
"flutter_bootstrap.js": "87b033c0bd08142d70fb737f526f1244",
"index.html": "172550859559d0278699145d4812a874",
"/": "172550859559d0278699145d4812a874",
"flutter.js": "f393d3c16b631f36852323de8e583132",
"main.dart.js": "16d70561589354d3c3aa1400f5208d28",
"assets/NOTICES": "72f411fe8a0fc8a93af4751f637c130a",
"assets/fonts/MaterialIcons-Regular.otf": "318a3c8374d077e9951852064451890d",
"assets/FontManifest.json": "0f52fa0164a03befb8b4cd2a1ed86ebf",
"assets/assets/fonts/inter-semibold.ttf": "84cf795ee940a39423fbee3dad4017c1",
"assets/assets/fonts/playfair-medium.ttf": "5f616827eb32923ea975f499a666192a",
"assets/assets/fonts/inter-medium.ttf": "eb0312411b133c48049ac630ab7f1fec",
"assets/assets/fonts/syne-bold.ttf": "f17a3b5e2d7a7a5535afd3859a3e731e",
"assets/assets/fonts/merriweather-bold.ttf": "09456aa2fd560c0b5ff73955961395b9",
"assets/assets/fonts/inter-regular.ttf": "a32ace5dba8400232b84bc017dcc38ef",
"assets/assets/fonts/playfair-regular.ttf": "87fac2f24d663acfb7a331f46b2ce1b2",
"assets/assets/fonts/playfair-semibold.ttf": "4f78e5e3d3ad2037f425644f05bf1ea9",
"assets/assets/fonts/merriweather-italic.ttf": "e792058e85328324c686ec989a48891b",
"assets/assets/fonts/merriweather-regular.ttf": "6cb4ed4a377ef68876f4fa093c31b4f0",
"assets/assets/fonts/syne-semibold.ttf": "184923f3808e4b734cc2b7e64b24bdce",
"assets/assets/fonts/playfair-italic.ttf": "b5febda5baa5f8ff10ef63127cb40ba3",
"assets/assets/fonts/playfair-bold.ttf": "3e8fa83ca949311ffbc59fc5cbfce9ea",
"assets/assets/fonts/inter-bold.ttf": "c59d7314123c3b770bfbbd994215805c",
"assets/assets/audio/page-flip-soft.wav": "4b5131ce686a5b57eae970184a771af2",
"assets/assets/audio/page-flip-soft.mp3": "f8f91ff118ab2846fcf95fcdaf13b193",
"assets/assets/illustrations/travelers.svg": "842183a09b55e09a44ba896cb5955c17",
"assets/assets/illustrations/journey.svg": "4a76e293243e28440c665a39f70fe5cf",
"assets/assets/images/logo-mark.svg": "4ad231fcba5b434356e6bc051da53468",
"assets/assets/images/book/edge-shadow-right.png": "584bdda51cc9425de45e0c3e3864fe56",
"assets/assets/images/book/edge-shadow-left.png": "4f54a2224d58c390c8f984a45b328fee",
"assets/assets/images/book/paper-texture.png": "2eafd7d6bd6a102ab824de496fe26415",
"assets/assets/images/book/lined-paper.png": "8d2632d297c46ba969100183a7f82979",
"assets/assets/images/logo-icon.svg": "4b3aeb5af47f4bf714012f2a9d68c4ce",
"assets/AssetManifest.bin.json": "fe06595a40e9a5291536329e703306ea",
"assets/packages/lucide_icons/assets/lucide.ttf": "03f254a55085ec6fe9a7ae1861fda9fd",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "e986ebe42ef785b27164c36a9abc7818",
"assets/AssetManifest.bin": "c901fc75f9612b7bf10fce5c7f8ace93",
"assets/AssetManifest.json": "0590819a67ff3812346e2d2b8b676a72",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/wimp.js": "40195751139ab9e4b7c62b19c420f63b",
"canvaskit/experimental_webparagraph/canvaskit.js.symbols": "0c6d97b036dffdc0f4bc4552ae7b5c9d",
"canvaskit/experimental_webparagraph/canvaskit.js": "230c0e2b182dcd1061c06c2fe7b64b5f",
"canvaskit/experimental_webparagraph/canvaskit.wasm": "e008e87c245b0718932b34e9a15be803",
"canvaskit/skwasm_heavy.js.symbols": "455930e12e6ef2d961627fe6f0c0cd0c",
"canvaskit/wimp.wasm": "9242e201530449825b5645ed3d5af22c",
"canvaskit/skwasm.js": "694fda5704053957c2594de355805228",
"canvaskit/wimp.js.symbols": "e9ac11318ebff9b7ad24ca7841f69b3f",
"canvaskit/canvaskit.js.symbols": "48c83a2ce573d9692e8d970e288d75f7",
"canvaskit/canvaskit.js": "66177750aff65a66cb07bb44b8c6422b",
"canvaskit/skwasm.js.symbols": "262f4827a1317abb59d71d6c587a93e2",
"canvaskit/canvaskit.wasm": "1f237a213d7370cf95f443d896176460",
"canvaskit/skwasm.worker.js": "89990e8c92bcb123999aa81f7e203b1c",
"canvaskit/skwasm_heavy.wasm": "f22698a773ef756eff818039e37be5c3",
"canvaskit/skwasm_heavy.js": "19b2126c270db6dde2255bec30c3e4f9",
"canvaskit/chromium/canvaskit.js.symbols": "a012ed99ccba193cf96bb2643003f6fc",
"canvaskit/chromium/canvaskit.js": "671c6b4f8fcc199dcc551c7bb125f239",
"canvaskit/chromium/canvaskit.wasm": "b1ac05b29c127d86df4bcfbf50dd902a",
"canvaskit/skwasm.wasm": "9f0c0c02b82a910d12ce0543ec130e60",
"version.json": "46779a55aa2bf170286022a9fa3d44b0"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
