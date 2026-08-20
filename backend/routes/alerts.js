const express = require("express");
const router = express.Router();
const Alert = require("../models/Alert");
const { messaging } = require("../config/firebase");

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

    const alertDate = timestamp ? new Date(timestamp) : new Date();

    const alert = await Alert.create({
      camera_id,
      zone,
      location,
      species,
      confidence,
      severity: severity || "WARNING",
      timestamp: alertDate,
      image_base64, // temporary – we will remove this later
    });

    const formattedTime = alertDate.toLocaleTimeString("en-IN", {
      timeZone: "Asia/Kolkata",
      hour: "2-digit",
      minute: "2-digit",
    });

    // --- FIREBASE PUSH NOTIFICATION LOGIC ---
    const message = {
      notification: {
        title: `🚨 ${severity} Alert: ${species.toUpperCase()} Detected!`,
        // Added the formatted time into the body string
        body: `A ${species} was spotted near ${location.area_name} at ${formattedTime}.`,
      },
      data: {
        alert_id: alert._id.toString(),
        species: species,
        zone: zone,
        time: formattedTime, // Also pass it in the background payload
      },
      topic: zone,
    };

    // Fire and forget - don't await so the response is faster

    messaging.send(message)
      .then((response) =>
        console.log("Successfully sent FCM message:", response),
      )
      .catch((error) => console.log("Error sending FCM message:", error));


    // TODO later:
    // 1. Upload image_base64 to Cloudinary → get image_url

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

// Replace your existing GET / route with this:
router.get('/', async (req, res) => {
  try {
    const { zone, page = 1, limit = 10, severity } = req.query;
    
    // Build the filter query
    const query = {};
    if (zone) query.zone = zone;
    if (severity) query.severity = severity;

    const alerts = await Alert.find(query)
      .sort({ timestamp: -1 }) // Newest first
      .skip((page - 1) * limit)
      .limit(parseInt(limit))

    res.json({ success: true, count: alerts.length, data: alerts });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
