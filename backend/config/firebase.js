const { initializeApp, cert } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");
const serviceAccount = require("./../firebase-service-account.json");

// Initialize the Firebase app
const app = initializeApp({
  credential: cert(serviceAccount),
});

// Export the messaging instance
const messaging = getMessaging(app);

module.exports = { messaging };
