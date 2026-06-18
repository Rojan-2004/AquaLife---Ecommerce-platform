const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

const userSchema = new mongoose.Schema(
  {
    firstName: {
      type: String,
      trim: true,
    },
    lastName: {
      type: String,
      trim: true,
    },
    name: {
      type: String,
      trim: true,
    },
    fullName: {
      type: String,
      trim: true,
    },
    email: {
      type: String,
      required: [true, "Email is required"],
      unique: true,
      trim: true,
      lowercase: true,
      match: [/^\S+@\S+\.\S+$/, "Please add a valid email"],
    },
    username: {
      type: String,
      required: [true, "Username is required"],
      trim: true,
    },
    password: {
      type: String,
      required: [true, "Password is required"],
      minlength: [6, "Password must be at least 6 characters"],
      select: false,
    },
    phoneNumber: {
      type: String,
      trim: true,
    },
    profilePicture: {
      type: String,
      default: "default-profile.png",
      trim: true,
    },
    role: {
      type: String,
      enum: ["user", "admin"],
      default: "user",
    },
    refreshToken: {
      type: String,
      select: false,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Virtual for ID
userSchema.virtual("id").get(function () {
  return this._id.toString();
});

// Collation-based case-insensitive username index
userSchema.index(
  { username: 1 },
  { unique: true, collation: { locale: "en", strength: 2 } }
);

// Pre-save hook to hash password
userSchema.pre("save", async function () {
  if (!this.isModified("password")) {
    return;
  }

  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  console.log(`[AUTH:HASH] Password hashed for ${this.email}`);
});

// Sign Access Token
userSchema.methods.getSignedJwtToken = function () {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error("JWT_SECRET environment variable is required");
  }
  return jwt.sign(
    { id: this._id, email: this.email, role: this.role },
    secret,
    {
      expiresIn: process.env.JWT_EXPIRE || "1d",
    }
  );
};

// Sign Refresh Token
userSchema.methods.getSignedRefreshToken = function () {
  const secret = process.env.JWT_REFRESH_SECRET;
  if (!secret) {
    throw new Error("JWT_REFRESH_SECRET environment variable is required");
  }
  return jwt.sign(
    { id: this._id, email: this.email, role: this.role },
    secret,
    {
      expiresIn: process.env.JWT_REFRESH_EXPIRE || "7d",
    }
  );
};

// Match password
userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Return safe profile object (no password or refresh token)
userSchema.methods.safeProfile = function () {
  const profile = this.toObject();
  delete profile.password;
  delete profile.refreshToken;
  return profile;
};

module.exports = mongoose.model("User", userSchema, "users");
