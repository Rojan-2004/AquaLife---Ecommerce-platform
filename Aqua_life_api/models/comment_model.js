const mongoose = require("mongoose");

const commentSchema = new mongoose.Schema(
  {
    text: {
      type: String,
      required: [true, "Comment text is required"],
      trim: true,
    },
    item: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Item",
      required: [true, "Item reference is required"],
    },
    commentedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Student",
      required: [true, "Commenter reference is required"],
    },
    // Tagged/mentioned users in the comment (e.g., @username)
    mentionedUsers: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Student",
      },
    ],
    // For nested replies - parent comment reference
    parentComment: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Comment",
      default: null,
    },
    // Track if this is a reply or main comment
    isReply: {
      type: Boolean,
      default: false,
    },
    // Like count (optional feature)
    likes: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Student",
      },
    ],
    // Track if comment has been edited
    isEdited: {
      type: Boolean,
      default: false,
    },
    editedAt: {
      type: Date,
      default: null,
    },
  },
  {
    timestamps: true, // Automatically manage createdAt and updatedAt fields
  }
);

// Virtual field to get reply count
commentSchema.virtual("replyCount", {
  ref: "Comment",
  localField: "_id",
  foreignField: "parentComment",
  count: true,
});

// Ensure virtuals are included in JSON output
commentSchema.set("toJSON", { virtuals: true });
commentSchema.set("toObject", { virtuals: true });

// Index for faster queries
commentSchema.index({ item: 1, createdAt: -1 });
commentSchema.index({ parentComment: 1 });
commentSchema.index({ commentedBy: 1 });

module.exports = mongoose.model("Comment", commentSchema);
