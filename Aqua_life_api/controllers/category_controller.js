const asyncHandler = require("../middleware/async");
const Category = require("../models/category_model");

// @desc    Create a new category
// @route   POST /api/v1/categories
// @access  Private

exports.createCategory = asyncHandler(async (req, res) => {
  const { name, description, status } = req.body;

  if (!name || typeof name !== "string") {
    return res.status(400).json({
      success: false,
      message: "Category name is required",
    });
  }

  const category = await Category.create({
    name: name.trim(),
    description: description?.trim(),
    status,
  });

  res.status(201).json({
    success: true,
    data: category,
  });
});

// @desc    Get all categories
// @route   GET /api/v1/categories
// @access  Public

exports.getAllCategories = asyncHandler(async (req, res) => {
  const categories = await Category.find({ status: "active" });

  res.status(200).json({
    success: true,
    count: categories.length,
    data: categories,
  });
});

// @desc    Get a single category by ID
// @route   GET /api/v1/categories/:id
// @access  Public

exports.getCategoryById = asyncHandler(async (req, res) => {
  const category = await Category.findById(req.params.id);

  if (!category) {
    return res.status(404).json({ message: "Category not found" });
  }

  res.status(200).json({
    success: true,
    data: category,
  });
});

// @desc    Update a category by ID
// @route   PUT /api/v1/categories/:id
// @access  Private

exports.updateCategory = asyncHandler(async (req, res) => {
  const { name, description, status } = req.body;

  const category = await Category.findByIdAndUpdate(
    req.params.id,
    { name: name?.trim(), description: description?.trim(), status },
    { new: true, runValidators: true }
  );

  if (!category) {
    return res.status(404).json({ message: "Category not found" });
  }

  res.status(200).json({
    success: true,
    data: category,
  });
});

// @desc    Delete a category by ID
// @route   DELETE /api/v1/categories/:id
// @access  Private

exports.deleteCategory = asyncHandler(async (req, res) => {
  const category = await Category.findByIdAndDelete(req.params.id);

  if (!category) {
    return res.status(404).json({ message: "Category not found" });
  }

  res.status(200).json({
    success: true,
    message: "Category deleted successfully",
  });
});
