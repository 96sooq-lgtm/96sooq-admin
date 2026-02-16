'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"flutter_bootstrap.js": "124269c15c69c3a444e330d849f4e1e7",
"version.json": "461b4cc271f7955d64085fe1a0b58bd6",
"index.html": "31428d267be6edbf1b7f899e885d75da",
"/": "31428d267be6edbf1b7f899e885d75da",
"main.dart.js": "c8ed194d9f7b8983783c296f89d4b97c",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"favicon.png": "aa1bd4c8c0d00d31d6508e276580e483",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"manifest.json": "4e692bd5ea5e1ce6fc195788507ded47",
"assets/NOTICES": "d477bc3e41cb7091aaecf91883a8e275",
"assets/FontManifest.json": "0aeab28cb67c170b25266678caa73cdb",
"assets/AssetManifest.bin.json": "7a3cf5b48c0a057f3de461dabd8059d2",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"assets/AssetManifest.bin": "e742762edab3934a1be8b81b87e2d06d",
"assets/fonts/MaterialIcons-Regular.otf": "5f46cd9e9646048cf4e0eb28608d450c",
"assets/assets/icons/listing.svg": "397909b8eca68229ddaf93e7d70016ec",
"assets/assets/icons/payment_selected.svg": "5560d9a08b2a5cec3184a62196df6779",
"assets/assets/icons/terms_and_condition_unselected.svg": "9e647d2864cbc70422e2cff1750d6666",
"assets/assets/icons/subscription_unselected.svg": "66142f1438a0b596e0c5fc4939426b89",
"assets/assets/icons/app_icon.png": "aa1bd4c8c0d00d31d6508e276580e483",
"assets/assets/icons/category_selected.svg": "c48f2e4bab771b4e1cb68a5177d83a36",
"assets/assets/icons/user_management_selected.svg": "60aa07713fdf1382f48b8e1d2538158e",
"assets/assets/icons/subscription_selected.svg": "32ca5df644bcba4295732999a9c8bc9a",
"assets/assets/icons/deals.svg": "187f23013bcdd0d99c7d12774ca9dd17",
"assets/assets/icons/request_approval_selected.svg": "ce8591fb19ce100a0d98c76815d480bb",
"assets/assets/icons/request_approval_unselected.svg": "bedc2a08ba99dff989db967ba877fb6f",
"assets/assets/icons/ad_banner_selected.svg": "75ed20e84744353dee37a048bb63477b",
"assets/assets/icons/add_banner.svg": "8b32196fdda6755d306bdc7a4953d15f",
"assets/assets/icons/pending_request.svg": "37b511059cf0b4cca4e08b18f0d565d2",
"assets/assets/icons/store_ic.svg": "3a18b3b31ad7c1498be269acac7577bc",
"assets/assets/icons/total_users.svg": "e3ddadc187ea31e58ebb62a567d7bb3a",
"assets/assets/icons/settings_unselected.svg": "7dae56ddda9e6aae20129230a330a9d0",
"assets/assets/icons/terms_and_condition_selected.svg": "4254e2bd5e1cb675dbe2cf7ef5b536a3",
"assets/assets/icons/offer_listing_unselected.svg": "f95238a4623e1bd175e6684da7e8965e",
"assets/assets/icons/96_sooq_logo.png": "4e96320bf2852d7572c136a0d9ca4cb4",
"assets/assets/icons/home_selected.svg": "26a40d004ccaffb029b3072335f9732e",
"assets/assets/icons/category_unselected.svg": "4dc5b49ddb1159ff1af6ec212917153a",
"assets/assets/icons/subcategory_selected.svg": "96eca69705460d672ff49140ce66931d",
"assets/assets/icons/ad_banner_unselected.svg": "8b32196fdda6755d306bdc7a4953d15f",
"assets/assets/icons/payment_unselected.svg": "f8687183cb91fc0ff5d89667f3868dee",
"assets/assets/icons/user_management_unselected.svg": "76cafbf4b2b6da6e0adf2533152da476",
"assets/assets/icons/offer_listing_selected.svg": "56895aee5df43a95ec152372f47ffc9c",
"assets/assets/icons/home_unselected.svg": "f2fd87f600e91a4f77c413c6cde8faf2",
"assets/assets/icons/subcategory_unselected.svg": "d52fb6d48a03756e2a4b6f1d8671ec4e",
"assets/assets/fonts/poppins/Poppins-Light.ttf": "fcc40ae9a542d001971e53eaed948410",
"assets/assets/fonts/poppins/Poppins-ExtraBold.ttf": "d45bdbc2d4a98c1ecb17821a1dbbd3a4",
"assets/assets/fonts/poppins/Poppins-Regular.ttf": "093ee89be9ede30383f39a899c485a82",
"assets/assets/fonts/poppins/Poppins-Black.ttf": "14d00dab1f6802e787183ecab5cce85e",
"assets/assets/fonts/poppins/Poppins-SemiBold.ttf": "6f1520d107205975713ba09df778f93f",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01"};
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
