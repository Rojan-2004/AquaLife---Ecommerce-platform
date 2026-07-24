class ReviewModel {
  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String? comment;
  final String firstName;
  final String lastName;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.rating,
    this.comment,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      productId: json['productId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
      firstName: json['user'] is Map<String, dynamic>
          ? (json['user'] as Map<String, dynamic>)['firstName'] as String? ?? ''
          : (json['firstName'] as String?) ?? '',
      lastName: json['user'] is Map<String, dynamic>
          ? (json['user'] as Map<String, dynamic>)['lastName'] as String? ?? ''
          : (json['lastName'] as String?) ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get fullName => '$firstName ${lastName.trim()}';
}

class ReviewSummary {
  final List<ReviewModel> reviews;
  final double averageRating;
  final int total;

  const ReviewSummary({
    required this.reviews,
    required this.averageRating,
    required this.total,
  });
}
