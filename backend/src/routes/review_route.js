const express = require("express");
const router = express.Router();
const Review = require("../models/review_model");
const Order = require("../models/order_model");
const { protect } = require("../middleware/auth");

function toImageArray(p) {
    if (Array.isArray(p.images) && p.images.length) return p.images;
    if (p.image) return [p.image];
    return [];
}

function toImageUrls(p) {
    const DEFAULT_IMAGE = "default-product.png";
    return toImageArray(p)
        .filter((img) => img && img !== DEFAULT_IMAGE && !img.startsWith("http"))
        .map((img) => `/item_photos/${img}`);
}

// GET — current user's own reviews with product info
router.get("/my", protect, async (req, res, next) => {
    try {
        const reviews = await Review.find({ user: req.user._id, status: { $ne: "hidden" } })
            .sort({ createdAt: -1 })
            .populate("product", "name price category image images");

        const mapped = reviews.map(r => {
            const obj = r.product ? r.product.toObject() : {};
            return {
                id: r._id.toString(),
                productId: obj._id ? obj._id.toString() : null,
                productName: obj.name || "Unknown Product",
                productPrice: obj.price || 0,
                productCategory: obj.category || "",
                productImages: toImageUrls(obj),
                rating: r.rating,
                comment: r.comment,
                createdAt: r.createdAt,
                status: r.status,
            };
        });

        res.status(200).json({ success: true, reviews: mapped, total: mapped.length });
    } catch (err) {
        next(err);
    }
});

// GET — fetch reviews for a product
router.get("/", async (req, res, next) => {
    try {
        const productId = req.query.productId;

        if (!productId) {
            return res.status(400).json({ error: "productId required" });
        }

        const reviews = await Review.find({ product: productId })
            .sort({ createdAt: -1 })
            .populate("user", "firstName lastName");

        // Calculate average rating
        const avg = reviews.length
            ? reviews.reduce((s, r) => s + r.rating, 0) / reviews.length
            : 0;

        // Map for virtual fields / clean responses
        const mappedReviews = reviews.map(r => ({
            id: r._id.toString(),
            userId: r.user ? r.user._id.toString() : null,
            productId: r.product ? r.product.toString() : null,
            rating: r.rating,
            comment: r.comment,
            createdAt: r.createdAt,
            user: r.user ? { firstName: r.user.firstName, lastName: r.user.lastName } : { firstName: "Anonymous", lastName: "" }
        }));

        return res.status(200).json({
            success: true,
            reviews: mappedReviews,
            averageRating: Math.round(avg * 10) / 10,
            total: reviews.length
        });
    } catch (err) {
        next(err);
    }
});

// DELETE — admin only
router.delete("/:id", protect, async (req, res, next) => {
    try {
        if (req.user.role !== "admin") {
            return res.status(403).json({ error: "Only admins can delete reviews" });
        }

        const review = await Review.findById(req.params.id);
        if (!review) {
            return res.status(404).json({ error: "Review not found" });
        }

        await Review.findByIdAndDelete(req.params.id);
        res.status(200).json({ success: true, message: "Review deleted successfully" });
    } catch (err) {
        next(err);
    }
});

// PATCH — update review status (admin only)
router.patch("/:id/status", protect, async (req, res, next) => {
    try {
        if (req.user.role !== "admin") {
            return res.status(403).json({ error: "Only admins can moderate reviews" });
        }

        const { status } = req.body;
        if (!["published", "hidden", "reported"].includes(status)) {
            return res.status(400).json({ error: "Invalid status. Use published, hidden, or reported." });
        }

        const review = await Review.findById(req.params.id);
        if (!review) {
            return res.status(404).json({ error: "Review not found" });
        }

        review.status = status;
        await review.save();

        const populated = await Review.findById(review._id)
            .populate("user", "firstName lastName");

        res.status(200).json({
            success: true,
            review: {
                id: populated._id.toString(),
                rating: populated.rating,
                comment: populated.comment,
                status: populated.status,
                createdAt: populated.createdAt,
                user: populated.user
                    ? { firstName: populated.user.firstName, lastName: populated.user.lastName }
                    : { firstName: "Anonymous", lastName: "" }
            }
        });
    } catch (err) {
        next(err);
    }
});

// POST — submit a review (logged-in non-admin users only)
router.post("/", protect, async (req, res, next) => {
    try {
        if (req.user.role === "admin") {
            return res.status(403).json({ error: "Admins cannot review products" });
        }

        const { productId, rating, comment } = req.body;

        if (!productId || !rating) {
            return res.status(400).json({ error: "productId and rating are required" });
        }

        const parsedRating = parseInt(rating);
        if (parsedRating < 1 || parsedRating > 5) {
            return res.status(400).json({ error: "Rating must be between 1 and 5" });
        }

        // Check if user already reviewed this product
        const existing = await Review.findOne({ user: req.user._id, product: productId });
        if (existing) {
            return res.status(409).json({ error: "You have already reviewed this product" });
        }

        // Check user has actually ordered this product (optional check)
        // const hasPurchased = await Order.findOne({
        //     user: req.user._id,
        //     status: { $in: ["delivered", "shipped"] },
        //     "items.product": productId
        // });
        // if (!hasPurchased) {
        //     return res.status(403).json({ error: "You can only review products you have purchased" });
        // }

        const review = await Review.create({
            user: req.user._id,
            product: productId,
            rating: parsedRating,
            comment: comment?.trim() || null,
        });

        const populatedReview = await Review.findById(review._id)
            .populate("user", "firstName lastName");

        return res.status(201).json({
            success: true,
            id: populatedReview._id.toString(),
            userId: populatedReview.user._id.toString(),
            productId: populatedReview.product.toString(),
            rating: populatedReview.rating,
            comment: populatedReview.comment,
            createdAt: populatedReview.createdAt,
            user: {
                firstName: populatedReview.user.firstName,
                lastName: populatedReview.user.lastName
            }
        });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
