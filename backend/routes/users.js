const express = require("express");
const router = express.Router();
const User = require("../models/User");

// POST /api/users/profile - Create or update user
router.post("/profile", async (req, res) => {
  try {
    const { firebase_uid, email, current_zone } = req.body;

    // Use findOneAndUpdate with upsert: true to either update an existing user or create a new one
    const user = await User.findOneAndUpdate(
      { firebase_uid },
      { email, current_zone },
      { new: true, upsert: true },
    );

    res.status(200).json({ success: true, data: user });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
