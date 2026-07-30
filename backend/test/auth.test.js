const request = require("supertest");
const mongoose = require("mongoose");
const { MongoMemoryServer } = require("mongodb-memory-server");

process.env.NODE_ENV = "test";
process.env.JWT_SECRET = process.env.JWT_SECRET || "test_jwt_secret";
process.env.JWT_REFRESH_SECRET =
  process.env.JWT_REFRESH_SECRET || "test_refresh_secret";

const app = require("../src/app");
const User = require("../src/models/user_model");

let mongoServer;

beforeAll(async () => {
  jest.setTimeout(30000);
  mongoServer = await MongoMemoryServer.create();
  await mongoose.connect(mongoServer.getUri());
}, 30000);

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
}, 30000);

afterEach(async () => {
  await User.deleteMany({});
});

describe("Auth API", () => {
  test("Register new user", async () => {
    const response = await request(app).post("/api/v1/auth/register").send({
      firstName: "Test",
      lastName: "User",
      email: "test@example.com",
      username: "testuser",
      password: "password123",
    });

    expect(response.status).toBe(201);
    expect(response.body.success).toBe(true);
    expect(response.body.data.email).toBe("test@example.com");
  });

  test("Login existing user", async () => {
    await request(app).post("/api/v1/auth/register").send({
      firstName: "Login",
      lastName: "User",
      email: "login@example.com",
      username: "loginuser",
      password: "password123",
    });

    const response = await request(app)
      .post("/api/v1/auth/login")
      .send({ email: "login@example.com", password: "password123" });

    expect(response.status).toBe(200);
    expect(response.body.success).toBe(true);
    expect(response.body.data.email).toBe("login@example.com");
  });
});
