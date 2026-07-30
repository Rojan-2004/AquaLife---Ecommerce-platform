const express = require("express");
const router = express.Router();
const {
  getAllProducts,
  getProductById,
  createProduct,
  updateProduct,
  deleteProduct,
} = require("../controllers/admin_product_controller");
const { protect, authorize } = require("../middleware/auth");
const upload = require("../middleware/uploads");

// Secure all routes with authentication and role check (admin)
router.use(protect);
router.use(authorize("admin"));

router
  .route("/")
  .get(getAllProducts)
  .post(upload.single("itemPhoto"), createProduct);

router
  .route("/:id")
  .get(getProductById)
  .put(upload.single("itemPhoto"), updateProduct)
  .delete(deleteProduct);

module.exports = router;
