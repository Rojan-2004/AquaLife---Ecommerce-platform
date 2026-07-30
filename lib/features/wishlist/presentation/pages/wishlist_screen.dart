import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/app/services/api_service.dart';
import 'package:aqua_life/features/product_detail/presentation/pages/product_detail_screen.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await ApiService.get('/api/wishlist');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['data'] ?? data['wishlist'] ?? data;
        setState(() {
          _items = list is List ? list : [];
          _isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (_) {
      setState(() {
        _error = 'Failed to load wishlist';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleWishlist(String productId) async {
    try {
      final res = await ApiService.post('/api/wishlist', {'productId': productId});
      if (res.statusCode == 200 || res.statusCode == 201) {
        _fetchWishlist();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Wishlist updated'),
            backgroundColor: Theme.of(context).colorScheme.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 360;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('My Wishlist', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: cs.onSurface.withValues(alpha: 0.24), size: 48),
                  const SizedBox(height: 12),
                  Text('Failed to load wishlist', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.54))),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchWishlist,
                    style: ElevatedButton.styleFrom(backgroundColor: cs.tertiary),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _items.isEmpty
              ? Center(
                  child: Text('No items in your wishlist yet', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72))),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: _items.length,
                  itemBuilder: (context, idx) {
                    final item = _items[idx];
                    final p = item['product'] ?? item;
                    final name = p['name'] as String? ?? '';
                    final price = p['price'] as num? ?? 0;
                    final productId = p['id'] ?? p['_id'] ?? '';
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
                          ).then((_) => _fetchWishlist());
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.outline),
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
                                              color: cs.surface,
                                              child: Icon(Icons.image_not_supported, color: cs.onSurface.withValues(alpha: 0.24), size: 36),
                                            ),
                                          )
                                        : Container(
                                            color: cs.surface,
                                            child: Center(child: Icon(Icons.set_meal, color: cs.onSurface.withValues(alpha: 0.24), size: 36)),
                                          ),
                                  ),
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(20),
                                        onTap: () => _toggleWishlist(productId),
                                     child: Container(
                                           padding: const EdgeInsets.all(6),
                                           decoration: BoxDecoration(color: cs.tertiary, shape: BoxShape.circle),
                                           child: const Icon(Icons.favorite, color: Colors.red, size: 16),
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
                                     style: TextStyle(color: cs.onSurface, fontSize: 13, fontWeight: FontWeight.w600),
                                   ),
                                   const SizedBox(height: 4),
                                   Text(
                                     'Rs. ${price.toStringAsFixed(0)}',
                                     maxLines: 1,
                                     overflow: TextOverflow.ellipsis,
                                     style: TextStyle(color: cs.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                   ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
