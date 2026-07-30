// Maps a product's stored image filenames to publicly servable URLs.
// Files live in public/item_photos, exposed at /item_photos.
// Skips the placeholder default so clients can fall back to their own UI.
const DEFAULT_IMAGE = "default-product.png";

function productImageUrls(product) {
    const raw = product.toObject ? product.toObject() : product;
    const list = [];
    if (Array.isArray(raw.images) && raw.images.length) {
        list.push(...raw.images);
    } else if (raw.image) {
        list.push(raw.image);
    }
    return list
        .filter((img) => img && img !== DEFAULT_IMAGE && !String(img).startsWith("http"))
        .map((img) => `/item_photos/${img}`);
}

module.exports = { productImageUrls };
