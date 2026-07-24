import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/api/api_client.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:aqua_life/features/product_detail/presentation/pages/product_detail_screen.dart';

final catalogueRepoProvider = Provider<CatalogueRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CatalogueRepository(apiClient);
});

final catalogueViewModelProvider = StateNotifierProvider<CatalogueViewModel, CatalogueState>((ref) {
  final repo = ref.read(catalogueRepoProvider);
  return CatalogueViewModel(repo);
});

class CatalogueRepository {
  final ApiClient _apiClient;
  CatalogueRepository(this._apiClient);

  Future<List<Map<String, dynamic>>> fetchProducts({String category = 'All', String? search}) async {
    final queryParameters = <String, dynamic>{
      'page': 1,
      'limit': 24,
    };
    if (category != 'All') queryParameters['category'] = category;
    if (search != null && search.isNotEmpty) queryParameters['search'] = search;

    final res = await _apiClient.get(ApiEndpoints.products, queryParameters: queryParameters);
    if (res.statusCode == 200 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      return List<Map<String, dynamic>>.from(data['products'] as List<dynamic>? ?? []);
    }
    return [];
  }

  Future<List<String>> fetchCategories() async {
    final res = await _apiClient.get(ApiEndpoints.categories);
    if (res.statusCode == 200 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      return items.map((e) => e['name'] as String).toList();
    }
    return const ['All', 'Fish', 'Food', 'Equipment', 'Plants', 'Decoration'];
  }
}

class CatalogueState {
  final List<Map<String, dynamic>> products;
  final List<String> categories;
  final String selectedCategory;
  final bool isLoading;
  final String? error;

  const CatalogueState({
    this.products = const [],
    this.categories = const ['All', 'Fish', 'Food', 'Equipment', 'Plants', 'Decoration'],
    this.selectedCategory = 'All',
    this.isLoading = true,
    this.error,
  });

  CatalogueState copyWith({
    List<Map<String, dynamic>>? products,
    List<String>? categories,
    String? selectedCategory,
    bool? isLoading,
    String? error,
  }) {
    return CatalogueState(
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CatalogueViewModel extends StateNotifier<CatalogueState> {
  final CatalogueRepository _repo;
  CatalogueViewModel(this._repo) : super(const CatalogueState()) {
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        _repo.fetchProducts(category: state.selectedCategory),
        _repo.fetchCategories(),
      ]);
      state = state.copyWith(
        products: results[0] as List<Map<String, dynamic>>,
        categories: results[1] as List<String>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> selectCategory(String category) async {
    state = state.copyWith(selectedCategory: category, isLoading: true);
    await _loadAll();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    await _loadAll();
  }
}

class CatalogueScreen extends ConsumerWidget {
  const CatalogueScreen({super.key, this.initialCategory});

  final String? initialCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogueViewModelProvider);
    final compact = MediaQuery.sizeOf(context).width < 360;

    if (initialCategory != null && state.selectedCategory != initialCategory) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(catalogueViewModelProvider.notifier).selectCategory(initialCategory!);
      });
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Catalogue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(catalogueViewModelProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 12 : 16),
          child: state.isLoading && state.products.isEmpty
              ? const Center(child: CircularProgressIndicator(color: kAccent))
              : state.error != null
                  ? Center(child: Text('Failed to load: ${state.error}', style: const TextStyle(color: Colors.white54)))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryChips(state, compact, ref),
                        const SizedBox(height: 16),
                        if (state.products.isEmpty)
                          const Center(child: Text('No products found', style: TextStyle(color: Colors.white54)))
                        else
                          _buildProductGrid(state, compact, ref, context),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(CatalogueState state, bool compact, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: state.categories.map((cat) {
          final selected = cat == state.selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat, style: TextStyle(color: selected ? Colors.white : kSub)),
              backgroundColor: kCard,
              selectedColor: kAccent,
              side: BorderSide(color: selected ? kAccent : kBorder),
              onSelected: (_) => ref.read(catalogueViewModelProvider.notifier).selectCategory(cat),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductGrid(CatalogueState state, bool compact, WidgetRef ref, BuildContext ctx) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.65,
      children: state.products.map((p) {
                          return _buildProductCard(p, compact, ref, ctx);
      }).toList(),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> p, bool compact, WidgetRef ref, BuildContext ctx) {
    final name = p['name'] as String? ?? '';
    final price = p['price'] as num? ?? 0;
    final productId = p['id'] as String? ?? '';
    final images = p['images'] as List<dynamic>?;
    final imgUrl = (images != null && images.isNotEmpty) ? images.first as String : null;
    final fullImgUrl = imgUrl != null ? '${ApiEndpoints.baseUrl}$imgUrl' : null;

    return GestureDetector(
      onTap: () {
        if (productId.isNotEmpty) {
          Navigator.push(
            ctx,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: productId),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: fullImgUrl != null
                        ? CachedNetworkImage(
                            imageUrl: fullImgUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: kCard, child: const Center(child: Icon(Icons.set_meal, color: Colors.white24))),
                            errorWidget: (_, __, ___) => Container(color: kCard, child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white24))),
                          )
                        : Container(color: kCard, child: const Center(child: Icon(Icons.set_meal, color: Colors.white24))),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (productId.isNotEmpty) {
                            ProviderScope.containerOf(ctx, listen: false).read(cartViewModelProvider.notifier).addToCart(productId);
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF112240),
                                content: Text('Added to cart', style: TextStyle(color: Colors.greenAccent)),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFF1A3A5C), shape: BoxShape.circle),
                          child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rs. ${price.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: kAccent, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
