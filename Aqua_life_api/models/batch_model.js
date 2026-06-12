const mongoose = require("mongoose");

const batchSchema = new mongoose.Schema({
  batchName: {
    type: String,
    required: [true, "Batch name is required"],
    trim: true,
    unique: true,
    maxlength: [50, "Batch name cannot exceed 50 characters"],
    minlength: [2, "Batch name must be at least 2 characters"],
    index: true,
  },
  status: {
    type: String,
    enum: ["active", "completed", "cancelled"],
    default: "active",
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model("Batch", batchSchema);
