const asyncHandler = require("../middleware/async");
const Comment = require("../models/comment_model");
const Student = require("../models/student_model");
const Item = require("../models/items_model");

// Helper function to extract mentions from text
const extractMentions = (text) => {
  // Match @username patterns
  const mentionPattern = /@(\w+)/g;
  const mentions = [];
  let match;

  while ((match = mentionPattern.exec(text)) !== null) {
    mentions.push(match[1]); // Extract username without @
  }

  return mentions;
};

// @desc    Create a new comment or reply
// @route   POST /api/v1/comments
// @access  Public (should be protected in production)
exports.createComment = asyncHandler(async (req, res) => {
  const { text, itemId, parentCommentId } = req.body;

  if (!text || !itemId) {
    return res.status(400).json({
      success: false,
      message: "Please provide text and itemId",
    });
  }

  const item = await Item.findById(itemId);
  if (!item) {
    return res.status(404).json({
      success: false,
      message: "Item not found",
    });
  }

  // Author is the authenticated user; never trust a body-supplied commentedBy.
  const commentedBy = req.user._id;

  // Extract mentioned usernames from text
  const mentionedUsernames = extractMentions(text);
  const mentionedUsers = [];

  if (mentionedUsernames.length > 0) {
    const users = await Student.find({
      username: { $in: mentionedUsernames },
    });
    mentionedUsers.push(...users.map((user) => user._id));
  }

  let isReply = false;
  if (parentCommentId) {
    const parentComment = await Comment.findById(parentCommentId);
    if (!parentComment) {
      return res.status(404).json({
        success: false,
        message: "Parent comment not found",
      });
    }
    isReply = true;
  }

  const comment = await Comment.create({
    text,
    item: itemId,
    commentedBy,
    mentionedUsers,
    parentComment: parentCommentId || null,
    isReply,
  });

  // Populate the comment before sending response
  await comment.populate([
    { path: "commentedBy", select: "name username profilePicture" },
    { path: "mentionedUsers", select: "name username" },
  ]);

  res.status(201).json({
    success: true,
    data: comment,
  });
});

// @desc    Get all comments for an item
// @route   GET /api/v1/comments/item/:itemId
// @access  Public
exports.getCommentsByItem = asyncHandler(async (req, res) => {
  const { itemId } = req.params;
  const { includeReplies, page = 1, limit = 10 } = req.query;

  // Check if item exists
  const item = await Item.findById(itemId);
  if (!item) {
    return res.status(404).json({
      success: false,
      message: "Item not found",
    });
  }

  let query = { item: itemId };

  // If includeReplies is false, only get main comments (not replies)
  if (includeReplies !== "true") {
    query.isReply = false;
  }

  const pageNum = parseInt(page, 10);
  const limitNum = parseInt(limit, 10);
  const skip = (pageNum - 1) * limitNum;

  const total = await Comment.countDocuments(query);

  const comments = await Comment.find(query)
    .populate("commentedBy", "name username profilePicture")
    .populate("mentionedUsers", "name username")
    .populate("likes", "name username")
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limitNum);

  // If we're getting main comments, also get reply counts
  if (includeReplies !== "true") {
    for (let comment of comments) {
      const replyCount = await Comment.countDocuments({
        parentComment: comment._id,
      });
      comment.replyCount = replyCount;
    }
  }

  res.status(200).json({
    success: true,
    count: comments.length,
    total,
    page: pageNum,
    pages: Math.ceil(total / limitNum),
    data: comments,
  });
});

// @desc    Get replies for a specific comment
// @route   GET /api/v1/comments/:commentId/replies
// @access  Public
exports.getRepliesByComment = asyncHandler(async (req, res) => {
  const { commentId } = req.params;
  const { page = 1, limit = 10 } = req.query;

  // Check if parent comment exists
  const parentComment = await Comment.findById(commentId);
  if (!parentComment) {
    return res.status(404).json({
      success: false,
      message: "Comment not found",
    });
  }

  const pageNum = parseInt(page, 10);
  const limitNum = parseInt(limit, 10);
  const skip = (pageNum - 1) * limitNum;

  const total = await Comment.countDocuments({ parentComment: commentId });

  const replies = await Comment.find({ parentComment: commentId })
    .populate("commentedBy", "name username profilePicture")
    .populate("mentionedUsers", "name username")
    .populate("likes", "name username")
    .sort({ createdAt: 1 }) // Oldest first for replies
    .skip(skip)
    .limit(limitNum);

  res.status(200).json({
    success: true,
    count: replies.length,
    total,
    page: pageNum,
    pages: Math.ceil(total / limitNum),
    data: replies,
  });
});

// @desc    Update a comment
// @route   PUT /api/v1/comments/:id
// @access  Private
exports.updateComment = asyncHandler(async (req, res) => {
  const { text } = req.body;

  if (!text) {
    return res.status(400).json({
      success: false,
      message: "Please provide text to update",
    });
  }

  const comment = await Comment.findById(req.params.id);

  if (!comment) {
    return res.status(404).json({
      success: false,
      message: "Comment not found",
    });
  }

  // Authorization check: Make sure user owns this comment
  if (comment.commentedBy.toString() !== req.user._id.toString()) {
    return res.status(403).json({
      success: false,
      message: "Not authorized to update this comment"
    });
  }

  // Extract new mentions
  const mentionedUsernames = extractMentions(text);
  const mentionedUsers = [];

  if (mentionedUsernames.length > 0) {
    const users = await Student.find({
      username: { $in: mentionedUsernames },
    });
    mentionedUsers.push(...users.map((user) => user._id));
  }

  // Update comment
  comment.text = text;
  comment.mentionedUsers = mentionedUsers;
  comment.isEdited = true;
  comment.editedAt = new Date();

  await comment.save();

  await comment.populate([
    { path: "commentedBy", select: "name username profilePicture" },
    { path: "mentionedUsers", select: "name username" },
  ]);

  res.status(200).json({
    success: true,
    data: comment,
  });
});

// @desc    Delete a comment
// @route   DELETE /api/v1/comments/:id
// @access  Private
exports.deleteComment = asyncHandler(async (req, res) => {
  const comment = await Comment.findById(req.params.id);

  if (!comment) {
    return res.status(404).json({
      success: false,
      message: "Comment not found",
    });
  }

  // Authorization check: Make sure user owns this comment
  if (comment.commentedBy.toString() !== req.user._id.toString()) {
    return res.status(403).json({
      success: false,
      message: "Not authorized to delete this comment"
    });
  }

  // If this is a parent comment, also delete all replies
  if (!comment.isReply) {
    await Comment.deleteMany({ parentComment: comment._id });
  }

  await Comment.findByIdAndDelete(req.params.id);

  res.status(200).json({
    success: true,
    message: "Comment deleted successfully",
  });
});

// @desc    Like/Unlike a comment
// @route   POST /api/v1/comments/:id/like
// @access  Public (should be protected)
exports.toggleLike = asyncHandler(async (req, res) => {
  // Liker is the authenticated user; never trust a body-supplied studentId,
  // otherwise any user could like/unlike on someone else's behalf.
  const studentId = req.user._id;

  const comment = await Comment.findById(req.params.id);

  if (!comment) {
    return res.status(404).json({
      success: false,
      message: "Comment not found",
    });
  }

  const likeIndex = comment.likes.findIndex(
    (id) => id.toString() === studentId.toString()
  );

  if (likeIndex > -1) {
    comment.likes.splice(likeIndex, 1);
  } else {
    comment.likes.push(studentId);
  }

  await comment.save();

  await comment.populate("likes", "name username");

  res.status(200).json({
    success: true,
    liked: likeIndex === -1,
    likeCount: comment.likes.length,
    data: comment,
  });
});

// @desc    Get all comments by a student
// @route   GET /api/v1/comments/student/:studentId
// @access  Public
exports.getCommentsByStudent = asyncHandler(async (req, res) => {
  const { studentId } = req.params;
  const { page = 1, limit = 10 } = req.query;

  // Check if student exists
  const student = await Student.findById(studentId);
  if (!student) {
    return res.status(404).json({
      success: false,
      message: "Student not found",
    });
  }

  const pageNum = parseInt(page, 10);
  const limitNum = parseInt(limit, 10);
  const skip = (pageNum - 1) * limitNum;

  const total = await Comment.countDocuments({ commentedBy: studentId });

  const comments = await Comment.find({ commentedBy: studentId })
    .populate("item", "itemName type")
    .populate("commentedBy", "name username profilePicture")
    .populate("mentionedUsers", "name username")
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limitNum);

  res.status(200).json({
    success: true,
    count: comments.length,
    total,
    page: pageNum,
    pages: Math.ceil(total / limitNum),
    data: comments,
  });
});

// @desc    Get comments where a student is mentioned
// @route   GET /api/v1/comments/mentions/:studentId
// @access  Public
exports.getMentionsByStudent = asyncHandler(async (req, res) => {
  const { studentId } = req.params;
  const { page = 1, limit = 10 } = req.query;

  // Check if student exists
  const student = await Student.findById(studentId);
  if (!student) {
    return res.status(404).json({
      success: false,
      message: "Student not found",
    });
  }

  const pageNum = parseInt(page, 10);
  const limitNum = parseInt(limit, 10);
  const skip = (pageNum - 1) * limitNum;

  const total = await Comment.countDocuments({ mentionedUsers: studentId });

  const comments = await Comment.find({ mentionedUsers: studentId })
    .populate("item", "itemName type")
    .populate("commentedBy", "name username profilePicture")
    .populate("mentionedUsers", "name username")
    .sort({ createdAt: -1 })
    .skip(skip)
    .limit(limitNum);

  res.status(200).json({
    success: true,
    count: comments.length,
    total,
    page: pageNum,
    pages: Math.ceil(total / limitNum),
    data: comments,
  });
});
