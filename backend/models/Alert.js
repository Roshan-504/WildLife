const mongoose = require("mongoose");

const alertSchema = new mongoose.Schema(
  {
    camera_id: { type: String, required: true },
    zone: { type: String, required: true },
    location: {
      lat: Number,
      lng: Number,
      area_name: String,
    },
    species: { type: String, required: true },
    confidence: { type: Number, required: true },
    severity: {
      type: String,
      enum: ["CRITICAL", "HIGH", "MEDIUM", "LOW", "WARNING"],
      default: "WARNING",
    },
    timestamp: { type: Date, required: true },
    image_url: { type: String, default: null }, // will be filled later by Cloudinary
    // We store base64 temporarily only if needed (not recommended for production)
    image_base64: { type: String, select: false },
  },
  { timestamps: true },
);

// Index for fast zone-based queries later
alertSchema.index({ zone: 1, createdAt: -1 });
alertSchema.index({ species: 1, createdAt: -1 });

module.exports = mongoose.model("Alert", alertSchema);
