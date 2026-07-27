import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/app/services/api_service.dart';
import 'package:aqua_life/features/product_detail/presentation/pages/product_detail_screen.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';

class CatalogueScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const CatalogueScreen({super.key, this.initialCategory});

  @override
  ConsumerState<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends ConsumerState<CatalogueScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _products = [];
  List<String> _categories = ['All'];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
    }
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCategories();
      _fetchProducts(isRefresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadingMore && _page < _totalPages) {
        _fetchProducts(isLoadMore: true);
      }
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await ApiService.get('/api/categories');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['data'] ?? data['categories'] ?? data;
        if (list is List) {
          final fetched = list.map((e) => e['name'] as String).toList();
          setState(() {
            _categories = ['All', ...fetched];
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchProducts({bool isRefresh = false, bool isLoadMore = false}) async {
    if (isRefresh) {
      setState(() {
        _page = 1;
        _isLoading = true;
        _error = null;
      });
    } else if (isLoadMore) {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final params = <String, String>{
        'page': _page.toString(),
        'limit': '10',
        if (_selectedCategory != 'All') 'category': _selectedCategory,
        if (_searchQuery.isNotEmpty) 'search': _searchQuery,
      };

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/products').replace(queryParameters: params);
      final res = await http.get(uri, headers: await ApiService.headers());

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final items = (data['products'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final total = data['pages'] as int? ?? 1;

        setState(() {
          if (isRefresh) {
            _products = items;
          } else if (isLoadMore) {
            _products.addAll(items);
            _page++;
          }
          _totalPages = total;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Catalogue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchProducts(isRefresh: true),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: 8),
              child: _buildSearchBar(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _buildCategoryChips(),
            ),
            Expanded(
              child: _buildMainContent(compact),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D1F35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3A5C)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(color: Color(0xFF4A6B82)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF7AB8CC)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Color(0xFF7AB8CC)),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    _fetchProducts(isRefresh: true);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onSubmitted: (val) {
          setState(() {
            _searchQuery = val.trim();
          });
          _fetchProducts(isRefresh: true);
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _categories.map((cat) {
          final selected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat, style: TextStyle(color: selected ? Colors.white : const Color(0xFF7AB8CC))),
              backgroundColor: const Color(0xFF112240),
              selectedColor: const Color(0xFF00B4D8),
              side: BorderSide(color: selected ? const Color(0xFF00B4D8) : const Color(0xFF1E3A5C)),
              onSelected: (_) {
                setState(() {
                  _selectedCategory = cat;
                });
                _fetchProducts(isRefresh: true);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainContent(bool compact) {
    if (_isLoading && _products.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)));
    }

    if (_error != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            const Text('Failed to load products', style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _fetchProducts(isRefresh: true),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3A5C)),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('No products found', style: TextStyle(color: Colors.white54)),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.65,
      ),
      itemCount: _products.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _products.length) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)));
        }

        final p = _products[index];
        final name = p['name'] as String? ?? '';
        final price = p['price'] as num? ?? 0;
        final productId = p['id'] as String? ?? '';
        final images = p['images'] as List<dynamic>?;
        final imgUrl = (images != null && images.isNotEmpty) ? images.first as String : null;
        final fullImgUrl = ApiConstants.getFullImageUrl(imgUrl);

        return GestureDetector(
          onTap: () {
            if (productId.isNotEmpty) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productId: productId),
                ),
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF112240),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E3A5C)),
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
                            ? Image.network(
                                fullImgUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) => progress == null
                                    ? child
                                    : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00B4D8))),
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFF112240),
                                  child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 36),
                                ),
                              )
                            : Container(
                                color: const Color(0xFF112240),
                                child: const Center(child: Icon(Icons.set_meal, color: Colors.white24, size: 36)),
                              ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              if (productId.isNotEmpty) {
                                try {
                                  final res = await ApiService.post('/api/cart', {'productId': productId, 'quantity': 1});
                                  if (res.statusCode == 200 || res.statusCode == 201) {
                                    ref.read(cartViewModelProvider.notifier).loadCart();
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: const Text('Added to cart'),
                                        backgroundColor: const Color(0xFF112240),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ));
                                    }
                                  } else {
                                    throw Exception();
                                  }
                                } catch (_) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: const Text('Failed to add to cart'),
                                      backgroundColor: const Color(0xFF7f1d1d),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ));
                                  }
                                }
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
                        style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
