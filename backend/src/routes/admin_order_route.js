const express = require("express");
const router = express.Router();
const { protect, authorize } = require("../middleware/auth");
const {
    getAdminOrders,
    getAdminOrderById,
    updateOrderStatus,
} = require("../controllers/admin_order_controller");

router.use(protect);
router.use(authorize("admin"));

router.get("/", getAdminOrders);
router.get("/:id", getAdminOrderById);
router.patch("/:id/status", updateOrderStatus);

module.exports = router;
