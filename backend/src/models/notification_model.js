const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema(
    {
        type: {
            type: String,
            default: "new_order",
        },
        message: {
            type: String,
            required: true,
        },
        orderId: {
            type: String,
            default: null,
        },
        isRead: {
            type: Boolean,
            default: false,
        },
    },
    { timestamps: true }
);

notificationSchema.virtual("id").get(function () {
    return this._id.toString();
});

module.exports = mongoose.model("Notification", notificationSchema, "notifications");
