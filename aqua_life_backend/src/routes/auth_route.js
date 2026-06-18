const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");
const { registerLimiter, authLimiter } = require("../middleware/rateLimiters");
const {
  register,
  login,
  getMe,
  logout,
  refreshToken,
} = require("../controllers/auth_controller");

// Public routes
router.post("/register", registerLimiter, register);
router.post("/login", authLimiter, login);
router.post("/refresh-token", refreshToken);

// Protected routes (Both Bearer Token and HttpOnly Cookie methods are supported in protect middleware)
router.get("/me", protect, getMe);
router.get("/profile", protect, getMe); // Duplicate mapped for web/mobile client compatibility
router.post("/logout", protect, logout);

module.exports = router;
