const asyncHandler = require("../middleware/async");
const Item = require("../models/items_model");
const path = require("path");
const fs = require("fs");

// @desc    Create a new item
// @route   POST /api/v1/items
// @access  Public
exports.createItem = asyncHandler(async (req, res) => {
  const { itemName, description, type, category, location, media } = req.body;

  // Owner is taken from the authenticated user, never from request body, so an
  // attacker cannot create items on behalf of another student.
  const item = await Item.create({
    itemName,
    description,
    type,
    category,
    location,
    media,
    reportedBy: req.user._id,
  });

  res.status(201).json({
    success: true,
    data: item,
  });
});

// @desc    Get all items
// @route   GET /api/v1/items
// @access  Public
exports.getAllItems = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page, 10) || 1;
  const limit = parseInt(req.query.limit, 10) || 10;
  const skip = (page - 1) * limit;

  // Build filter object
  const filter = {};
  if (req.query.type) filter.type = req.query.type;
  if (req.query.status) filter.status = req.query.status;
  if (req.query.category) filter.category = req.query.category;

  const total = await Item.countDocuments(filter);
  const items = await Item.find(filter)
    .populate("reportedBy", "name username")
    .populate("claimedBy", "name username")
    .populate("category", "name")
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limit);

  res.status(200).json({
    success: true,
    count: items.length,
    total,
    page,
    pages: Math.ceil(total / limit),
    data: items,
  });
});

// @desc    Get a single item by ID
// @route   GET /api/v1/items/:id
// @access  Public
exports.getItemById = asyncHandler(async (req, res) => {
  const item = await Item.findById(req.params.id)
    .populate("reportedBy", "name username")
    .populate("claimedBy", "name username")
    .populate("category", "name");

  if (!item) {
    return res.status(404).json({ message: "Item not found" });
  }

  res.status(200).json({
    success: true,
    data: item,
  });
});

// @desc    Update an item
// @route   PUT /api/v1/items/:id
// @access  Private
exports.updateItem = asyncHandler(async (req, res) => {
  const {
    itemName,
    description,
    type,
    category,
    location,
    media,
    claimedBy,
    isClaimed,
    status,
  } = req.body;

  const item = await Item.findById(req.params.id);

  if (!item) {
    return res.status(404).json({ message: "Item not found" });
  }

  // Authorization check: Make sure user owns this item
  if (item.reportedBy.toString() !== req.user._id.toString()) {
    return res.status(403).json({
      message: "Not authorized to update this item",
    });
  }

  // Update the item fields
  item.itemName = itemName || item.itemName;
  item.description = description || item.description;
  item.type = type || item.type;
  item.category = category || item.category;
  item.location = location || item.location;
  item.media = media || item.media;
  item.claimedBy = claimedBy || item.claimedBy;
  item.isClaimed = isClaimed !== undefined ? isClaimed : item.isClaimed;
  item.status = status || item.status;

  await item.save();

  res.status(200).json({
    success: true,
    data: item,
  });
});

// @desc    Delete an item
// @route   DELETE /api/v1/items/:id
// @access  Private
exports.deleteItem = asyncHandler(async (req, res) => {
  const item = await Item.findById(req.params.id);

  if (!item) {
    return res.status(404).json({ message: "Item not found" });
  }

  // Authorization check: Make sure user owns this item
  if (item.reportedBy.toString() !== req.user._id.toString()) {
    return res.status(403).json({
      message: "Not authorized to delete this item",
    });
  }

  // Remove the item's media file if it exists
  if (item.media && item.media !== "default.jpg") {
    // Check if it's a photo or video based on file extension
    const ext = path.extname(item.media).toLowerCase();
    let mediaPath;

    if ([".jpg", ".jpeg", ".png", ".gif"].includes(ext)) {
      mediaPath = path.join(__dirname, "../public/item_photos", item.media);
    } else if ([".mp4", ".avi", ".mov", ".wmv"].includes(ext)) {
      mediaPath = path.join(__dirname, "../public/item_videos", item.media);
    }

    if (mediaPath && fs.existsSync(mediaPath)) {
      fs.unlinkSync(mediaPath);
    }
  }

  await Item.findByIdAndDelete(req.params.id);

  res.status(200).json({
    success: true,
    message: "Item deleted successfully",
  });
});

// @desc    Upload Item Photo
// @route   POST /api/v1/items/upload-photo
// @access  Public
exports.uploadItemPhoto = asyncHandler(async (req, res, next) => {
  if (!req.file) {
    return res.status(400).send({ message: "Please upload a photo file" });
  }

  // Check for the file size
  if (req.file.size > process.env.MAX_FILE_UPLOAD) {
    return res.status(400).send({
      message: `Please upload an image less than ${process.env.MAX_FILE_UPLOAD} bytes`,
    });
  }

  res.status(200).json({
    success: true,
    data: req.file.filename,
    message: "Item photo uploaded successfully",
  });
});

// @desc    Upload Item Video
// @route   POST /api/v1/items/upload-video
// @access  Public
exports.uploadItemVideo = asyncHandler(async (req, res, next) => {
  if (!req.file) {
    return res.status(400).send({ message: "Please upload a video file" });
  }

  // Check for the file size
  if (req.file.size > process.env.MAX_FILE_UPLOAD) {
    return res.status(400).send({
      message: `Please upload a video less than ${process.env.MAX_FILE_UPLOAD} bytes`,
    });
  }

  res.status(200).json({
    success: true,
    data: req.file.filename,
    message: "Item video uploaded successfully",
  });
});
