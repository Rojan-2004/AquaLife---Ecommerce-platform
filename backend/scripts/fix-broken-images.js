const mongoose = require("mongoose");
const fs = require("fs");
const path = require("path");
require("dotenv").config();

const Product = require("../src/models/product_model");

const PUBLIC_DIR = path.join(__dirname, "..", "public", "item_photos");

async function main() {
  const uri =
    process.env.LOCAL_DATABASE_URI ||
    process.env.MONGODB_URI ||
    "mongodb://localhost:27017/aqualife";
  await mongoose.connect(uri);
  console.log("Connected to MongoDB");

  const products = await Product.find({});
  let fixed = 0;

  for (const product of products) {
    let needsUpdate = false;
    const update = {};

    // Check primary image
    if (product.image && product.image !== "default-product.png") {
      const filePath = path.join(PUBLIC_DIR, product.image);
      if (!fs.existsSync(filePath)) {
        console.log(
          `  Missing file: ${product.image} for product "${product.name}" (${product._id})`,
        );
        update.image = "default-product.png";
        needsUpdate = true;
      }
    }

    // Check images array
    if (Array.isArray(product.images) && product.images.length > 0) {
      const validImages = product.images.filter((img) => {
        if (!img || img === "default-product.png") return true;
        if (String(img).startsWith("http")) return true;
        const filePath = path.join(PUBLIC_DIR, img);
        return fs.existsSync(filePath);
      });

      if (validImages.length !== product.images.length) {
        console.log(
          `  Cleaning images array for product "${product.name}" (${product._id})`,
        );
        console.log(`    Was: ${JSON.stringify(product.images)}`);
        console.log(`    Now: ${JSON.stringify(validImages)}`);
        update.images = validImages.length > 0 ? validImages : [];
        needsUpdate = true;
      }

      if (
        validImages.length === 0 &&
        (!product.image || product.image === "default-product.png")
      ) {
        // Ensure we have at least the default
        update.image = "default-product.png";
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      await Product.findByIdAndUpdate(product._id, update);
      fixed++;
    }
  }

  console.log(
    `\nFixed ${fixed} product(s) with missing or invalid image references.`,
  );
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => mongoose.disconnect());
