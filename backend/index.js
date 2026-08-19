require("dotenv").config();
const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");
const alertRoutes = require("./routes/alerts");

connectDB();

const app = express();

// Middleware
app.use(cors());
app.use(express.json({ limit: "15mb" }));

// Routes
app.use("/api/alerts", alertRoutes);

// Health check
app.get("/", (req, res) => {
  res.json({ message: "Wildlife Alert Backend is running" });
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
