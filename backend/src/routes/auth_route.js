const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");
const { registerLimiter, authLimiter } = require("../middleware/rateLimiters");
const upload = require("../middleware/uploads");
const {
  register,
  login,
  getMe,
  logout,
  refreshToken,
  updateProfile,
  updatePassword,
  uploadProfilePicture,
  requestPasswordReset,
  resetPassword,
  googleOAuth,
} = require("../controllers/auth_controller");

// Public routes
router.post("/register", registerLimiter, register);
router.post("/login", authLimiter, login);
router.post("/refresh-token", refreshToken);
router.post("/google", googleOAuth);
router.post("/request-password-reset", requestPasswordReset);
router.post("/reset-password/:token", resetPassword);

// Protected routes (Both Bearer Token and HttpOnly Cookie methods are supported in protect middleware)
router.get("/me", protect, getMe);
router.get("/profile", protect, getMe); // Duplicate mapped for web/mobile client compatibility
router.put("/profile", protect, updateProfile);
router.put("/password", protect, updatePassword);
router.post("/upload-profile-picture", protect, upload.single("profilePicture"), uploadProfilePicture);
router.post("/logout", protect, logout);

module.exports = router;

