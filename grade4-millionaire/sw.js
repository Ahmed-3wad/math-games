// retired: hand control back to the network (the app's own worker is one level up)
self.addEventListener("install", () => self.skipWaiting());
self.addEventListener("activate", e => e.waitUntil(self.registration.unregister()));
