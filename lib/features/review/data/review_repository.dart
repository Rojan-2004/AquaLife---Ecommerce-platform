import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/core/api/api_client.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:aqua_life/features/review/domain/entities/review_model.dart';

class ReviewRepository {
  final ApiClient _apiClient;
  ReviewRepository(this._apiClient);

  Future<ReviewSummary> fetchReviews(String productId) async {
    final res = await _apiClient.get(
      ApiEndpoints.reviews,
      queryParameters: {'productId': productId},
    );
    if (res.statusCode == 200 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      final reviews = data['reviews'] as List<dynamic>? ?? [];
      return ReviewSummary(
        reviews: reviews.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>)).toList(),
        averageRating: (data['averageRating'] as num?)?.toDouble() ?? 0.0,
        total: data['total'] as int? ?? 0,
      );
    }
    return const ReviewSummary(reviews: [], averageRating: 0.0, total: 0);
  }

  Future<ReviewModel?> submitReview(String productId, int rating, String comment) async {
    final res = await _apiClient.post(
      ApiEndpoints.reviews,
      data: {'productId': productId, 'rating': rating, 'comment': comment},
    );
    if (res.statusCode == 201 && res.data != null) {
      return ReviewModel.fromJson(res.data as Map<String, dynamic>);
    }
    return null;
  }
}

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return ReviewRepository(apiClient);
});
