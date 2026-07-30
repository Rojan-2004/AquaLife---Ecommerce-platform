const Product = require("../models/product_model");
const Review = require("../models/review_model");
const { createProductSchema, updateProductSchema } = require("../validations/admin_product_validation");
const fs = require("fs");
const path = require("path");

// @desc    Get all products
// @route   GET /api/v1/admin/products
// @access  Private/Admin
const getAllProducts = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = parseInt(req.query.limit, 10) || 10;
    const skip = (page - 1) * limit;
    const search = req.query.search || "";
    const category = req.query.category || "";
    const status = req.query.status || "";
    const sortBy = req.query.sortBy || "";

    let query = {};
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: "i" } },
        { description: { $regex: search, $options: "i" } },
      ];
    }
    if (category && category !== "All") {
      query.category = category;
    }
    if (status && status !== "All") {
      query.status = status;
    }

    let sort = { createdAt: -1 };
    if (sortBy === "price_asc") {
      sort = { price: 1 };
    } else if (sortBy === "price_desc") {
      sort = { price: -1 };
    } else if (sortBy === "stock_asc") {
      sort = { stock: 1 };
    } else if (sortBy === "stock_desc") {
      sort = { stock: -1 };
    } else if (sortBy === "name_asc") {
      sort = { name: 1 };
    } else if (sortBy === "name_desc") {
      sort = { name: -1 };
    }

    const total = await Product.countDocuments(query);
    const products = await Product.find(query)
      .sort(sort)
      .skip(skip)
      .limit(limit);

    const totalPages = Math.ceil(total / limit);

    res.status(200).json({
      success: true,
      count: products.length,
      pagination: {
        page,
        limit,
        total,
        totalPages,
      },
      data: products,
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single product
// @route   GET /api/v1/admin/products/:id
// @access  Private/Admin
const getProductById = async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: `Product not found with id of ${req.params.id}`,
      });
    }

    const reviews = await Review.find({ product: product._id })
      .sort({ createdAt: -1 })
      .populate("user", "firstName lastName email");

    const avg = reviews.length
      ? reviews.reduce((s, r) => s + r.rating, 0) / reviews.length
      : 0;

    const mappedReviews = reviews.map(r => ({
      id: r._id.toString(),
      userId: r.user ? r.user._id.toString() : null,
      rating: r.rating,
      comment: r.comment,
      status: r.status || "published",
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      user: r.user
        ? { firstName: r.user.firstName, lastName: r.user.lastName, email: r.user.email }
        : { firstName: "Anonymous", lastName: "", email: "" }
    }));

    res.status(200).json({
      success: true,
      data: {
        ...product.toObject(),
        reviews: mappedReviews,
        averageRating: Math.round(avg * 10) / 10,
        totalReviews: reviews.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Create product
// @route   POST /api/v1/admin/products
// @access  Private/Admin
const createProduct = async (req, res, next) => {
  try {
    // Validate request body
    const validatedData = createProductSchema.parse(req.body);

    // Handle image file
    let imageFilename = "default-product.png";
    if (req.file) {
      imageFilename = req.file.filename;
    }

    const uploadedImages = req.file ? [req.file.filename] : [];
    const bodyImages = Array.isArray(req.body.images)
      ? req.body.images
      : req.body.images
      ? [req.body.images]
      : [];
    const images = [...uploadedImages, ...bodyImages];

    if (!req.file && bodyImages.length > 0) {
      imageFilename = bodyImages[0];
    }

    const product = await Product.create({
      ...validatedData,
      image: imageFilename,
      category: req.body.category || "Fish",
      images,
      isActive: true,
      isFeatured: req.body.isFeatured === true || req.body.isFeatured === "true",
      specs: req.body.specs && typeof req.body.specs === "object" ? req.body.specs : {},
    });

    res.status(201).json({
      success: true,
      message: "Product created successfully",
      data: product,
    });
  } catch (error) {
    // Clean up uploaded file if validation failed
    if (req.file) {
      const filePath = path.join("public", "item_photos", req.file.filename);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    if (error.name === "ZodError" || error.errors) {
      return res.status(400).json({
        success: false,
        message: "Validation failed",
        errors: error.errors || error.message,
      });
    }
    next(error);
  }
};

// @desc    Update product
// @route   PUT /api/v1/admin/products/:id
// @access  Private/Admin
const updateProduct = async (req, res, next) => {
  try {
    let product = await Product.findById(req.params.id);

    if (!product) {
      if (req.file) {
        const filePath = path.join("public", "item_photos", req.file.filename);
        if (fs.existsSync(filePath)) {
          fs.unlinkSync(filePath);
        }
      }
      return res.status(404).json({
        success: false,
        message: `Product not found with id of ${req.params.id}`,
      });
    }

    // Validate request body
    const validatedData = updateProductSchema.parse(req.body);

    // Handle image file
    if (req.file) {
      // Delete old image if it's not the default
      if (product.image && product.image !== "default-product.png") {
        const oldPath = path.join("public", "item_photos", product.image);
        if (fs.existsSync(oldPath)) {
          fs.unlinkSync(oldPath);
        }
      }
      validatedData.image = req.file.filename;

      // Keep the images array in sync: drop the previously stored file and
      // put the newly uploaded one first.
      const existingImages = Array.isArray(product.images)
        ? product.images.filter((img) => img && img !== product.image)
        : [];
      validatedData.images = [req.file.filename, ...existingImages];
    } else if (req.body.images) {
      const bodyImages = Array.isArray(req.body.images)
        ? req.body.images
        : [req.body.images];
      const existingImages = Array.isArray(product.images)
        ? product.images.filter((img) => img && img !== product.image)
        : [];
      validatedData.images = [...bodyImages, ...existingImages];
      if (bodyImages.length > 0) {
        validatedData.image = bodyImages[0];
      }
    }

    product = await Product.findByIdAndUpdate(req.params.id, validatedData, {
      new: true,
      runValidators: true,
    });

    res.status(200).json({
      success: true,
      message: "Product updated successfully",
      data: product,
    });
  } catch (error) {
    // Clean up uploaded file if validation failed
    if (req.file) {
      const filePath = path.join("public", "item_photos", req.file.filename);
      if (fs.existsSync(filePath)) {
        fs.unlinkSync(filePath);
      }
    }

    if (error.name === "ZodError" || error.errors) {
      return res.status(400).json({
        success: false,
        message: "Validation failed",
        errors: error.errors || error.message,
      });
    }
    next(error);
  }
};

// @desc    Delete product
// @route   DELETE /api/v1/admin/products/:id
// @access  Private/Admin
const deleteProduct = async (req, res, next) => {
  try {
    const product = await Product.findById(req.params.id);

    if (!product) {
      return res.status(404).json({
        success: false,
        message: `Product not found with id of ${req.params.id}`,
      });
    }

    // Delete image if not the default
    if (product.image && product.image !== "default-product.png") {
      const imgPath = path.join("public", "item_photos", product.image);
      if (fs.existsSync(imgPath)) {
        fs.unlinkSync(imgPath);
      }
    }

    await Product.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: "Product deleted successfully",
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
};
