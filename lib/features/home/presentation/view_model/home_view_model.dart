import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/home/data/home_repository.dart';
import 'package:aqua_life/features/home/presentation/state/home_state.dart';

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  final repo = ref.read(homeRepositoryProvider);
  return HomeViewModel(repo);
});

class HomeViewModel extends StateNotifier<HomeState> {
  final HomeRepository _repo;
  HomeViewModel(this._repo) : super(const HomeState()) {
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        _repo.fetchBannerProduct(),
        _repo.fetchSpotlightProducts(),
        _repo.fetchCategories(),
      ]);

      final banner = results[0] as Map<String, dynamic>?;
      final spotlight = results[1] as List<Map<String, dynamic>>;
      final categories = results[2] as List<Map<String, dynamic>>;

      if (banner != null && spotlight.isNotEmpty && spotlight.first['id'] == banner['id']) {
        spotlight.removeAt(0);
      }

      state = state.copyWith(
        bannerProduct: banner,
        spotlightProducts: spotlight,
        categories: categories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadAll();
  }
}
