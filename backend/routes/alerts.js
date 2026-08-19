const express = require("express");
const router = express.Router();
const Alert = require("../models/Alert");

// POST /api/alerts  ← This is what your Python code calls
router.post("/", async (req, res) => {
  try {
    const {
      camera_id,
      zone,
      location,
      species,
      confidence,
      severity,
      timestamp,
      image_base64,
    } = req.body;

    // Basic validation
    if (!camera_id || !zone || !species || !confidence) {
      return res.status(400).json({
        success: false,
        message: "Missing required fields",
      });
    }

    const alert = await Alert.create({
      camera_id,
      zone,
      location,
      species,
      confidence,
      severity: severity || "WARNING",
      timestamp: timestamp ? new Date(timestamp) : new Date(),
      image_base64, // temporary – we will remove this later
    });

    console.log(
      `[NEW ALERT] ${species} | ${severity} | Camera: ${camera_id} | Zone: ${zone}`,
    );

    // TODO later:
    // 1. Upload image_base64 to Cloudinary → get image_url
    // 2. Send push notification to residents of this zone

    res.status(201).json({
      success: true,
      message: "Alert received and stored",
      data: {
        id: alert._id,
        species: alert.species,
        severity: alert.severity,
        zone: alert.zone,
      },
    });
  } catch (error) {
    console.error("Error saving alert:", error);
    res.status(500).json({
      success: false,
      message: "Server error",
      error: error.message,
    });
  }
});

// Optional: GET recent alerts (useful for testing / admin)
router.get("/", async (req, res) => {
  try {
    const alerts = await Alert.find()
      .sort({ createdAt: -1 })
      .limit(50)
      .select("-image_base64"); // never send base64 back

    res.json({ success: true, count: alerts.length, data: alerts });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
