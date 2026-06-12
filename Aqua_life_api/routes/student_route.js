const express = require("express");
const router = express.Router();
const upload = require("../middleware/uploads");
const { protect } = require("../middleware/auth");

const {
  createStudent,
  getAllStudents,
  getStudentById,
  updateStudent,
  deleteStudent,
  loginStudent,
  uploadProfilePicture,
} = require("../controllers/student_controller");

router.post("/upload", protect, upload.single("profilePicture"), uploadProfilePicture);

router.post("/", createStudent);
router.get("/", protect, getAllStudents); // Protected - prevents user enumeration
router.post("/login", loginStudent);
router.put("/:id", protect, updateStudent);
router.delete("/:id", protect, deleteStudent);
router.get("/:id", getStudentById);

module.exports = router;
