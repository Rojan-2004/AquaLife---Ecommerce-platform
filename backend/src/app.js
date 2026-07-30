const path = require("path");
const express = require("express");
const morgan = require("morgan");
const cookieParser = require("cookie-parser");
const helmet = require("helmet");
const bodyParser = require("body-parser");
const cors = require("cors");
const errorHandler = require("./middleware/errorHandler");
const { limiter } = require("./middleware/rateLimiters");

const app = express();

// Base Middlewares
app.use(express.json());
app.use(morgan("dev")); // Morgan request logging
app.use(cookieParser()); // Cookie parser middleware

// Custom security middleware to prevent NoSQL Operator injection and escape html strings (compatible with Express v5)
app.use((req, res, next) => {
  // Fields that opt out of XSS escaping only. NoSQL operator stripping ALWAYS runs.
  const skipXssEscape = new Set([
    "email",
    "username",
    "password",
    "mediaUrl",
    "profilePicture",
  ]);

  const sanitize = (obj) => {
    if (!obj || typeof obj !== "object") return obj;
    for (const key of Object.keys(obj)) {
      // Strip Mongo operator keys regardless of field name
      if (key.startsWith("$") || key.includes(".")) {
        delete obj[key];
        continue;
      }
      const val = obj[key];
      if (typeof val === "string") {
        if (
          !skipXssEscape.has(key) &&
          !val.includes("@") &&
          !val.startsWith("http")
        ) {
          obj[key] = val.replace(/</g, "&lt;").replace(/>/g, "&gt;");
        }
      } else if (val && typeof val === "object") {
        sanitize(val);
      }
    }
    return obj;
  };

  if (req.body) sanitize(req.body);
  if (req.params) sanitize(req.params);

  // Express 5 makes req.query a getter; replace with a sanitized copy.
  if (req.query && Object.keys(req.query).length > 0) {
    const sanitizedQuery = sanitize({ ...req.query });
    Object.defineProperty(req, "query", {
      value: sanitizedQuery,
      writable: true,
      configurable: true,
    });
  }

  next();
});

app.use(helmet()); // Helmet security headers
app.use(bodyParser.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Configure CORS to support both web frontend URL list and wildcards for mobile apps
const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = process.env.CORS_ORIGIN
      ? process.env.CORS_ORIGIN.split(",")
      : [];
    // Allow requests with no origin (mobile apps, Postman, etc.) or matching allowed domains
    if (!origin || allowedOrigins.indexOf(origin) !== -1 || allowedOrigins.includes("*")) {
      return callback(null, true);
    }
    // In development the Next dev server can be reached via localhost, 127.0.0.1,
    // or a LAN IP on a varying port. Reflect any origin so CORS preflight never
    // fails (e.g. http://127.0.0.1:3001). Production still enforces the whitelist.
    if (process.env.NODE_ENV !== "production") {
      return callback(null, true);
    }
    callback(new Error("Not allowed by CORS"));
  },
  credentials: true, // Allow cookies
  optionsSuccessStatus: 200,
};
app.use(cors(corsOptions)); // Enable CORS with options

app.use(limiter); // Apply rate limiting to all requests
app.use(express.static(path.join(__dirname, "../public"))); // Serve static files

// Routers
const authRoute = require("./routes/auth_route");
const categoryRoute = require("./routes/category_route");
const adminUserRoute = require("./routes/admin_user_route");
const adminProductRoute = require("./routes/admin_product_route");
const dashboardRoute = require("./routes/dashboard_route");
const productRoute = require("./routes/product_route");
const wishlistRoute = require("./routes/wishlist_route");
const cartRoute = require("./routes/cart_route");
const orderRoute = require("./routes/order_route");
const adminNotificationRoute = require("./routes/admin_notification_route");
const adminOrderRoute = require("./routes/admin_order_route");
const reviewRoute = require("./routes/review_route");

app.use("/api/v1/auth", authRoute);
app.use("/api/v1/categories", categoryRoute);
app.use("/api/v1/admin/users", adminUserRoute);
app.use("/api/v1/admin/products", adminProductRoute);
app.use("/api/v1", dashboardRoute);
app.use("/api/v1/products", productRoute);
app.use("/api/v1/wishlist", wishlistRoute);
app.use("/api/v1/cart", cartRoute);
app.use("/api/v1/orders", orderRoute);
app.use("/api/v1/admin/notifications", adminNotificationRoute);
app.use("/api/v1/admin/orders", adminOrderRoute);
app.use("/api/v1/reviews", reviewRoute);

// 404 handler
app.use((req, res, next) => {
  res.status(404).json({ success: false, message: "API endpoint not found" });
});

// Error handling middleware
app.use(errorHandler);

module.exports = app;
