const mongoose = require("mongoose");

const itemSchema = new mongoose.Schema(
  {
    itemName: {
      type: String,
      required: [true, "Item name is required"],
      trim: true,
    },
    description: {
      type: String,
      required: [true, "Description is required"],
      trim: true,
    },
    type: {
      type: String,
      enum: ["lost", "found"],
      required: false,
    },
    category: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Category",
      required: false,
    },
    location: {
      type: String,
      trim: true,
      maxlength: [200, "Location cannot exceed 200 characters"],
      required: false,
    },
    media: {
      type: String,
      trim: true,
      required: false,
    },
    mediaType: {
      type: String,
      enum: ["photo", "video"],
      default: "photo",
    },
    claimedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Student",
      default: null,
    },
    isClaimed: {
      type: Boolean,
      default: false,
    },
    reportedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Student",
      required: [true, "Reported by is required"],
    },
    status: {
      type: String,
      required: [true, "Status is required"],
      enum: ["available", "claimed", "resolved"],
      default: "available",
    },
  },
  {
    timestamps: true,
  }
);
module.exports = mongoose.model("Item", itemSchema);
