import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/home/presentation/view_model/home_view_model.dart';
import 'package:aqua_life/features/home/presentation/state/home_state.dart';
import 'package:aqua_life/features/home/data/home_repository.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  group('HomeViewModel Tests', () {
    late MockHomeRepository mockHomeRepository;
    late ProviderContainer container;

    setUp(() {
      mockHomeRepository = MockHomeRepository();
      container = ProviderContainer(
        overrides: [
          homeRepositoryProvider.overrideWithValue(mockHomeRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('refresh should load all data successfully', () async {
      final banner = {'id': 'banner1', 'name': 'Banner Product'};
      final spotlight = [
        {'id': 'spot1', 'name': 'Spotlight 1'},
        {'id': 'spot2', 'name': 'Spotlight 2'},
      ];
      final categories = <Map<String, dynamic>>[
        {'id': 'cat1', 'name': 'Fish'},
        {'id': 'cat2', 'name': 'Plants'},
      ];

      when(() => mockHomeRepository.fetchBannerProduct()).thenAnswer((_) async => banner);
      when(() => mockHomeRepository.fetchSpotlightProducts()).thenAnswer((_) async => spotlight);
      when(() => mockHomeRepository.fetchCategories()).thenAnswer((_) async => categories);

      final viewModel = container.read(homeViewModelProvider.notifier);
      await viewModel.refresh();

      final state = container.read(homeViewModelProvider);
      expect(state.bannerProduct, banner);
      expect(state.spotlightProducts.length, 2);
      expect(state.categories.length, 2);
      expect(state.error, isNull);
    });

test('refresh should remove banner from spotlight when IDs match', () async {
      final banner = {'id': 'prod1', 'name': 'Banner Product'};
      final spotlight = <Map<String, dynamic>>[
        {'id': 'prod1', 'name': 'Spotlight 1'},
        {'id': 'prod2', 'name': 'Spotlight 2'},
      ];
      final categories = <Map<String, dynamic>>[];

      when(() => mockHomeRepository.fetchBannerProduct()).thenAnswer((_) async => banner);
      when(() => mockHomeRepository.fetchSpotlightProducts()).thenAnswer((_) async => spotlight);
      when(() => mockHomeRepository.fetchCategories()).thenAnswer((_) async => categories);

      final viewModel = container.read(homeViewModelProvider.notifier);
      await viewModel.refresh();

      final state = container.read(homeViewModelProvider);
      expect(state.spotlightProducts.length, 1);
      expect(state.spotlightProducts.first['id'], 'prod2');
    });
  });
}
