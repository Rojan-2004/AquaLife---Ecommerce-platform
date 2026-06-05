import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/home/presentation/state/home_state.dart';

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel();
});

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(HomeState.initial());

  void updateCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }

  void toggleLike(int postIndex) {
    // Toggle like logic
  }

  void addComment(int postIndex, String comment) {
    // Add comment logic
  }
}
