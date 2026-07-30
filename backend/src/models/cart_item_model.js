const mongoose = require("mongoose");

const cartItemSchema = new mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        product: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "Product",
            required: true,
        },
        quantity: {
            type: Number,
            default: 1,
            min: 1,
        },
    },
    { timestamps: true }
);

// One cart line per product per user
cartItemSchema.index({ user: 1, product: 1 }, { unique: true });

cartItemSchema.virtual("id").get(function () {
    return this._id.toString();
});

module.exports = mongoose.model("CartItem", cartItemSchema, "cartitems");
