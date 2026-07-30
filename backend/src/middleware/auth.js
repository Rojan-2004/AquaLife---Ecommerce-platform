const jwt = require("jsonwebtoken");
const User = require("../models/user_model");

// Route protection middleware supporting both cookies (web) and Bearer tokens (mobile)
const protect = async (req, res, next) => {
  let token;

  // 1. Try reading token from HttpOnly cookies (accessToken or token)
  if (req.cookies) {
    token = req.cookies.accessToken || req.cookies.token;
  }

  // 2. Try reading token from Authorization Bearer header
  if (
    !token &&
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Not authorized to access this route. Token is missing.",
    });
  }

  try {
    // Verify token using secret key
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    
    // Retrieve associated user from DB
    req.user = await User.findById(decoded.id);
    
    if (!req.user) {
      return res.status(401).json({
        success: false,
        message: "Not authorized to access this route. User not found.",
      });
    }

    next();
  } catch (err) {
    return res.status(401).json({
      success: false,
      message: "Not authorized to access this route. Token is invalid or expired.",
    });
  }
};

// Role authorization middleware
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `User role '${req.user ? req.user.role : "undefined"}' is not authorized to access this route`,
      });
    }
    next();
  };
};

module.exports = {
  protect,
  authorize,
};
