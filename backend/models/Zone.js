const mongoose = require("mongoose");

const zoneSchema = new mongoose.Schema({
  name: { type: String, required: true },
  topic_id: { type: String, required: true, unique: true }, // e.g., 'ZoneA' (Used for Firebase)
  description: String,
  coordinates: {
    lat: Number,
    lng: Number,
  },
});

module.exports = mongoose.model("Zone", zoneSchema);
