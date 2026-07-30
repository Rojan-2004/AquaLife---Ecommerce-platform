const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");
const CartItem = require("../models/cart_item_model");
const Order = require("../models/order_model");
const Notification = require("../models/notification_model");
const Product = require("../models/product_model");

const SHIPPING_FLAT = 50;
const FREE_SHIPPING_THRESHOLD = 50000;

router.use(protect);

// GET /api/v1/orders  (user's own orders)
router.get("/", async (req, res, next) => {
    try {
        const userId = req.user._id;
        const page = parseInt(req.query.page, 10) || 1;
        const limit = parseInt(req.query.limit, 10) || 10;
        const skip = (page - 1) * limit;
        const status = (req.query.status || "").trim();

        let query = { user: userId };
        if (status) {
            query.status = status;
        }

        const total = await Order.countDocuments(query);
        const orders = await Order.find(query)
            .sort({ createdAt: -1 })
            .skip(skip)
            .limit(limit)
            .populate("items.product", "name image images price")
            .lean();

        const totalPages = Math.ceil(total / limit);

        res.status(200).json({
            success: true,
            data: orders.map((o) => ({
                ...o,
                id: o._id.toString(),
                items: (o.items || []).map((it) => ({
                    ...it,
                    product: it.product
                        ? {
                            ...it.product,
                            id: it.product._id.toString(),
                            image: it.product.image || null,
                            images: it.product.images || [],
                        }
                        : null,
                })),
            })),
            pagination: { page, limit, total, totalPages },
        });
    } catch (err) {
        next(err);
    }
});

// POST /api/v1/orders  (place order, clear cart, notify admin)
router.post("/", async (req, res, next) => {
    try {
        const userId = req.user._id;
        const { shippingAddress } = req.body;

        if (
            !shippingAddress ||
            !shippingAddress.fullName ||
            !shippingAddress.email ||
            !shippingAddress.phone ||
            !shippingAddress.province ||
            !shippingAddress.district ||
            !shippingAddress.city ||
            !shippingAddress.street ||
            !shippingAddress.postalCode
        ) {
            return res
                .status(400)
                .json({ success: false, message: "Shipping address is required." });
        }

        const cartItems = await CartItem.find({ user: userId }).populate("product");
        const validItems = cartItems.filter((i) => i.product);

        if (validItems.length === 0) {
            return res
                .status(400)
                .json({ success: false, message: "Cart is empty" });
        }

        // Totals
        const subtotal = validItems.reduce(
            (sum, i) => sum + i.product.price * i.quantity,
            0
        );
        const deliveryFee = subtotal > FREE_SHIPPING_THRESHOLD ? 0 : SHIPPING_FLAT;
        const total = subtotal + deliveryFee;

        const order = await Order.create({
            user: userId,
            total,
            subtotal,
            deliveryFee,
            status: "pending",
            shippingAddress,
            items: validItems.map((i) => ({
                product: i.product._id,
                quantity: i.quantity,
                price: i.product.price,
            })),
        });

        // Clear the cart
        await CartItem.deleteMany({ user: userId });

        // Decrement stock for each purchased item
        await Promise.all(
            validItems.map((i) =>
                Product.findByIdAndUpdate(i.product._id, {
                    $inc: { stock: -i.quantity },
                })
            )
        );

        // Notify admin
        const itemNames = validItems
            .map((i) => `${i.product.name} x${i.quantity}`)
            .join(", ");
        const shortId = order._id.toString().slice(0, 8);
        await Notification.create({
            type: "new_order",
            orderId: order._id.toString(),
            message: `New order #${shortId} from ${shippingAddress.fullName} — ${itemNames} — Rs. ${total.toLocaleString()}`,
        });

        res.status(201).json({ success: true, orderId: order._id.toString() });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
