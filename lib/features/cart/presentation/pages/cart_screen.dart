import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/features/checkout/presentation/pages/checkout_screen.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';

class CartScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const CartScreen({super.key, this.onBack});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(cartViewModelProvider.notifier).loadCart());
  }

  Future<void> _removeItem(String cartItemId) async {
    await ref.read(cartViewModelProvider.notifier).removeFromCart(cartItemId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item removed'),
          backgroundColor: const Color(0xFF112240),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _updateQuantity(String cartItemId, int newQty) async {
    await ref.read(cartViewModelProvider.notifier).updateQuantity(cartItemId, newQty);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final compact = MediaQuery.sizeOf(context).width < 360;
    final cartState = ref.watch(cartViewModelProvider);

    if (cartState.isLoading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(
          child: CircularProgressIndicator(color: cs.primary),
        ),
      );
    }

    if (cartState.error != null) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: cs.onSurface.withValues(alpha: 0.24), size: 48),
              const SizedBox(height: 12),
              Text(
                'Failed to load cart',
                style: TextStyle(color: cs.onSurface.withValues(alpha: 0.54)),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(cartViewModelProvider.notifier).loadCart(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.tertiary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final items = cartState.items;
    final subtotal = items.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
    final total = subtotal > 0 ? subtotal.toDouble() + 50 : 0.0;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Your Cart',
          style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold),
        ),
        leading: widget.onBack != null
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: cs.onSurface),
                onPressed: widget.onBack,
              )
            : null,
      ),
      body: items.isEmpty
          ? _buildEmptyState(compact)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 12 : 16,
                      vertical: 8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final name = item.name;
                      final price = item.price;
                      final quantity = item.quantity;
                      final cartItemId = item.id;
                      final imgUrl = item.image;
                      final fullImgUrl = ApiConstants.getFullImageUrl(imgUrl);

                       return Container(
                         margin: const EdgeInsets.only(bottom: 12),
                         padding: const EdgeInsets.all(12),
                         decoration: BoxDecoration(
                           color: cs.surface,
                           borderRadius: BorderRadius.circular(16),
                           border: Border.all(color: cs.outline),
                         ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: fullImgUrl.isNotEmpty
                                  ? Image.network(
                                      fullImgUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) =>
                                          progress == null
                                          ? child
                                          : const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Color(0xFF00B4D8),
                                              ),
                                            ),
                                       errorBuilder: (context, error, stackTrace) => Container(
                                         width: 60,
                                         height: 60,
                                         color: cs.surface,
                                         child: Icon(
                                           Icons.image_not_supported,
                                           color: cs.onSurface.withValues(alpha: 0.24),
                                           size: 24,
                                         ),
                                       ),
                                     )
                                   : Container(
                                       width: 60,
                                       height: 60,
                                       color: cs.surface,
                                       child: Icon(
                                         Icons.set_meal,
                                         color: cs.onSurface.withValues(alpha: 0.24),
                                         size: 24,
                                       ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                     name,
                                     style: TextStyle(
                                       color: cs.onSurface,
                                       fontWeight: FontWeight.bold,
                                       fontSize: 14,
                                     ),
                                   ),
                                   const SizedBox(height: 4),
                                   Text(
                                     'Rs. ${price.toStringAsFixed(0)}',
                                     style: TextStyle(
                                       color: cs.primary,
                                       fontWeight: FontWeight.bold,
                                     ),
                                   ),
                                   const SizedBox(height: 6),
                                   Row(
                                     children: [
                                       IconButton(
                                         icon: Icon(
                                           Icons.remove_circle_outline,
                                           color: cs.primary,
                                           size: 20,
                                         ),
                                         onPressed: () => _updateQuantity(
                                           cartItemId,
                                           quantity - 1,
                                         ),
                                         padding: EdgeInsets.zero,
                                         constraints: const BoxConstraints(),
                                       ),
                                       const SizedBox(width: 8),
                                       Text(
                                         '$quantity',
                                         style: TextStyle(
                                           color: cs.onSurface,
                                           fontWeight: FontWeight.bold,
                                         ),
                                       ),
                                       const SizedBox(width: 8),
                                       IconButton(
                                         icon: Icon(
                                           Icons.add_circle_outline,
                                           color: cs.primary,
                                           size: 20,
                                         ),
                                         onPressed: () => _updateQuantity(
                                           cartItemId,
                                           quantity + 1,
                                         ),
                                         padding: EdgeInsets.zero,
                                         constraints: const BoxConstraints(),
                                       ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _removeItem(cartItemId),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                _buildOrderSummary(compact, subtotal, total),
              ],
            ),
    );
  }

  Widget _buildEmptyState(bool compact) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐟', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Browse Catalogue',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool compact, double subtotal, double total) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72)),
                ),
                Text(
                  'Rs. ${subtotal.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Delivery Fee',
                  style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72)),
                ),
                Text(
                  'Rs. 50',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(color: cs.outline, height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Rs. ${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: cs.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Proceed to Checkout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
