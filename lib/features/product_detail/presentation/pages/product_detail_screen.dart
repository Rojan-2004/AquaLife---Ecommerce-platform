import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/app/services/api_service.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  Map<String, dynamic>? _product;
  List<dynamic> _reviews = [];
  int _quantity = 1;
  bool _isLoadingProduct = true;
  bool _isLoadingReviews = true;
  bool _isWishlisted = false;
  String? _error;

  // Review Form state
  int _submitRating = 5;
  final _commentCtrl = TextEditingController();
  bool _submittingReview = false;

  @override
  void initState() {
    super.initState();
    _fetchProductDetails();
    _fetchReviews();
    _checkWishlistStatus();
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchProductDetails() async {
    setState(() {
      _isLoadingProduct = true;
      _error = null;
    });

    try {
      final res = await ApiService.get('/api/products/${widget.productId}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _product = data['product'] ?? data['data'] ?? data;
          _isLoadingProduct = false;
        });
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingProduct = false;
      });
    }
  }

  Future<void> _fetchReviews() async {
    try {
      final res = await ApiService.get('/api/reviews?productId=${widget.productId}');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _reviews = data['reviews'] ?? data['data'] ?? [];
          _isLoadingReviews = false;
        });
      }
    } catch (_) {
      setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _checkWishlistStatus() async {
    try {
      final res = await ApiService.get('/api/wishlist');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['data'] ?? data['wishlist'] ?? data ?? [];
        if (list is List) {
          final contains = list.any((item) {
            final prod = item['product'] ?? item;
            return prod['id'] == widget.productId || prod['_id'] == widget.productId;
          });
          setState(() {
            _isWishlisted = contains;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _toggleWishlist() async {
    try {
      final res = await ApiService.post('/api/wishlist', {'productId': widget.productId});
      if (res.statusCode == 200 || res.statusCode == 201) {
        setState(() {
          _isWishlisted = !_isWishlisted;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_isWishlisted ? 'Added to wishlist' : 'Removed from wishlist'),
            backgroundColor: const Color(0xFF112240),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Failed to update wishlist'),
          backgroundColor: const Color(0xFF7f1d1d),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Future<void> _addToCart() async {
    final stock = _product?['stock'] as int? ?? 0;
    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Product is out of stock'),
        backgroundColor: const Color(0xFF7f1d1d),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    try {
      final res = await ApiService.post('/api/cart', {
        'productId': widget.productId,
        'quantity': _quantity,
      });

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

  Future<void> _submitReview() async {
    if (_commentCtrl.text.trim().isEmpty) return;
    setState(() => _submittingReview = true);

    try {
      final res = await ApiService.post('/api/reviews', {
        'productId': widget.productId,
        'rating': _submitRating,
        'comment': _commentCtrl.text.trim(),
      });

      setState(() => _submittingReview = false);

      if (res.statusCode == 200 || res.statusCode == 201) {
        _commentCtrl.clear();
        _fetchReviews();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Review submitted successfully!'),
            backgroundColor: const Color(0xFF112240),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      } else {
        final data = jsonDecode(res.body);
        throw Exception(data['error'] ?? data['message'] ?? 'Failed to submit review');
      }
    } catch (e) {
      setState(() => _submittingReview = false);
      if (mounted) {
        final errMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(errMsg),
          backgroundColor: const Color(0xFF7f1d1d),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  Widget _buildStockIndicator(int stock) {
    final color = stock > 10 ? const Color(0xFF4ade80)
                : stock > 0  ? const Color(0xFFfbbf24)
                : const Color(0xFFf87171);
    final label = stock > 10 ? '✓ In Stock'
                : stock > 0  ? 'Only $stock left'
                : '✗ Out of Stock';
    return Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingProduct) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8))),
      );
    }

    if (_error != null || _product == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        appBar: AppBar(title: const Text('Product Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white24, size: 48),
              const SizedBox(height: 12),
              const Text('Failed to load product details', style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchProductDetails,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3A5C)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final p = _product!;
    final name = p['name'] as String? ?? '';
    final price = p['price'] as num? ?? 0;
    final description = p['description'] as String? ?? '';
    final category = p['category'] as String? ?? '';
    final stock = p['stock'] as int? ?? 0;
    final images = p['images'] as List<dynamic>?;
    final imgUrl = (images != null && images.isNotEmpty) ? images.first as String : null;
    final fullImgUrl = ApiConstants.getFullImageUrl(imgUrl);

    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Product Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isWishlisted ? Icons.favorite : Icons.favorite_border, color: _isWishlisted ? Colors.red : Colors.white),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (fullImgUrl != null)
              Image.network(
                fullImgUrl,
                width: double.infinity,
                height: compact ? 220 : 280,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00B4D8))),
                errorBuilder: (_, __, ___) => Container(
                  height: compact ? 220 : 280,
                  color: const Color(0xFF112240),
                  child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 48),
                ),
              )
            else
              Container(
                height: compact ? 220 : 280,
                color: const Color(0xFF112240),
                child: const Center(child: Icon(Icons.image, color: Colors.white24, size: 48)),
              ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category label
                  if (category.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A3A5C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(category, style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 10),
                  ],

                  // Title & Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStockIndicator(stock),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Price
                  Text(
                    'Rs. ${price.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text('Description', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(color: Color(0xFF7AB8CC), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),

                  // Stepper & Add to Cart
                  if (stock > 0) ...[
                    Row(
                      children: [
                        const Text('Quantity', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF112240),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E3A5C)),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Color(0xFF00B4D8)),
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                              ),
                              Text('$_quantity', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add, color: Color(0xFF00B4D8)),
                                onPressed: () {
                                  if (_quantity < stock) {
                                    setState(() => _quantity++);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 55,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            onPressed: stock > 0 ? _addToCart : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4D8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Reviews List
                  const Text('Customer Reviews', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_isLoadingReviews)
                    const Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8)))
                  else if (_reviews.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF112240),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E3A5C)),
                      ),
                      child: const Center(
                        child: Text('No reviews for this product yet.', style: TextStyle(color: Color(0xFF7AB8CC))),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reviews.length,
                      itemBuilder: (context, idx) {
                        final rev = _reviews[idx];
                        final user = rev['user'] ?? {};
                        final name = user.isNotEmpty
                            ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim()
                            : 'User';
                        final comment = rev['comment'] ?? rev['text'] ?? '';
                        final rating = rev['rating'] as int? ?? 5;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF112240),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF1E3A5C)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF1A3A5C),
                                    radius: 14,
                                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Row(
                                    children: List.generate(5, (starIdx) => Icon(
                                      starIdx < rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 14,
                                    )),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (comment.isNotEmpty)
                                Text(comment, style: const TextStyle(color: Color(0xFF7AB8CC), fontSize: 13)),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),

                  // Submit Review Form
                  const Text('Write a Review', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF112240),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF1E3A5C)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Rating: ', style: TextStyle(color: Colors.white)),
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(5, (idx) {
                                final starRating = idx + 1;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() => _submitRating = starRating);
                                  },
                                  child: Icon(
                                    idx < _submitRating ? Icons.star : Icons.star_border,
                                    color: Colors.amber,
                                    size: 28,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentCtrl,
                          style: const TextStyle(color: Colors.white),
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Share your thoughts about this product...',
                            hintStyle: TextStyle(color: Color(0xFF4A6B82)),
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submittingReview ? null : _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00B4D8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: _submittingReview
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Submit Review', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
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
