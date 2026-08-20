const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    firebase_uid: { type: String, required: true, unique: true },
    email: { type: String, required: true },
    current_zone: { type: String, ref: "Zone" }, // References the topic_id
    fcm_token: String, // Optional: for sending messages to a specific device later
  },
  { timestamps: true },
);

module.exports = mongoose.model("User", userSchema);
