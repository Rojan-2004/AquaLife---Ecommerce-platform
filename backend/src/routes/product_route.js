const express = require("express");
const router = express.Router();
const Product = require("../models/product_model");
const Review = require("../models/review_model");

function toImageArray(p) {
    if (Array.isArray(p.images) && p.images.length) return p.images;
    if (p.image) return [p.image];
    return [];
}

// Map stored filenames to publicly servable URLs. The DB stores only the
// filename (e.g. "itm-pic-123.jpeg"); static files live under
// public/item_photos, exposed at /item_photos. Skip the placeholder default
// so the client can fall back to its own empty-state UI.
const DEFAULT_IMAGE = "default-product.png";

function toImageUrls(p) {
    return toImageArray(p)
        .filter((img) => img && img !== DEFAULT_IMAGE && !img.startsWith("http"))
        .map((img) => `/item_photos/${img}`);
}

// GET /api/v1/products  (public catalogue)
router.get("/", async (req, res, next) => {
    try {
        const category = req.query.category;
        const search = req.query.search;
        const featured = req.query.featured === "true";
        const minPrice = typeof req.query.minPrice === "string" ? Number(req.query.minPrice) : NaN;
        const maxPrice = typeof req.query.maxPrice === "string" ? Number(req.query.maxPrice) : NaN;
        const sort = typeof req.query.sort === "string" ? req.query.sort : "";
        const page = parseInt(req.query.page, 10) || 1;
        const limit = Math.min(parseInt(req.query.limit, 10) || 12, 24);
        const skip = (page - 1) * limit;

        const query = { isActive: true };
        if (featured) query.isFeatured = true;
        if (category && category !== "All") query.category = category;
        if (search) query.name = { $regex: search, $options: "i" };
        if (Number.isFinite(minPrice) && minPrice >= 0) query.price = { ...(query.price || {}), $gte: minPrice };
        if (Number.isFinite(maxPrice) && maxPrice >= 0) query.price = { ...(query.price || {}), $lte: maxPrice };

        let sortOption = { createdAt: -1 };
        if (sort === "price_asc") sortOption = { price: 1 };
        else if (sort === "price_desc") sortOption = { price: -1 };

        const [products, total] = await Promise.all([
            Product.find(query)
                .sort(sortOption)
                .skip(skip)
                .limit(limit),
            Product.countDocuments(query),
        ]);

        const mapped = products.map((p) => {
            const obj = p.toObject();
            return { ...obj, images: toImageUrls(obj), id: obj.id };
        });

        res.status(200).json({
            success: true,
            products: mapped,
            total,
            pages: Math.ceil(total / limit),
        });
    } catch (err) {
        next(err);
    }
});

// GET /api/v1/products/category-counts  (public category counts)
router.get("/category-counts", async (req, res, next) => {
    try {
        const counts = await Product.aggregate([
            { $match: { isActive: true } },
            { $group: { _id: "$category", count: { $sum: 1 } } },
            { $project: { category: "$_id", count: 1, _id: 0 } },
        ]);

        res.status(200).json({
            success: true,
            counts: counts.reduce((acc, cur) => ({ ...acc, [cur.category]: cur.count }), {}),
        });
    } catch (err) {
        next(err);
    }
});

// GET /api/v1/products/:id  (public single product with reviews)
router.get("/:id", async (req, res, next) => {
    try {
        const product = await Product.findOne({
            _id: req.params.id,
            isActive: true,
        });
        if (!product) {
            return res
                .status(404)
                .json({ success: false, message: "Product not found" });
        }

        const reviews = await Review.find({ product: req.params.id })
            .populate("user", "firstName lastName")
            .sort({ createdAt: -1 })
            .limit(20)
            .lean();

        const obj = product.toObject();
        const mappedReviews = reviews.map((r) => ({
            id: r.id,
            rating: r.rating,
            comment: r.comment,
            createdAt: r.createdAt,
            user: r.user
                ? { firstName: r.user.firstName, lastName: r.user.lastName }
                : null,
        }));

        res.status(200).json({
            success: true,
            product: { ...obj, images: toImageUrls(obj), id: obj.id },
            reviews: mappedReviews,
        });
    } catch (err) {
        next(err);
    }
});

module.exports = router;
