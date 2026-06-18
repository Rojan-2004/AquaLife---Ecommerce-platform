const mongoose = require("mongoose");

const connectDB = async () => {
  try {
    const dbUri = process.env.LOCAL_DATABASE_URI || process.env.MONGODB_URL || process.env.MONGODB_URI || "mongodb://127.0.0.1:27017/aqua_life";
    const conn = await mongoose.connect(dbUri);
    console.log(
      `MongoDB connected to : ${conn.connection.host}`.yellow.underline.bold
    );
  } catch (error) {
    console.error(`MongoDB connection error: ${error}`.red.underline.bold);
    process.exit(1); // Exit process on DB connection failure
  }
};

module.exports = connectDB;
