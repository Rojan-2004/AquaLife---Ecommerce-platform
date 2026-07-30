const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");
const WishlistItem = require("../models/wishlist_item_model");
const Product = require("../models/product_model");

router.use(protect);

const DEFAULT_IMAGE = "default-product.png";

function toImageArray(p) {
    if (Array.isArray(p.images) && p.images.length) return p.images;
    if (p.image) return [p.image];
    return [];
}

function toImageUrls(p) {
    return toImageArray(p)
        .filter((img) => img && img !== DEFAULT_IMAGE && !img.startsWith("http"))
        .map((img) => `/item_photos/${img}`);
}

// POST /api/v1/wishlist  (toggle)
router.post("/", async (req, res, next) => {
    try {
        const { productId } = req.body;
        if (!productId) {
            return res
                .status(400)
                .json({ success: false, message: "productId is required" });
        }

        const existing = await WishlistItem.findOne({
            user: req.user._id,
            product: productId,
        });

        if (existing) {
            await WishlistItem.deleteOne({ _id: existing._id });
            return res
                .status(200)
                .json({ success: true, wishlisted: false });
        }

        await WishlistItem.create({ user: req.user._id, product: productId });
        return res.status(201).json({ success: true, wishlisted: true });
    } catch (err) {
        next(err);
    }
});

// GET /api/v1/wishlist  (current user's wishlist with product details)
router.get("/", async (req, res, next) => {
    try {
        const items = await WishlistItem.find({
            user: req.user._id,
        }).populate("product");

        const data = items
            .filter((i) => i.product)
            .map((i) => ({
                id: i.id,
                product: {
                    id: i.product.id,
                    name: i.product.name,
                    price: i.product.price,
                    category: i.product.category,
                    stock: i.product.stock ?? 0,
                    images: toImageUrls(i.product.toObject()),
                },
            }));

        res.status(200).json({ success: true, data });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
