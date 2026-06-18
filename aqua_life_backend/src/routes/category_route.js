const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");
const {
  createCategory,
  getAllCategories,
  getCategoryById,
  updateCategory,
  deleteCategory,
} = require("../controllers/category_controller");

// Public endpoints
router.get("/", getAllCategories);
router.get("/:id", getCategoryById);

// Protected endpoints
router.post("/", protect, createCategory);
router.put("/:id", protect, updateCategory);
router.delete("/:id", protect, deleteCategory);

module.exports = router;
