const express = require("express");
const router = express.Router();
const { protect, authorize } = require("../middleware/auth");
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
router.post("/", protect, authorize("admin"), createCategory);
router.put("/:id", protect, authorize("admin"), updateCategory);
router.delete("/:id", protect, authorize("admin"), deleteCategory);

module.exports = router;
