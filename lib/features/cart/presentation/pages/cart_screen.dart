import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/app/services/api_service.dart';
import 'package:aqua_life/features/checkout/presentation/pages/checkout_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const CartScreen({super.key, this.onBack});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  List<dynamic> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCart();
  }

  Future<void> _fetchCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await ApiService.get('/api/cart');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['data'] ?? data['items'] ?? data;
        setState(() {
          _items = list is List ? list : [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch cart');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeItem(String cartItemId) async {
    try {
      final res = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/cart'),
        headers: await ApiService.headers(),
        body: jsonEncode({'cartItemId': cartItemId}),
      );
      
      if (res.statusCode == 200) {
        _fetchCart();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Item removed'),
            backgroundColor: const Color(0xFF112240),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ));
        }
      }
    } catch (_) {}
  }

  Future<void> _updateQuantity(String cartItemId, int newQty) async {
    if (newQty <= 0) {
      _removeItem(cartItemId);
      return;
    }

    try {
      final res = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/cart'),
        headers: await ApiService.headers(),
        body: jsonEncode({
          'cartItemId': cartItemId,
          'quantity': newQty,
        }),
      );

      if (res.statusCode == 200) {
        _fetchCart();
      }
    } catch (_) {}
  }

  double get subtotal {
    double sum = 0;
    for (var item in _items) {
      final prod = item['product'] ?? {};
      final price = prod['price'] as num? ?? 0;
      final quantity = item['quantity'] as int? ?? 1;
      sum += price * quantity;
    }
    return sum;
  }

  double get total => subtotal > 0 ? subtotal + 50 : 0;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 360;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A1628),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF00B4D8))),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF0A1628),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off, color: Colors.white24, size: 48),
              const SizedBox(height: 12),
              const Text('Failed to load cart', style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _fetchCart,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A3A5C)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Your Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              )
            : null,
      ),
      body: _items.isEmpty
          ? _buildEmptyState(compact)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: 8),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final prod = item['product'] ?? {};
                      final name = prod['name'] as String? ?? '';
                      final price = prod['price'] as num? ?? 0;
                      final quantity = item['quantity'] as int? ?? 1;
                      final cartItemId = item['id'] ?? item['_id'] ?? '';
                      final images = prod['images'] as List<dynamic>?;
                      final imgUrl = (images != null && images.isNotEmpty) ? images.first as String : null;
                      final fullImgUrl = ApiConstants.getFullImageUrl(imgUrl);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF112240),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1E3A5C)),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: fullImgUrl != null
                                  ? Image.network(
                                      fullImgUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (_, child, progress) => progress == null
                                          ? child
                                          : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00B4D8))),
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 60,
                                        height: 60,
                                        color: const Color(0xFF112240),
                                        child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 24),
                                      ),
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: const Color(0xFF112240),
                                      child: const Icon(Icons.set_meal, color: Colors.white24, size: 24),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text('Rs. ${price.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00B4D8), size: 20),
                                        onPressed: () => _updateQuantity(cartItemId, quantity - 1),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('$quantity', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00B4D8), size: 20),
                                        onPressed: () => _updateQuantity(cartItemId, quantity + 1),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () => _removeItem(cartItemId),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildOrderSummary(compact),
              ],
            ),
    );
  }

  Widget _buildEmptyState(bool compact) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐟', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text('Your cart is empty', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00B4D8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Browse Catalogue', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool compact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF112240),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF1E3A5C))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(color: Color(0xFF7AB8CC))),
                Text('Rs. ${subtotal.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Delivery Fee', style: TextStyle(color: Color(0xFF7AB8CC))),
                Text('Rs. 50', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(color: Color(0xFF1E3A5C), height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Rs. ${total.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF00B4D8), fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  ).then((_) => _fetchCart());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
