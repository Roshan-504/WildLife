const express = require("express");
const router = express.Router();
const Zone = require("../models/Zone");

// GET /api/zones - Fetch all available zones
router.get("/", async (req, res) => {
  try {
    const zones = await Zone.find().sort({ name: 1 });
    res.status(200).json({ success: true, data: zones });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

// POST /api/zones - (Admin/Test only) Add a new zone to the DB
router.post("/", async (req, res) => {
  try {
    const zone = await Zone.create(req.body);
    res.status(201).json({ success: true, data: zone });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
