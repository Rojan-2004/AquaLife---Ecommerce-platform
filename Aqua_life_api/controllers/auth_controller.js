const asyncHandler = require("../middleware/async");
const User = require("../models/user_model");

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

const getCookieOptions = () => {
  const cookieExpireDays = parseInt(process.env.JWT_COOKIE_EXPIRE || "30", 10);

  return {
    expires: new Date(Date.now() + cookieExpireDays * 24 * 60 * 60 * 1000),
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
  };
};

const sendTokenResponse = (user, statusCode, res, action) => {
  const token = user.getSignedJwtToken();

  if (process.env.NODE_ENV === "development") {
    console.log(
      `[AUTH:${action.toUpperCase()}] JWT token generated for ${user.email}: ${token}`
    );
  }

  res.status(statusCode).cookie("token", token, getCookieOptions()).json({
    success: true,
    token,
    data: user.safeProfile(),
  });
};

exports.register = asyncHandler(async (req, res) => {
  const {
    name,
    fullName,
    email,
    username,
    password,
    phoneNumber,
    profilePicture,
  } = req.body;

  const normalizedEmail = normalizeEmail(email);
  const normalizedUsername = normalizeUsername(username, normalizedEmail);
  const displayName = fullName || name || normalizedEmail.split("@")[0] || "Aqua User";

  if (!normalizedEmail) {
    return res.status(400).json({ success: false, message: "Email is required" });
  }

  if (!normalizedUsername || normalizedUsername.length < 3) {
    return res
      .status(400)
      .json({ success: false, message: "Username must be at least 3 characters" });
  }

  if (typeof password !== "string" || password.length < 6) {
    return res
      .status(400)
      .json({ success: false, message: "Password must be at least 6 characters" });
  }

  const existingEmail = await User.findOne({ email: normalizedEmail }).select("_id");
  if (existingEmail) {
    return res.status(400).json({ success: false, message: "Email already exists" });
  }

  const existingUsername = await User.findOne({ username: normalizedUsername })
    .select("_id")
    .collation({ locale: "en", strength: 2 });

  if (existingUsername) {
    return res.status(400).json({ success: false, message: "Username already exists" });
  }

  const user = await User.create({
    name: displayName,
    fullName: displayName,
    email: normalizedEmail,
    username: normalizedUsername,
    password,
    phoneNumber: phoneNumber || null,
    profilePicture: profilePicture || "default-profile.png",
  });

  sendTokenResponse(user, 201, res, "register");
});

exports.login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;
  const normalizedEmail = normalizeEmail(email);

  if (!normalizedEmail || typeof password !== "string" || !password) {
    return res
      .status(400)
      .json({ success: false, message: "Please provide an email and password" });
  }

  const user = await User.findOne({ email: normalizedEmail }).select("+password");

  if (!user) {
    return res.status(401).json({ success: false, message: "Invalid credentials" });
  }

  const matches = await user.matchPassword(password);

  if (!matches) {
    return res.status(401).json({ success: false, message: "Invalid credentials" });
  }

  sendTokenResponse(user, 200, res, "login");
});

exports.getMe = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id);

  if (!user) {
    return res.status(404).json({ success: false, message: "User not found" });
  }

  res.status(200).json({
    success: true,
    data: user.safeProfile(),
  });
});
exports.logout = (req, res) => {
  res.clearCookie("token", getCookieOptions()).status(200).json({
    success: true,
    message: "Logged out successfully",
  });
};
