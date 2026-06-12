const path = require("path");
const express = require("express");
const dotenv = require("dotenv");
const morgan = require("morgan");
const colors = require("colors");
const connectDB = require("./config/db");
const cookieParser = require("cookie-parser");
const helmet = require("helmet");
const rateLimit = require("express-rate-limit");
const bodyParser = require("body-parser");
const cors = require("cors");
const errorHandler = require("./middleware/errorHandler");
const app = express();

// Load environment variables
dotenv.config({ path: "./config/config.env", quiet: true });

// Connect to the database
connectDB();

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: "Too many requests from this IP, please try again later.",
  standardHeaders: true, // Return rate limit info in the `RateLimit-*` headers
  legacyHeaders: false, // Disable the `X-RateLimit-*` headers
  skip: () => process.env.DISABLE_RATE_LIMIT === "true",
});

// Rate limiter for auth routes (stricter)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 login attempts per windowMs
  message: "Too many login attempts, please try again after 15 minutes.",
  skipSuccessfulRequests: true, // Don't count successful requests
  skip: () => process.env.DISABLE_RATE_LIMIT === "true",
});

// Rate limiter for account registration (prevent signup spam)
const registerLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 10, // Limit each IP to 10 registrations per hour
  message: "Too many accounts created from this IP, please try again in an hour.",
  standardHeaders: true,
  legacyHeaders: false,
  skip: () => process.env.DISABLE_RATE_LIMIT === "true",
});

// Middleware
app.use(express.json());
app.use(morgan("dev")); // Logging middleware
app.use(cookieParser()); // Cookie parser middleware

// Custom security middleware (compatible with Express v5)
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
      // Strip Mongo operator keys regardless of field name. Closes the hole
      // where { email: { $gt: "" } } previously bypassed the skip-list.
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

app.use(helmet()); // Security middleware
app.use(bodyParser.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Configure CORS
const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = process.env.CORS_ORIGIN
      ? process.env.CORS_ORIGIN.split(",")
      : [];
    // Allow requests with no origin (mobile apps, Postman, etc.)
    if (!origin || allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  credentials: true, // Allow cookies
  optionsSuccessStatus: 200,
};
app.use(cors(corsOptions)); // Enable CORS with options

app.use(limiter); // Apply rate limiting to all requests
app.use(express.static(path.join(__dirname, "public"))); // Serve static files

// Routes
const batchRoutes = require("./routes/batch_route");
app.use("/api/v1/batches", batchRoutes);

const categoryRoutes = require("./routes/category_route");
app.use("/api/v1/categories", categoryRoutes);

// Apply stricter rate limiting to login + registration endpoints
const studentRoutes = require("./routes/student_route");
app.use("/api/v1/students/login", authLimiter);
app.post("/api/v1/students", registerLimiter, (req, res, next) => next());
app.use("/api/v1/students", studentRoutes);

const itemRoutes = require("./routes/item_route");
app.use("/api/v1/items", itemRoutes);

const commentRoutes = require("./routes/comment_route");
app.use("/api/v1/comments", commentRoutes);

// const userRoutes = require("./routes/userRoutes");
// const productRoutes = require("./routes/productRoutes");
// const orderRoutes = require("./routes/orderRoutes");
// const paymentRoutes = require("./routes/paymentRoutes");
// app.use("/api/v1/users", userRoutes);
// app.use("/api/v1/products", productRoutes);
// app.use("/api/v1/orders", orderRoutes);
// app.use("/api/v1/payments", paymentRoutes);

// Error handling middleware
app.use(errorHandler);

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(
    `Server running in ${process.env.NODE_ENV} mode on port ${PORT}`.green.bold
      .underline
  );
});
