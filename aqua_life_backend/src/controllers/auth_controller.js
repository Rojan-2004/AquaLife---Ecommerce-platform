const User = require("../models/user_model");
const { registerSchema, loginSchema } = require("../validations/auth_validation");
const { z } = require("zod");
const jwt = require("jsonwebtoken");
const HttpException = require("../utils/httpException");

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

    const refreshSecret = process.env.JWT_REFRESH_SECRET;
    if (!refreshSecret) {
      return res.status(500).json({
        success: false,
        message: "Server configuration error",
      });
    }

    let decoded;
    try {
      decoded = jwt.verify(tokenVal, refreshSecret);
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

module.exports = {
  register,
  login,
  getMe,
  logout,
  refreshToken,
};
