const mongoose = require("mongoose");
const { MongoMemoryServer } = require("mongodb-memory-server");
const request = require("supertest");
const app = require("../src/app");
const User = require("../src/models/user_model");
const Product = require("../src/models/product_model");
const Category = require("../src/models/category_model");
const CartItem = require("../src/models/cart_item_model");
const WishlistItem = require("../src/models/wishlist_item_model");
const Review = require("../src/models/review_model");
const Order = require("../src/models/order_model");

process.env.NODE_ENV = "test";
process.env.DISABLE_RATE_LIMIT = "true";
process.env.JWT_SECRET = process.env.JWT_SECRET || "test_jwt_secret";
process.env.JWT_REFRESH_SECRET =
  process.env.JWT_REFRESH_SECRET || "test_refresh_secret";
process.env.FRONTEND_URL = process.env.FRONTEND_URL || "http://localhost:3001";

let mongoServer;

const connectDatabase = async () => {
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri(), {
    autoIndex: true,
  });
};

const clearDatabase = async () => {
  const collections = mongoose.connection.collections;
  for (const key of Object.keys(collections)) {
    await collections[key].deleteMany({});
  }
};

const disconnectDatabase = async () => {
  await mongoose.disconnect();
  if (mongoServer) {
    await mongoServer.stop();
  }
};

const createTestUser = async (overrides = {}) => {
  const defaults = {
    firstName: "Test",
    lastName: "User",
    email: "user@example.com",
    username: "testuser",
    password: "password123",
    role: "user",
  };
  const user = new User({ ...defaults, ...overrides });
  await user.save();
  return user;
};

const createAdminUser = async (overrides = {}) => {
  return createTestUser({
    role: "admin",
    email: "admin@example.com",
    username: "adminuser",
    ...overrides,
  });
};

const getAuthToken = async ({ email, password }) => {
  const response = await request(app)
    .post("/api/v1/auth/login")
    .send({ email, password });
  return response.body.token;
};

const requestWithToken = (token) =>
  request(app).set("Authorization", `Bearer ${token}`);

const createProductData = async (overrides = {}) => {
  const defaults = {
    name: "Aqua Fish",
    price: 2500,
    description: "A premium aquarium fish for freshwater tanks.",
    status: "active",
    category: "Fish",
    stock: 10,
  };
  return Product.create({ ...defaults, ...overrides });
};

const createCategoryData = async (overrides = {}) => {
  const defaults = {
    name: "Fish",
    description: "Freshwater fish category",
    status: "active",
  };
  return Category.create({ ...defaults, ...overrides });
};

const createCartItem = async ({ user, product, quantity = 1 }) => {
  return CartItem.create({ user: user._id, product: product._id, quantity });
};

const createWishlistItem = async ({ user, product }) => {
  return WishlistItem.create({ user: user._id, product: product._id });
};

const createReview = async ({
  user,
  product,
  rating = 5,
  comment = "Great product",
}) => {
  return Review.create({
    user: user._id,
    product: product._id,
    rating,
    comment,
  });
};

const createOrderData = async ({
  user,
  items,
  shippingAddress,
  total,
  subtotal,
  deliveryFee = 50,
}) => {
  return Order.create({
    user: user._id,
    items,
    shippingAddress,
    total,
    subtotal,
    deliveryFee,
    status: "pending",
  });
};

module.exports = {
  app,
  request,
  requestWithToken,
  connectDatabase,
  clearDatabase,
  disconnectDatabase,
  createTestUser,
  createAdminUser,
  getAuthToken,
  createProductData,
  createCategoryData,
  createCartItem,
  createWishlistItem,
  createReview,
  createOrderData,
};
