// One-time script: give existing products a sensible stock and clear the
// sold-out flag. Run with: node scripts/fix-stock.js
// (Place this file at backend/scripts/fix-stock.js and run from the backend dir.)
const mongoose = require("mongoose");
require("dotenv").config();

const Product = require("../src/models/product_model");

async function main() {
    const uri = process.env.MONGODB_URI || "mongodb://localhost:27017/aqualife";
    await mongoose.connect(uri);
    console.log("Connected to MongoDB");

    // Products that were created before `stock` existed have it unset (undefined).
    // Treat missing/0 stock as needing a default of 100.
    const result = await Product.updateMany(
        { $or: [{ stock: { $in: [0, null] } }, { stock: { $exists: false } }] },
        { $set: { stock: 100, isSoldOut: false } }
    );

    console.log(
        `Stock reset to 100 for ${result.modifiedCount} product(s) with zero/missing stock.`
    );
}

main()
    .catch((e) => {
        console.error(e);
        process.exit(1);
    })
    .finally(() => mongoose.disconnect());
