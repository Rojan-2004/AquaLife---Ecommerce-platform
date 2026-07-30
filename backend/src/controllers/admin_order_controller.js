const Order = require("../models/order_model");

// GET /api/v1/admin/orders - list all orders with pagination, search, filter, sort
const getAdminOrders = async (req, res, next) => {
    try {
        const page = parseInt(req.query.page, 10) || 1;
        const limit = parseInt(req.query.limit, 10) || 10;
        const skip = (page - 1) * limit;
        const search = (req.query.search || "").trim();
        const status = (req.query.status || "").trim();
        const sortParam = (req.query.sort || req.query.sortBy || "newest").trim();

        let query = {};
        if (search) {
            query.$or = [
                { "shippingAddress.fullName": { $regex: search, $options: "i" } },
                { "shippingAddress.email": { $regex: search, $options: "i" } },
                { "shippingAddress.phone": { $regex: search, $options: "i" } },
            ];
        }
        if (status) {
            query.status = status;
        }

        const total = await Order.countDocuments(query);
        let sort = {};
        switch (sortParam) {
            case "oldest":
                sort = { createdAt: 1 };
                break;
            case "highest_total":
                sort = { total: -1 };
                break;
            case "lowest_total":
                sort = { total: 1 };
                break;
            default:
                sort = { createdAt: -1 };
        }

        const orders = await Order.find(query)
            .sort(sort)
            .skip(skip)
            .limit(limit)
            .populate("user", "firstName lastName email phoneNumber")
            .populate("items.product", "name image images price")
            .lean();

        const totalPages = Math.ceil(total / limit);

        res.status(200).json({
            success: true,
            data: orders.map((o) => ({
                ...o,
                id: o._id.toString(),
                customerName: [o.user?.firstName, o.user?.lastName].filter(Boolean).join(" ") || "Customer",
                email: o.user?.email || "",
                phone: o.user?.phoneNumber || "",
            })),
            pagination: { page, limit, total, totalPages },
        });
    } catch (err) {
        next(err);
    }
};

// GET /api/v1/admin/orders/:id - single order detail
const getAdminOrderById = async (req, res, next) => {
    try {
        const order = await Order.findById(req.params.id)
            .populate("user", "firstName lastName email phoneNumber username")
            .populate("items.product", "name image images price category stock");

        if (!order) {
            return res.status(404).json({ success: false, message: "Order not found" });
        }

        res.status(200).json({
            success: true,
            data: {
                ...order.toObject(),
                id: order._id.toString(),
            },
        });
    } catch (err) {
        next(err);
    }
};

// PATCH /api/v1/admin/orders/:id/status - update order status
const updateOrderStatus = async (req, res, next) => {
    try {
        let { status } = req.body;

        if (!status) {
            return res.status(400).json({ success: false, message: "Status is required" });
        }

        // Normalize status string
        status = status.toLowerCase().trim().replace(/\s+/g, "_");

        const validStatuses = ["pending", "processing", "packed", "shipped", "out_for_delivery", "delivered", "cancelled"];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({ success: false, message: "Invalid status: " + status });
        }

        const order = await Order.findById(req.params.id);
        if (!order) {
            return res.status(404).json({ success: false, message: "Order not found" });
        }

        order.status = status;
        await order.save();

        res.status(200).json({
            success: true,
            message: `Order status updated to ${status}`,
            data: { ...order.toObject(), id: order._id.toString() },
        });
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getAdminOrders,
    getAdminOrderById,
    updateOrderStatus,
};
