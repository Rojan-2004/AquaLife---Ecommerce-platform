const {
  app,
  request,
  connectDatabase,
  clearDatabase,
  disconnectDatabase,
  createTestUser,
  createAdminUser,
  getAuthToken,
  createProductData,
  createCategoryData,
} = require("./testUtils");

let user;
let admin;
let userToken;
let adminToken;
let product;
let outOfStockProduct;
let lowStockProduct;

beforeAll(async () => {
  await connectDatabase();
});

afterEach(async () => {
  await clearDatabase();
});

afterAll(async () => {
  await disconnectDatabase();
});

beforeEach(async () => {
  user = await createTestUser({
    email: "user1@example.com",
    username: "user1",
  });
  admin = await createAdminUser({
    email: "admin1@example.com",
    username: "admin1",
  });
  userToken = await getAuthToken({
    email: "user1@example.com",
    password: "password123",
  });
  adminToken = await getAuthToken({
    email: "admin1@example.com",
    password: "password123",
  });

  product = await createProductData({
    name: "Aqua Fish",
    price: 1200,
    stock: 10,
  });
  outOfStockProduct = await createProductData({
    name: "Sold Out Fish",
    price: 500,
    stock: 0,
    isSoldOut: true,
  });
  lowStockProduct = await createProductData({
    name: "Limited Fish",
    price: 1800,
    stock: 2,
  });
});

describe("API Integration Tests", () => {
  // Auth tests
  test("Register new user successfully", async () => {
    const response = await request(app).post("/api/v1/auth/register").send({
      firstName: "New",
      lastName: "Customer",
      email: "newcustomer@example.com",
      username: "newcustomer",
      password: "password123",
    });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.email).toBe("newcustomer@example.com");
  });

  test("Register fails for duplicate email", async () => {
    await request(app).post("/api/v1/auth/register").send({
      firstName: "New",
      lastName: "Customer",
      email: "duplicate@example.com",
      username: "duplicateuser",
      password: "password123",
    });

    const response = await request(app).post("/api/v1/auth/register").send({
      firstName: "Another",
      lastName: "Customer",
      email: "duplicate@example.com",
      username: "anotheruser",
      password: "password123",
    });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.message).toMatch(/Email already exists|email/i);
  });

  test("Login existing user successfully", async () => {
    const response = await request(app).post("/api/v1/auth/login").send({
      email: "user1@example.com",
      password: "password123",
    });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.email).toBe("user1@example.com");
    expect(response.body.token).toBeTruthy();
    expect(response.body.refreshToken).toBeTruthy();
  });

  test("Login fails with wrong password", async () => {
    const response = await request(app).post("/api/v1/auth/login").send({
      email: "user1@example.com",
      password: "wrongpassword",
    });

    expect(response.status).toBe(401);
    expect(response.body.success).toBe(false);
    expect(response.body.message).toMatch(/Invalid credentials/i);
  });

  test("Login fails for non-existent user", async () => {
    const response = await request(app).post("/api/v1/auth/login").send({
      email: "unknown@example.com",
      password: "password123",
    });

    expect(response.status).toBe(401);
    expect(response.body.success).toBe(false);
  });

  test("Get authenticated profile with valid token", async () => {
    const response = await request(app)
      .get("/api/v1/auth/me")
      .set("Authorization", `Bearer ${userToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.email).toBe("user1@example.com");
  });

  test("Get authenticated profile without token returns 401", async () => {
    const response = await request(app).get("/api/v1/auth/me");

    expect(response.status).toBe(401);
    expect(response.body.success).toBe(false);
  });

  test("Refresh token succeeds with valid refresh token", async () => {
    const loginResponse = await request(app).post("/api/v1/auth/login").send({
      email: "user1@example.com",
      password: "password123",
    });

    const response = await request(app)
      .post("/api/v1/auth/refresh-token")
      .send({
        refreshToken: loginResponse.body.refreshToken,
      });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.token).toBeTruthy();
  });

  test("Logout invalidates the access token cookie", async () => {
    const response = await request(app)
      .post("/api/v1/auth/logout")
      .set("Authorization", `Bearer ${userToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  // Category tests
  test("Admin can create a category", async () => {
    const response = await request(app)
      .post("/api/v1/categories")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ name: "Aquarium Plants", description: "Live plants for tanks" });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.name).toBe("Aquarium Plants");
  });

  test("Category creation fails when name is missing", async () => {
    const response = await request(app)
      .post("/api/v1/categories")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ description: "Missing name" });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.message).toMatch(/name is required/i);
  });

  test("Non-admin cannot create a category", async () => {
    const response = await request(app)
      .post("/api/v1/categories")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ name: "Accessories", description: "Tank decorations" });

    expect(response.status).toBe(403);
    expect(response.body.success).toBe(false);
  });

  test("Get all active categories", async () => {
    await createCategoryData({ name: "Food", description: "Fish food" });

    const response = await request(app).get("/api/v1/categories");

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.count).toBe(1);
  });

  test("Get a category by id", async () => {
    const category = await createCategoryData({
      name: "Décor",
      description: "Aquarium decorations",
    });

    const response = await request(app).get(
      `/api/v1/categories/${category._id}`,
    );

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.name).toBe("Décor");
  });

  test("Admin can update a category", async () => {
    const category = await createCategoryData({
      name: "Lighting",
      description: "Tank lights",
    });

    const response = await request(app)
      .put(`/api/v1/categories/${category._id}`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ description: "Updated lighting description" });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.description).toBe("Updated lighting description");
  });

  test("Admin can delete a category", async () => {
    const category = await createCategoryData({
      name: "TestDelete",
      description: "To be deleted",
    });

    const response = await request(app)
      .delete(`/api/v1/categories/${category._id}`)
      .set("Authorization", `Bearer ${adminToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  // Admin product tests
  test("Admin can create a product", async () => {
    const response = await request(app)
      .post("/api/v1/admin/products")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        name: "Test Product",
        price: 500,
        description: "A sample product",
        status: "active",
        stock: 20,
      });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.name).toBe("Test Product");
  });

  test("Admin product creation fails when name is missing", async () => {
    const response = await request(app)
      .post("/api/v1/admin/products")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        price: 500,
        description: "Incomplete product",
      });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
  });

  test("Admin can update a product", async () => {
    const createResponse = await request(app)
      .post("/api/v1/admin/products")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        name: "Update Product",
        price: 300,
        description: "Update test",
      });

    const response = await request(app)
      .put(`/api/v1/admin/products/${createResponse.body.data._id}`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ price: 350 });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.price).toBe(350);
  });

  test("Update product returns 404 when id not found", async () => {
    const response = await request(app)
      .put("/api/v1/admin/products/507f1f77bcf86cd799439011")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ name: "Missing Product" });

    expect(response.status).toBe(404);
    expect(response.body.success).toBe(false);
  });

  test("Admin can delete a product", async () => {
    const createResponse = await request(app)
      .post("/api/v1/admin/products")
      .set("Authorization", `Bearer ${adminToken}`)
      .send({
        name: "Delete Product",
        price: 100,
        description: "Delete test",
      });

    const response = await request(app)
      .delete(`/api/v1/admin/products/${createResponse.body.data._id}`)
      .set("Authorization", `Bearer ${adminToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  test("Public product list returns active products", async () => {
    const response = await request(app).get("/api/v1/products");

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(Array.isArray(response.body.products)).toBe(true);
  });

  test("Public product details returns product by id", async () => {
    const response = await request(app).get(`/api/v1/products/${product._id}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.product.id).toBe(product._id.toString());
  });

  test("Product category counts returns counts object", async () => {
    const response = await request(app).get("/api/v1/products/category-counts");

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.counts).toHaveProperty("Fish");
  });

  // Cart tests
  test("Empty cart returns an empty data array", async () => {
    const response = await request(app)
      .get("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data).toEqual([]);
  });

  test("Add a product to cart successfully", async () => {
    const response = await request(app)
      .post("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, quantity: 2 });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.quantity).toBe(2);
  });

  test("Add to cart fails when productId is missing", async () => {
    const response = await request(app)
      .post("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ quantity: 1 });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.message).toMatch(/productId is required/i);
  });

  test("Add out-of-stock product returns 400", async () => {
    const response = await request(app)
      .post("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: outOfStockProduct._id, quantity: 1 });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.message).toMatch(/out of stock/i);
  });

  test("Get cart returns item data after adding product", async () => {
    await request(app)
      .post("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, quantity: 1 });

    const response = await request(app)
      .get("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`);

    expect(response.status).toBe(200);
    expect(response.body.data.length).toBe(1);
    expect(response.body.data[0].product.id).toBe(product._id.toString());
  });

  test("Delete cart item fails without cartItemId", async () => {
    const response = await request(app)
      .delete("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({});

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
  });

  test("Delete cart item succeeds", async () => {
    const addResponse = await request(app)
      .post("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, quantity: 1 });

    const response = await request(app)
      .delete("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ cartItemId: addResponse.body.data.id });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  // Wishlist tests
  test("Add product to wishlist successfully", async () => {
    const response = await request(app)
      .post("/api/v1/wishlist")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.wishlisted).toBe(true);
  });

  test("Toggling wishlist removes existing item", async () => {
    await request(app)
      .post("/api/v1/wishlist")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id });

    const response = await request(app)
      .post("/api/v1/wishlist")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.wishlisted).toBe(false);
  });

  test("Get wishlist returns saved product", async () => {
    await request(app)
      .post("/api/v1/wishlist")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id });

    const response = await request(app)
      .get("/api/v1/wishlist")
      .set("Authorization", `Bearer ${userToken}`);

    expect(response.status).toBe(200);
    expect(response.body.data.length).toBe(1);
    expect(response.body.data[0].product.id).toBe(product._id.toString());
  });

  test("Wishlist toggle fails when productId is missing", async () => {
    const response = await request(app)
      .post("/api/v1/wishlist")
      .set("Authorization", `Bearer ${userToken}`)
      .send({});

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
  });

  test("Wishlist route returns 401 when no token is supplied", async () => {
    const response = await request(app)
      .post("/api/v1/wishlist")
      .send({ productId: product._id });

    expect(response.status).toBe(401);
    expect(response.body.success).toBe(false);
  });

  // Order tests
  test("Place order fails without shipping address", async () => {
    const response = await request(app)
      .post("/api/v1/orders")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ shippingAddress: {} });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
  });

  test("Place order fails when cart is empty", async () => {
    const response = await request(app)
      .post("/api/v1/orders")
      .set("Authorization", `Bearer ${userToken}`)
      .send({
        shippingAddress: {
          fullName: "Test User",
          email: "user1@example.com",
          phone: "1234567890",
          province: "Province",
          district: "District",
          city: "City",
          street: "Street",
          postalCode: "12345",
        },
      });

    expect(response.status).toBe(400);
    expect(response.body.success).toBe(false);
    expect(response.body.message).toMatch(/Cart is empty/i);
  });

  test("Place order succeeds and returns orderId", async () => {
    await request(app)
      .post("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, quantity: 2 });

    const response = await request(app)
      .post("/api/v1/orders")
      .set("Authorization", `Bearer ${userToken}`)
      .send({
        shippingAddress: {
          fullName: "Order User",
          email: "user1@example.com",
          phone: "1234567890",
          province: "Province",
          district: "District",
          city: "City",
          street: "Street",
          postalCode: "12345",
        },
      });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.orderId).toBeTruthy();
  });

  test("Order clears the cart after placement", async () => {
    await request(app)
      .post("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, quantity: 1 });

    await request(app)
      .post("/api/v1/orders")
      .set("Authorization", `Bearer ${userToken}`)
      .send({
        shippingAddress: {
          fullName: "Order User",
          email: "user1@example.com",
          phone: "1234567890",
          province: "Province",
          district: "District",
          city: "City",
          street: "Street",
          postalCode: "12345",
        },
      });

    const cartResponse = await request(app)
      .get("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`);

    expect(cartResponse.body.data).toEqual([]);
  });

  test("Get orders list returns placed orders", async () => {
    await request(app)
      .post("/api/v1/cart")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, quantity: 1 });

    await request(app)
      .post("/api/v1/orders")
      .set("Authorization", `Bearer ${userToken}`)
      .send({
        shippingAddress: {
          fullName: "Order User",
          email: "user1@example.com",
          phone: "1234567890",
          province: "Province",
          district: "District",
          city: "City",
          street: "Street",
          postalCode: "12345",
        },
      });

    const response = await request(app)
      .get("/api/v1/orders")
      .set("Authorization", `Bearer ${userToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.length).toBe(1);
  });

  // Review tests
  test("Submit a review successfully", async () => {
    const response = await request(app)
      .post("/api/v1/reviews")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, rating: 5, comment: "Excellent" });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.rating).toBe(5);
    expect(response.body.productId).toBe(product._id.toString());
  });

  test("Review submission fails when rating is missing", async () => {
    const response = await request(app)
      .post("/api/v1/reviews")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id });

    expect(response.status).toBe(400);
    expect(response.body.error).toMatch(/productId and rating are required/i);
  });

  test("Duplicate review submission returns 409", async () => {
    await request(app)
      .post("/api/v1/reviews")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, rating: 4, comment: "Good" });

    const response = await request(app)
      .post("/api/v1/reviews")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, rating: 5, comment: "Great" });

    expect(response.status).toBe(409);
    expect(response.body.error).toMatch(/already reviewed/i);
  });

  test("Get public reviews fails without productId", async () => {
    const response = await request(app).get("/api/v1/reviews");

    expect(response.status).toBe(400);
    expect(response.body.error).toMatch(/productId required/i);
  });

  test("Regular user cannot delete a review via admin delete route", async () => {
    const reviewResponse = await request(app)
      .post("/api/v1/reviews")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, rating: 4, comment: "Nice" });

    const response = await request(app)
      .delete(`/api/v1/reviews/${reviewResponse.body.id}`)
      .set("Authorization", `Bearer ${userToken}`);

    expect(response.status).toBe(403);
    expect(response.body.error).toMatch(/Only admins can delete reviews/i);
  });

  test("Admin can delete a review successfully", async () => {
    const reviewResponse = await request(app)
      .post("/api/v1/reviews")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, rating: 4, comment: "Nice" });

    const response = await request(app)
      .delete(`/api/v1/reviews/${reviewResponse.body.id}`)
      .set("Authorization", `Bearer ${adminToken}`);

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
  });

  test("Admin can update review status successfully", async () => {
    const reviewResponse = await request(app)
      .post("/api/v1/reviews")
      .set("Authorization", `Bearer ${userToken}`)
      .send({ productId: product._id, rating: 4, comment: "Nice" });

    const response = await request(app)
      .patch(`/api/v1/reviews/${reviewResponse.body.id}/status`)
      .set("Authorization", `Bearer ${adminToken}`)
      .send({ status: "hidden" });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.review.status).toBe("hidden");
  });
});
