const express = require("express");
const router = express.Router();
const { protect, authorize } = require("../middleware/auth");
const upload = require("../middleware/uploads");
const {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
} = require("../controllers/admin_user_controller");

// Protect all routes below this line to only authenticated admin users
router.use(protect, authorize("admin"));

router.get("/", getAllUsers);
router.get("/:id", getUserById);
router.post("/", createUser);
router.put("/:id", upload.single("profilePicture"), updateUser);
router.patch("/:id", upload.single("profilePicture"), updateUser);
router.delete("/:id", deleteUser);

module.exports = router;
