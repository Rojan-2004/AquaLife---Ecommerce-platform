import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/dashboard/presentation/view_model/dashboard_view_model.dart';
import 'package:aqua_life/features/dashboard/presentation/state/dashboard_state.dart';

void main() {
  group('DashboardViewModel Tests', () {
    test('initial state should have currentIndex 0', () {
      final container = ProviderContainer();
      final state = container.read(dashboardViewModelProvider);

      expect(state.currentIndex, 0);

      container.dispose();
    });

test('updateCurrentIndex should allow switching between tabs', () {
      final container = ProviderContainer();
      final viewModel = container.read(dashboardViewModelProvider.notifier);

      viewModel.updateCurrentIndex(1);
      expect(container.read(dashboardViewModelProvider).currentIndex, 1);

      viewModel.updateCurrentIndex(3);
      expect(container.read(dashboardViewModelProvider).currentIndex, 3);

      viewModel.updateCurrentIndex(0);
      expect(container.read(dashboardViewModelProvider).currentIndex, 0);

      container.dispose();
    });
  });
}
