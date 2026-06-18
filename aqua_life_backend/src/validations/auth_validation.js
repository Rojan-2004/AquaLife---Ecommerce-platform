const { z } = require("zod");

// Zod schema for user registration validation
const registerSchema = z.object({
  firstName: z.string().trim().min(1, "First name is required").optional(),
  lastName: z.string().trim().min(1, "Last name is required").optional(),
  name: z.string().trim().optional(),
  fullName: z.string().trim().optional(),
  email: z.string().trim().email("Invalid email address"),
  username: z.string().trim().min(3, "Username must be at least 3 characters long"),
  password: z.string().min(6, "Password must be at least 6 characters long"),
  phoneNumber: z.string().trim().optional().nullable(),
  profilePicture: z.string().trim().optional().nullable(),
}).refine(data => {
  // Ensure we have either (firstName & lastName) OR name OR fullName
  return (data.firstName && data.lastName) || data.name || data.fullName;
}, {
  message: "Provide either (firstName and lastName) or (fullName or name)",
  path: ["firstName"],
});

// Zod schema for user login validation
const loginSchema = z.object({
  email: z.string().trim().email("Invalid email address"),
  password: z.string().min(1, "Password is required"),
});

module.exports = {
  registerSchema,
  loginSchema,
};
