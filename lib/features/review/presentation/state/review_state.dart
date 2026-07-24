import 'package:aqua_life/features/review/domain/entities/review_model.dart';

class ReviewState {
  final ReviewSummary summary;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? submitError;

  const ReviewState({
    this.summary = const ReviewSummary(reviews: [], averageRating: 0.0, total: 0),
    this.isLoading = true,
    this.isSubmitting = false,
    this.error,
    this.submitError,
  });

  ReviewState copyWith({
    ReviewSummary? summary,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? submitError,
  }) {
    return ReviewState(
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
      submitError: submitError ?? this.submitError,
    );
  }
}
