const colors = require("colors");
const dotenv = require("dotenv");
const User = require("./src/models/user_model");

// Load environments
dotenv.config({ path: "./src/config/config.env", quiet: true });
dotenv.config({ path: "./.env", quiet: true });

const connectDB = async () => {
  const mongoose = require("mongoose");
  const dbUri = process.env.LOCAL_DATABASE_URI || process.env.MONGODB_URL || process.env.MONGODB_URI || "mongodb://127.0.0.1:27017/aqua_life";
  const conn = await mongoose.connect(dbUri);
  console.log(`MongoDB Connected: ${conn.connection.host}`.cyan.underline.bold);
};

const users = [
  {
    firstName: "Demo",
    lastName: "User",
    name: "Demo User",
    fullName: "Demo User",
    email: "demo@aqualife.com",
    username: "demouser",
    password: "password123",
    phoneNumber: "+9779801234567",
    profilePicture: "default-profile.png",
    role: "user"
  },
  {
    firstName: "Aqua",
    lastName: "Admin",
    name: "Aqua Admin",
    fullName: "Aqua Admin",
    email: "admin@aqualife.com",
    username: "aquaadmin",
    password: "password123",
    phoneNumber: "+9779801234568",
    profilePicture: "default-profile.png",
    role: "admin",
  },
];

const importData = async () => {
  try {
    await connectDB();
    await User.deleteMany();
    console.log("Old users removed...".red.inverse);

    // Creates demo users. Password hashing will automatically execute in the pre-save hook.
    const createdUsers = [];
    for (const u of users) {
      const created = await User.create(u);
      createdUsers.push(created);
    }

    console.log(`${createdUsers.length} users created`.green.inverse);
    console.log("\nDemo credentials (password: password123):".yellow.bold);
    createdUsers.forEach((user) => {
      console.log(`   Email: ${user.email} | Username: ${user.username}`);
    });

    process.exit();
  } catch (error) {
    console.error(`Error: ${error}`.red.inverse);
    process.exit(1);
  }
};

const deleteData = async () => {
  try {
    await connectDB();
    await User.deleteMany();
    console.log("Users deleted...".red.inverse);
    process.exit();
  } catch (error) {
    console.error(`Error: ${error}`.red.inverse);
    process.exit(1);
  }
};

if (process.argv[2] === "-i") {
  importData();
} else if (process.argv[2] === "-d") {
  deleteData();
} else {
  console.log("Please use -i to import demo users or -d to delete users".yellow);
  process.exit();
}
