const mongoose = require("mongoose");
const User = require("../models/user_model");
const { createUserSchema, updateUserSchema } = require("../validations/admin_user_validation");
const { z } = require("zod");

// Helper to format Zod validation errors
const formatZodError = (err) => {
  if (typeof z.prettifyError === "function") {
    return z.prettifyError(err);
  }
  return err.errors.map((e) => `${e.path.join(".")}: ${e.message}`).join(", ");
};

// @desc    Get all users (paginated and searchable)
// @route   GET /api/v1/admin/users
// @access  Private/Admin
const getAllUsers = async (req, res, next) => {
  try {
    const { page, limit, search } = req.query;

    const pageNum = parseInt(page) || 1;
    const limitNum = parseInt(limit) || 10;

    let query = {};
    if (search && search.trim() !== "") {
      const searchRegex = new RegExp(search.trim(), "i");
      query = {
        $or: [
          { name: searchRegex },
          { fullName: searchRegex },
          { firstName: searchRegex },
          { lastName: searchRegex },
          { email: searchRegex },
          { username: searchRegex },
        ],
      };
    }

    const total = await User.countDocuments(query);
    const totalPages = Math.ceil(total / limitNum);

    const users = await User.find(query)
      .skip((pageNum - 1) * limitNum)
      .limit(limitNum)
      .sort({ createdAt: -1 });

    res.status(200).json({
      success: true,
      message: "Users fetched successfully",
      data: users.map((u) => u.safeProfile()),
      meta: {
        page: pageNum,
        limit: limitNum,
        total,
        totalPages,
      },
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Get single user by ID
// @route   GET /api/v1/admin/users/:id
// @access  Private/Admin
const getUserById = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const user = await User.findById(id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    res.status(200).json({
      success: true,
      message: "User fetched successfully",
      data: user.safeProfile(),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Create new user by admin
// @route   POST /api/v1/admin/users
// @access  Private/Admin
const createUser = async (req, res, next) => {
  try {
    const validated = createUserSchema.safeParse(req.body);
    if (!validated.success) {
      return res.status(400).json({
        success: false,
        message: formatZodError(validated.error),
      });
    }

    const { firstName, lastName, email, username, password, role, status } = validated.data;
    const normalizedEmail = email.trim().toLowerCase();
    const normalizedUsername = username.trim().toLowerCase();

    // Check unique email
    const existingEmail = await User.findOne({ email: normalizedEmail }).select("_id");
    if (existingEmail) {
      return res.status(400).json({ success: false, message: "Email already exists" });
    }

    // Check unique username
    const existingUsername = await User.findOne({ username: normalizedUsername })
      .select("_id")
      .collation({ locale: "en", strength: 2 });
    if (existingUsername) {
      return res.status(400).json({ success: false, message: "Username already exists" });
    }

    const fullName = `${firstName} ${lastName}`.trim();

    const user = new User({
      firstName,
      lastName,
      name: fullName,
      fullName,
      email: normalizedEmail,
      username: normalizedUsername,
      password,
      role: role || "user",
      status: status || "active",
    });

    await user.save();

    res.status(201).json({
      success: true,
      message: "User created successfully",
      data: user.safeProfile(),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Update user details by admin
// @route   PUT /api/v1/admin/users/:id
// @access  Private/Admin
const updateUser = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const validated = updateUserSchema.safeParse(req.body);
    if (!validated.success) {
      return res.status(400).json({
        success: false,
        message: formatZodError(validated.error),
      });
    }

    const user = await User.findById(id).select("+password");
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    const { firstName, lastName, email, username, role, status, password } = validated.data;

    // Check unique email
    if (email && email.toLowerCase() !== user.email) {
      const existingEmail = await User.findOne({ email: email.toLowerCase() }).select("_id");
      if (existingEmail) {
        return res.status(400).json({ success: false, message: "Email already exists" });
      }
      user.email = email.toLowerCase();
    }

    // Check unique username
    if (username && username.toLowerCase() !== user.username) {
      const existingUsername = await User.findOne({ username: username.toLowerCase() })
        .select("_id")
        .collation({ locale: "en", strength: 2 });
      if (existingUsername && existingUsername._id.toString() !== user._id.toString()) {
        return res.status(400).json({ success: false, message: "Username already exists" });
      }
      user.username = username.toLowerCase();
    }

    if (firstName !== undefined) user.firstName = firstName;
    if (lastName !== undefined) user.lastName = lastName;
    if (role !== undefined) user.role = role;
    if (status !== undefined) user.status = status;

    if (firstName !== undefined || lastName !== undefined) {
      const fName = firstName !== undefined ? firstName : user.firstName || "";
      const lName = lastName !== undefined ? lastName : user.lastName || "";
      user.fullName = `${fName} ${lName}`.trim();
      user.name = user.fullName;
    }

    if (password && password.trim() !== "") {
      user.password = password;
    }

    if (req.file) {
      user.profilePicture = req.file.filename;
    }

    await user.save();

    res.status(200).json({
      success: true,
      message: "User updated successfully",
      data: user.safeProfile(),
    });
  } catch (err) {
    next(err);
  }
};

// @desc    Delete user
// @route   DELETE /api/v1/admin/users/:id
// @access  Private/Admin
const deleteUser = async (req, res, next) => {
  try {
    const { id } = req.params;

    if (!mongoose.Types.ObjectId.isValid(id)) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    if (req.user && id === req.user._id.toString()) {
      return res.status(400).json({
        success: false,
        message: "You cannot delete your own admin account",
      });
    }

    const user = await User.findByIdAndDelete(id);
    if (!user) {
      return res.status(404).json({ success: false, message: "User not found" });
    }

    res.status(200).json({
      success: true,
      message: "User deleted successfully",
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
};
