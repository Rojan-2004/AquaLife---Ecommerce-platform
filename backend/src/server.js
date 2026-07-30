const app = require("./app");
const dotenv = require("dotenv");
const colors = require("colors");
const connectDB = require("./config/db");

// Load environment variables
dotenv.config({ path: "./config/config.env", quiet: true });
dotenv.config({ path: "./.env", quiet: true });

// Connect to database
connectDB();

// Start server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(
    `Server running in ${process.env.NODE_ENV || "development"} mode on port ${PORT}`.green.bold
      .underline
  );
});
