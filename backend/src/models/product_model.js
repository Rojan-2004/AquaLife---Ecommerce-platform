const mongoose = require("mongoose");

const productSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, "Product name is required"],
      trim: true,
      maxlength: [100, "Product name cannot exceed 100 characters"],
    },
    price: {
      type: Number,
      required: [true, "Product price is required"],
      min: [0, "Price cannot be negative"],
    },
    description: {
      type: String,
      required: [true, "Product description is required"],
      trim: true,
    },
    image: {
      type: String,
      default: "default-product.png",
      trim: true,
    },
    status: {
      type: String,
      enum: ["active", "inactive"],
      default: "active",
    },
    category: {
      type: String,
      enum: ["Fish", "Food", "Equipment", "Plants", "Decoration"],
      default: "Fish",
    },
    images: {
      type: [String],
      default: [],
    },
    isActive: {
      type: Boolean,
      default: true,
    },
    isFeatured: {
      type: Boolean,
      default: false,
    },
    specs: {
      type: mongoose.Schema.Types.Mixed,
      default: {},
    },
    stock: {
      type: Number,
      default: 100,
      min: 0,
    },
    isSoldOut: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: true,
    toJSON: { virtuals: true },
    toObject: { virtuals: true },
  }
);

// Virtual for ID
productSchema.virtual("id").get(function () {
  return this._id.toString();
});

module.exports = mongoose.model("Product", productSchema, "products");
