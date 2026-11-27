
/* PawLink Firebase Cloud Messaging Service Worker */

importScripts(
  "https://www.gstatic.com/firebasejs/10.13.2/firebase-app-compat.js"
);

importScripts(
  "https://www.gstatic.com/firebasejs/10.13.2/firebase-messaging-compat.js"
);

// PawLink Firebase Web Configuration.
firebase.initializeApp({
  apiKey: "AIzaSyBrZLPVodEuAtpslRG9_wZJQFS7YnvdCPU",
  appId: "1:85061079051:web:69c7d92e933ec30103370e",
  messagingSenderId: "85061079051",
  projectId: "pawlink-pet-2026",
  authDomain: "pawlink-pet-2026.firebaseapp.com",
  storageBucket: "pawlink-pet-2026.firebasestorage.app",
});

const messaging = firebase.messaging();

// Handle push notifications when PawLink is in the background.
messaging.onBackgroundMessage((payload) => {
  console.log(
    "[PawLink] Background message received:",
    payload
  );

  const notificationTitle =
    payload.notification?.title || "PawLink Notification";

  const notificationOptions = {
    body:
      payload.notification?.body ||
      "You have a new notification from PawLink.",

    icon: "/icons/Icon-192.png",

    badge: "/icons/Icon-192.png",

    data: payload.data || {},
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});

// Handle notification clicks.
self.addEventListener("notificationclick", (event) => {
  event.notification.close();

  const targetUrl = new URL("/", self.location.origin).href;

  event.waitUntil(
    clients.matchAll({
      type: "window",
      includeUncontrolled: true,
    }).then((windowClients) => {
      for (const client of windowClients) {
        if ("focus" in client) {
          return client.focus().then(() => {
            if ("navigate" in client) {
              return client.navigate(targetUrl);
            }
          });
        }
      }

      return clients.openWindow(targetUrl);
    })
  );
});
