import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/review/data/review_repository.dart';
import 'package:aqua_life/features/review/presentation/state/review_state.dart';

final reviewViewModelProvider = StateNotifierProvider<ReviewViewModel, ReviewState>((ref) {
  final repo = ref.read(reviewRepositoryProvider);
  return ReviewViewModel(repo);
});

class ReviewViewModel extends StateNotifier<ReviewState> {
  final ReviewRepository _repo;
  ReviewViewModel(this._repo) : super(const ReviewState());

  Future<void> loadReviews(String productId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final summary = await _repo.fetchReviews(productId);
      state = state.copyWith(summary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> submitReview(String productId, int rating, String comment) async {
    try {
      state = state.copyWith(isSubmitting: true, submitError: null);
      final review = await _repo.submitReview(productId, rating, comment);
      if (review != null) {
        await loadReviews(productId);
        state = state.copyWith(isSubmitting: false);
        return true;
      }
      state = state.copyWith(isSubmitting: false);
      return false;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submitError: e.toString());
      return false;
    }
  }
}