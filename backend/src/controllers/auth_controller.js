const User = require("../models/user_model");
const { registerSchema, loginSchema, requestPasswordResetSchema, resetPasswordSchema } = require("../validations/auth_validation");
const { z } = require("zod");
const jwt = require("jsonwebtoken");
const HttpException = require("../utils/httpException");
const axios = require("axios");
const { sendPasswordResetEmail } = require("../utils/email");

const normalizeEmail = (value) => {
  if (typeof value !== "string") return "";
  return value.trim().toLowerCase();
};

const normalizeUsername = (value, email) => {
  if (typeof value === "string" && value.trim()) {
    return value.trim();
  }
  if (email) {
    return email.split("@")[0];
  }
  return "";
};

const formatZodError = (err) => {
  if (typeof z.prettifyError === "function") {
    return z.prettifyError(err);
  }
  return err.errors.map((e) => `${e.path.join(".")}: ${e.message}`).join(", ");
};

// Helper for cookie options
const getCookieOptions = (expireDays = 7) => {
  return {
    expires: new Date(Date.now() + expireDays * 24 * 60 * 60 * 1000),
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: process.env.NODE_ENV === "production" ? "none" : "lax",
  };
};

// Send cookies and tokens
const sendTokenResponse = (user, accessToken, refreshToken, statusCode, res, action) => {
  console.log(
    `[AUTH:${action.toUpperCase()}] Access token generated for ${user.email}`
  );

  // Set HTTPOnly cookies for web browsers
  res.cookie("accessToken", accessToken, getCookieOptions(1)); // 1 day
  res.cookie("token", accessToken, getCookieOptions(1)); // fallback cookie
  res.cookie("refreshToken", refreshToken, getCookieOptions(7)); // 7 days

  // Return json response (for mobile clients and web fallback)
  res.status(statusCode).json({
    success: true,
    token: accessToken,
    refreshToken: refreshToken,
    data: user.safeProfile(),
  });
};

// @desc    Register user
// @route   POST /api/v1/auth/register
// @access  Public
const register = async (req, res, next) => {
  try {
    const validated = registerSchema.safeParse(req.body);
    if (!validated.success) {
      return res.status(400).json({
        success: false,
        message: formatZodError(validated.error),
      });
    }

    let {
      firstName,
      lastName,
      name,
      fullName,
      email,
      username,
      password,
      phoneNumber,
      profilePicture,
      role,
    } = validated.data;

    const normalizedEmail = normalizeEmail(email);
    const normalizedUsername = normalizeUsername(username, normalizedEmail);

    // Map Web/Mobile fields safely
    if (firstName && lastName) {
      fullName = fullName || `${firstName} ${lastName}`.trim();
      name = name || fullName;
    } else if (fullName || name) {
      const display = fullName || name;
      name = display;
      fullName = display;
      const parts = display.split(" ");
      firstName = firstName || parts[0] || "";
      lastName = lastName || parts.slice(1).join(" ") || "";
    }

    // Check unique email
    const existingEmail = await User.findOne({ email: normalizedEmail }).select("_id");
    if (existingEmail) {
      return res.status(400).json({ success: false, message: "Email already exists" });
    }

    // Check unique username (case insensitive)
    const existingUsername = await User.findOne({ username: normalizedUsername })
      .select("_id")
      .collation({ locale: "en", strength: 2 });
    if (existingUsername) {
      return res.status(400).json({ success: false, message: "Username already exists" });
    }

    // Instantiate User model
    const user = new User({
      firstName,
      lastName,
      name,
      fullName,
      email: normalizedEmail,
      username: normalizedUsername,
      password,
      phoneNumber: phoneNumber || null,
      profilePicture: profilePicture || "default-profile.png",
      role: role || "user",
    });

    const accessToken = user.getSignedJwtToken();
    const refreshToken = user.getSignedRefreshToken();
    
    // Attach refresh token to user and save (triggers pre-save password hashing)
    user.refreshToken = refreshToken;
    await user.save();

    sendTokenResponse(user, accessToken, refreshToken, 201, res, "register");
  } catch (err) {
    next(err);
  }
};

// @desc    Login user
// @route   POST /api/v1/auth/login
// @access  Public
const login = async (req, res, next) => {
  try {
    const validated = loginSchema.safeParse(req.body);
    if (!validated.success) {
      return res.status(400).json({
        success: false,
        message: formatZodError(validated.error),
      });
    }

    const { email, password } = validated.data;
    const normalizedEmail = normalizeEmail(email);

    console.log(`[AUTH:LOGIN_REQUEST] email=${normalizedEmail}`);

    const user = await User.findOne({ email: normalizedEmail }).select("+password +refreshToken");
    if (!user) {
      console.log(`[AUTH:LOGIN_FAILED] User not found: ${normalizedEmail}`);
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      console.log(`[AUTH:LOGIN_FAILED] Password mismatch for: ${normalizedEmail}`);
      return res.status(401).json({ success: false, message: "Invalid credentials" });
    }

    const accessToken = user.getSignedJwtToken();
    const refreshToken = user.getSignedRefreshToken();

    // Save refresh token to user
    user.refreshToken = refreshToken;
    await user.save();

    sendTokenResponse(user, accessToken, refreshToken, 200, res, "login");
  } catch (err) {
    next(err);
  }
};

// @desc    Get current user profile
// @route   GET /api/v1/auth/me or /api/v1/auth/profile
// @access  Private
const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    res.status(200).json({
      success: true,
      data: user.safeProfile(),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Logout user and clear cookies
// @route   POST /api/v1/auth/logout
// @access  Private
const logout = async (req, res, next) => {
  try {
    if (req.user) {
      // Unset the refresh token in the DB
      await User.updateOne({ _id: req.user._id }, { $unset: { refreshToken: "" } });
    }

    res.clearCookie("accessToken", getCookieOptions());
    res.clearCookie("token", getCookieOptions());
    res.clearCookie("refreshToken", getCookieOptions());

    res.status(200).json({
      success: true,
      message: "Logged out successfully",
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Refresh token rotation
// @route   POST /api/v1/auth/refresh-token
// @access  Public
const refreshToken = async (req, res, next) => {
  try {
    const tokenVal = req.cookies?.refreshToken || req.body.refreshToken;

    if (!tokenVal) {
      return res.status(401).json({
        success: false,
        message: "Refresh token is missing",
      });
    }

    let decoded;
    try {
      decoded = jwt.verify(tokenVal, process.env.JWT_REFRESH_SECRET || "refresh_secret_default_key");
    } catch (err) {
      return res.status(401).json({
        success: false,
        message: "Refresh token is invalid or expired",
      });
    }

    // Retrieve user and compare refresh token
    const user = await User.findById(decoded.id).select("+refreshToken");
    if (!user || user.refreshToken !== tokenVal) {
      return res.status(401).json({
        success: false,
        message: "Refresh token has been revoked or is invalid",
      });
    }

    // Generate new tokens (token rotation)
    const newAccessToken = user.getSignedJwtToken();
    const newRefreshToken = user.getSignedRefreshToken();

    // Update refresh token in DB
    user.refreshToken = newRefreshToken;
    await user.save();

    // Send updated cookies & JSON tokens
    sendTokenResponse(user, newAccessToken, newRefreshToken, 200, res, "refresh");
  } catch (err) {
    next(err);
  }
};

// @desc    Update user profile
// @route   PUT /api/v1/auth/profile
// @access  Private
const updateProfile = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const { firstName, lastName, username, phoneNumber } = req.body;

    if (username && username !== user.username) {
      // Check unique username (case insensitive)
      const existingUsername = await User.findOne({ username })
        .select("_id")
        .collation({ locale: "en", strength: 2 });
      if (existingUsername && existingUsername._id.toString() !== user._id.toString()) {
        return res.status(400).json({ success: false, message: "Username already exists" });
      }
      user.username = username.trim();
    }

    if (firstName !== undefined) user.firstName = firstName.trim();
    if (lastName !== undefined) user.lastName = lastName.trim();
    if (phoneNumber !== undefined) user.phoneNumber = phoneNumber.trim() || null;

    // Derived fields
    if (user.firstName && user.lastName) {
      user.fullName = `${user.firstName} ${user.lastName}`.trim();
      user.name = user.fullName;
    } else if (user.firstName) {
      user.fullName = user.firstName;
      user.name = user.firstName;
    }

    await user.save();

    res.status(200).json({
      success: true,
      message: "Profile updated successfully",
      data: user.safeProfile(),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Upload profile picture
// @route   POST /api/v1/auth/upload-profile-picture
// @access  Private
const uploadProfilePicture = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, message: "Please upload an image file" });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    user.profilePicture = req.file.filename;
    await user.save();

    res.status(200).json({
      success: true,
      message: "Profile picture updated successfully",
      data: user.safeProfile(),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update user password
// @route   PUT /api/v1/auth/password
// @access  Private
const updatePassword = async (req, res, next) => {
  try {
    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res.status(400).json({
        success: false,
        message: "Current password and new password are required",
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        success: false,
        message: "New password must be at least 6 characters long",
      });
    }

    // Get user and select password
    const user = await User.findById(req.user._id).select("+password");
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    // Match current password
    const isMatch = await user.matchPassword(currentPassword);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: "Incorrect current password" });
    }

    // Set new password
    user.password = newPassword;
    await user.save();

    res.status(200).json({
      success: true,
      message: "Password updated successfully",
    });
  } catch (err) {
    next(err);
  }
};

const verifyGoogleToken = async (credential) => {
  try {
    const response = await axios.get(
      `https://oauth2.googleapis.com/tokeninfo?id_token=${credential}`
    );
    const clientId = process.env.GOOGLE_CLIENT_ID;
    if (
      response.data &&
      response.data.email_verified === "true" &&
      (!clientId || response.data.aud === clientId)
    ) {
      return response.data;
    }
    return null;
  } catch (err) {
    return null;
  }
};

// @desc    Google OAuth login
// @route   POST /api/v1/auth/google
// @access  Public
const googleOAuth = async (req, res, next) => {
  try {
    const { credential } = req.body;

    if (!credential) {
      return res.status(400).json({ success: false, message: "Google credential is required" });
    }

    const googleUser = await verifyGoogleToken(credential);
    if (!googleUser) {
      return res.status(401).json({ success: false, message: "Invalid Google credential" });
    }

    const { email, sub, name, picture, given_name, family_name } = googleUser;

    let user = await User.findOne({ email }).select("+refreshToken");
    if (!user) {
      user = new User({
        firstName: given_name || (name ? name.split(" ")[0] : ""),
        lastName: family_name || (name ? name.split(" ").slice(1).join(" ") : ""),
        email,
        username: normalizeUsername("", email),
        provider: "google",
        providerId: sub,
        profilePicture: picture || "default-profile.png",
        role: "user",
        status: "active",
      });
    } else if (!user.providerId) {
      user.providerId = sub;
      user.provider = "google";
    }

    const accessToken = user.getSignedJwtToken();
    const refreshToken = user.getSignedRefreshToken();
    user.refreshToken = refreshToken;
    await user.save();

    sendTokenResponse(user, accessToken, refreshToken, 200, res, "google");
  } catch (err) {
    next(err);
  }
};

// @desc    Request password reset
// @route   POST /api/v1/auth/request-password-reset
// @access  Public
const requestPasswordReset = async (req, res, next) => {
  try {
    const validated = requestPasswordResetSchema.safeParse(req.body);
    if (!validated.success) {
      return res.status(400).json({
        success: false,
        message: formatZodError(validated.error),
      });
    }

    const email = normalizeEmail(validated.data.email);
    const user = await User.findOne({ email });

    if (!user) {
      return res.status(200).json({
        success: true,
        message: "If an account exists with that email, a reset link has been sent.",
      });
    }

    const resetToken = jwt.sign(
      { id: user._id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    user.resetPasswordToken = resetToken;
    user.resetPasswordExpire = Date.now() + 60 * 60 * 1000; // 1 hour
    await user.save();

    try {
      const emailResult = await sendPasswordResetEmail(user.email, resetToken);
    } catch (emailErr) {
      console.error("Password reset email failed:", emailErr);
    }

    const frontendUrl = process.env.FRONTEND_URL || "http://localhost:3001";
    const devResetUrl = `${frontendUrl}/frontend/reset-password?token=${encodeURIComponent(resetToken)}`;
    console.log(`[DEV PASSWORD RESET] Use this link: ${devResetUrl}`);

    return res.status(200).json({
      success: true,
      message: "If an account exists with that email, a reset link has been sent.",
      ...(process.env.NODE_ENV !== "production" ? { devResetUrl } : {}),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Reset password
// @route   POST /api/v1/auth/reset-password/:token
// @access  Public
const resetPassword = async (req, res, next) => {
  try {
    const validated = resetPasswordSchema.safeParse(req.body);
    if (!validated.success) {
      return res.status(400).json({
        success: false,
        message: formatZodError(validated.error),
      });
    }

    const token = req.params.token;
    if (!token) {
      return res.status(400).json({ success: false, message: "Reset token is required" });
    }

    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      return res.status(400).json({ success: false, message: "Invalid or expired reset token" });
    }

    const user = await User.findOne({
      _id: decoded.id,
      resetPasswordToken: token,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return res.status(400).json({ success: false, message: "Invalid or expired reset token" });
    }

    user.password = validated.data.password;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    user.markModified("password");
    user.markModified("resetPasswordToken");
    user.markModified("resetPasswordExpire");
    await user.save();

    return res.status(200).json({
      success: true,
      message: "Password reset successfully. You can now log in.",
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  register,
  login,
  getMe,
  logout,
  refreshToken,
  updateProfile,
  uploadProfilePicture,
  updatePassword,
  requestPasswordReset,
  resetPassword,
  googleOAuth,
};

