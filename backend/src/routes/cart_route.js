const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");
const CartItem = require("../models/cart_item_model");
const Product = require("../models/product_model");
const { productImageUrls } = require("../utils/images");

router.use(protect);

// Shape a cart document for the client
function serialize(item) {
    const product = item.product ? item.product.toObject() : null;
    return {
        id: item.id,
        quantity: item.quantity,
        product: product
            ? {
                  id: product.id,
                  name: product.name,
                  price: product.price,
                  category: product.category,
                  stock: product.stock,
                  images: productImageUrls(product),
              }
            : null,
    };
}

// GET /api/v1/cart  (current user's cart)
router.get("/", async (req, res, next) => {
    try {
        const items = await CartItem.find({ user: req.user._id }).populate("product");
        res.status(200).json({
            success: true,
            data: items.filter((i) => i.product).map(serialize),
        });
    } catch (err) {
        next(err);
    }
});

// POST /api/v1/cart  (add item, or increment if already present)
router.post("/", async (req, res, next) => {
    try {
        const { productId, quantity = 1 } = req.body;
        if (!productId) {
            return res
                .status(400)
                .json({ success: false, message: "productId is required" });
        }

        const product = await Product.findById(productId);
        if (!product) {
            return res
                .status(404)
                .json({ success: false, message: "Product not found" });
        }

        const qty = Math.max(1, parseInt(quantity, 10) || 1);

        // Availability / stock check
        if (product.isSoldOut || product.stock <= 0) {
            return res
                .status(400)
                .json({ success: false, message: "Product is out of stock" });
        }
        if (qty > product.stock) {
            return res
                .status(400)
                .json({ success: false, message: `Only ${product.stock} in stock` });
        }

        const existing = await CartItem.findOne({
            user: req.user._id,
            product: productId,
        });

        if (existing) {
            existing.quantity = Math.min(product.stock, existing.quantity + qty);
            await existing.save();
            await existing.populate("product");
            return res.status(200).json({ success: true, data: serialize(existing) });
        }

        const item = await CartItem.create({
            user: req.user._id,
            product: productId,
            quantity: qty,
        });
        await item.populate("product");
        return res.status(201).json({ success: true, data: serialize(item) });
    } catch (err) {
        next(err);
    }
});

// DELETE /api/v1/cart  (remove a cart line by cartItemId)
router.delete("/", async (req, res, next) => {
    try {
        const { cartItemId } = req.body;
        if (!cartItemId) {
            return res
                .status(400)
                .json({ success: false, message: "cartItemId is required" });
        }
        await CartItem.deleteOne({ _id: cartItemId, user: req.user._id });
        res.status(200).json({ success: true });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
