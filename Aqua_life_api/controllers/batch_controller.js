const asyncHandler = require("../middleware/async");
const Batch = require("../models/batch_model");

// @desc    Create a new batch
// @route   POST /api/batches
// @access  Private (Admin)

exports.createBatch = asyncHandler(async (req, res) => {
  const { batchName, status } = req.body;

  if (!batchName || typeof batchName !== "string") {
    return res.status(400).json({
      success: false,
      message: "Batch name is required",
    });
  }

  const batch = await Batch.create({
    batchName: batchName.trim(),
    status,
  });

  res.status(201).json({
    success: true,
    data: batch,
  });
});

// @desc    Get all batches
// @route   GET /api/batches
// @access  Private (Admin)

exports.getAllBatches = asyncHandler(async (req, res) => {
  const batches = await Batch.find();

  res.status(200).json({
    success: true,
    count: batches.length,
    data: batches,
  });
});

// @desc    Get a single batch by ID
// @route   GET /api/batches/:id
// @access  Private (Admin)

exports.getBatchById = asyncHandler(async (req, res) => {
  const batch = await Batch.findById(req.params.id);

  if (!batch) {
    return res.status(404).json({ message: "Batch not found" });
  }

  res.status(200).json({
    success: true,
    data: batch,
  });
});

// @desc    Update a batch by ID
// @route   PUT /api/batches/:id
// @access  Private (Admin)

exports.updateBatch = asyncHandler(async (req, res) => {
  const { batchName, status } = req.body;

  const updates = {};
  if (batchName !== undefined) updates.batchName = batchName;
  if (status !== undefined) updates.status = status;

  const batch = await Batch.findByIdAndUpdate(req.params.id, updates, {
    new: true,
    runValidators: true,
  });

  if (!batch) {
    return res.status(404).json({ message: "Batch not found" });
  }

  res.status(200).json({
    success: true,
    data: batch,
  });
});
