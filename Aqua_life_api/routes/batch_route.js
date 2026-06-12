const express = require("express");
const router = express.Router();
const { protect } = require("../middleware/auth");

const {
  createBatch,
  getAllBatches,
  getBatchById,
  updateBatch,
} = require("../controllers/batch_controller");

router.post("/", protect, createBatch);
router.get("/", getAllBatches);
router.get("/:id", getBatchById);
router.put("/:id", protect, updateBatch);

module.exports = router;
