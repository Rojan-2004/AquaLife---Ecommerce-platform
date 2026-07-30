const { z } = require("zod");

// Validation for creating user by admin
const createUserSchema = z.object({
  firstName: z.string().trim().min(2, "First name must be at least 2 characters"),
  lastName: z.string().trim().min(2, "Last name must be at least 2 characters"),
  email: z.string().trim().email("Invalid email address"),
  username: z.string().trim().min(3, "Username must be at least 3 characters"),
  password: z.string().min(6, "Password must be at least 6 characters"),
  role: z.enum(["user", "admin"]).default("user"),
  status: z.enum(["active", "inactive"]).default("active"),
});

// Validation for updating user by admin
const updateUserSchema = z.object({
  firstName: z.string().trim().min(2, "First name must be at least 2 characters").optional(),
  lastName: z.string().trim().min(2, "Last name must be at least 2 characters").optional(),
  email: z.string().trim().email("Invalid email address").optional(),
  username: z.string().trim().min(3, "Username must be at least 3 characters").optional(),
  role: z.enum(["user", "admin"]).optional(),
  status: z.enum(["active", "inactive"]).optional(),
  password: z.string().min(6, "Password must be at least 6 characters").optional().or(z.literal("")),
});

module.exports = {
  createUserSchema,
  updateUserSchema,
};
