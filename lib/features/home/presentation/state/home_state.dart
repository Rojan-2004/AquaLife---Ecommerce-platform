class HomeState {
  final Map<String, dynamic>? bannerProduct;
  final List<Map<String, dynamic>> spotlightProducts;
  final List<Map<String, dynamic>> categories;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.bannerProduct,
    this.spotlightProducts = const [],
    this.categories = const [],
    this.isLoading = true,
    this.error,
  });

  HomeState copyWith({
    Map<String, dynamic>? bannerProduct,
    List<Map<String, dynamic>>? spotlightProducts,
    List<Map<String, dynamic>>? categories,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      bannerProduct: bannerProduct ?? this.bannerProduct,
      spotlightProducts: spotlightProducts ?? this.spotlightProducts,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
