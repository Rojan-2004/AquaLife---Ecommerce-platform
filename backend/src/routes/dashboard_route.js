const express = require("express");
const router = express.Router();
const { protect, authorize } = require("../middleware/auth");
const {
    getAdminStats,
    getRecentOrders,
    getUserDashboard,
} = require("../controllers/dashboard_controller");

// Admin-only analytics
router.get("/admin/stats", protect, authorize("admin"), getAdminStats);
router.get(
    "/admin/orders/recent",
    protect,
    authorize("admin"),
    getRecentOrders
);

// Authenticated user dashboard (any logged-in user)
router.get("/user/dashboard", protect, getUserDashboard);

module.exports = router;
