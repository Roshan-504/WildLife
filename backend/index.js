require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const alertRoutes = require("./routes/alerts");
const zoneRoutes = require("./routes/zones");
const userRoutes = require("./routes/users");


connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: "15mb" }));

// Routes
app.use("/api/alerts", alertRoutes);
app.use("/api/zones", zoneRoutes);
app.use("/api/users", userRoutes);

// Health check
app.get("/", (req, res) => {
  res.json({ message: "Wildlife Alert Backend is running" });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
