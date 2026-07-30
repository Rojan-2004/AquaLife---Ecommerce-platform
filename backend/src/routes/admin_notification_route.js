const express = require("express");
const router = express.Router();
const { protect, authorize } = require("../middleware/auth");
const Notification = require("../models/notification_model");

// All notification endpoints are admin-only
router.use(protect);
router.use(authorize("admin"));

// GET /api/v1/admin/notifications  (latest 20)
router.get("/", async (req, res, next) => {
    try {
        const notifications = await Notification.find()
            .sort({ createdAt: -1 })
            .limit(20)
            .lean();
        const data = notifications.map((n) => ({
            id: n._id.toString(),
            type: n.type,
            message: n.message,
            orderId: n.orderId,
            isRead: n.isRead,
            createdAt: n.createdAt,
        }));
        res.status(200).json({ success: true, data });
    } catch (err) {
        next(err);
    }
});

// PATCH /api/v1/admin/notifications  (mark all as read)
router.patch("/", async (req, res, next) => {
    try {
        await Notification.updateMany({ isRead: false }, { isRead: true });
        res.status(200).json({ success: true });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
