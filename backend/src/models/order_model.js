const mongoose = require("mongoose");

const orderSchema = new mongoose.Schema(
    {
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: "User",
            required: true,
        },
        items: [
            {
                product: {
                    type: mongoose.Schema.Types.ObjectId,
                    ref: "Product",
                },
                quantity: { type: Number, default: 1 },
                price: { type: Number, default: 0 },
            },
        ],
        total: {
            type: Number,
            default: 0,
        },
        subtotal: {
            type: Number,
            default: 0,
        },
        deliveryFee: {
            type: Number,
            default: 0,
        },
        shippingAddress: {
            fullName: String,
            email: String,
            phone: String,
            province: String,
            district: String,
            city: String,
            street: String,
            postalCode: String,
            landmark: String,
        },
        status: {
            type: String,
            enum: ["pending", "processing", "packed", "shipped", "out_for_delivery", "delivered", "cancelled"],
            default: "pending",
        },
    },
    { timestamps: true }
);

orderSchema.virtual("id").get(function () {
    return this._id.toString();
});

orderSchema.index({ status: 1 });
orderSchema.index({ createdAt: -1 });
orderSchema.index({ user: 1 });

module.exports = mongoose.model("Order", orderSchema, "orders");
