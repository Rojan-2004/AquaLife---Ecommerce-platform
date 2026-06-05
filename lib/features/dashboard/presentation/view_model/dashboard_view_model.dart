import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/dashboard/presentation/state/dashboard_state.dart';

final dashboardViewModelProvider = StateNotifierProvider<DashboardViewModel, DashboardState>((ref) {
  return DashboardViewModel();
});

class DashboardViewModel extends StateNotifier<DashboardState> {
  DashboardViewModel() : super(DashboardState.initial());

  void updateCurrentIndex(int index) {
    state = state.copyWith(currentIndex: index);
  }
}
