const { z } = require("zod");

const createProductSchema = z.object({
  name: z
    .string({ required_error: "Product name is required" })
    .min(2, "Product name must be at least 2 characters long"),
  price: z.preprocess(
    (val) => (typeof val === "string" ? parseFloat(val) : val),
    z.number({ required_error: "Product price is required" }).min(0, "Price cannot be negative")
  ),
  description: z
    .string({ required_error: "Product description is required" })
    .min(5, "Description must be at least 5 characters long"),
  status: z.enum(["active", "inactive"]).optional(),
  stock: z.coerce.number().min(0, "Stock cannot be negative").default(100),
});

const updateProductSchema = z.object({
  name: z
    .string()
    .min(2, "Product name must be at least 2 characters long")
    .optional(),
  price: z.preprocess(
    (val) => (typeof val === "string" ? parseFloat(val) : val),
    z.number().min(0, "Price cannot be negative")
  ).optional(),
  description: z
    .string()
    .min(5, "Description must be at least 5 characters long")
    .optional(),
  status: z.enum(["active", "inactive"]).optional(),
  stock: z.coerce.number().min(0, "Stock cannot be negative").optional(),
});

module.exports = {
  createProductSchema,
  updateProductSchema,
};
