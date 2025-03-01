const express = require("express");
const cors = require("cors");
const morgan = require("morgan");

const app = express();
const PORT =  3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(morgan("dev")); // Log HTTP requests

// Root route
app.get("/", (req, res) => {
  res.json({ message: "Welcome to our Node.js backend!" });
});

// Health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "healthy", uptime: process.uptime() });
});

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

// Start the server
app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
