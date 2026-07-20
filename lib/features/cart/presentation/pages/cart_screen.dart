import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:aqua_life/features/cart/domain/entities/cart_item_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:aqua_life/features/checkout/presentation/pages/checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartViewModelProvider);
    final compact = MediaQuery.sizeOf(context).width < 360;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 12 : 16),
            child: cartState.isEmpty
                ? _buildEmptyState(compact)
                : Column(
                    children: [
                      _buildAppBar(compact, cartState),
                      SizedBox(height: compact ? 14 : 18),
                      _buildCartList(compact, cartState.items, ref, context),
                      SizedBox(height: compact ? 16 : 20),
                      _buildOrderSummary(compact, cartState),
                      SizedBox(height: compact ? 12 : 16),
                      _buildCheckoutButton(compact, context),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool compact, cartState) {
    return Row(
      children: [
        _buildIconButton(Icons.arrow_back_ios_new, compact, onBack),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Your Cart',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white, fontSize: compact ? 16 : 18, fontWeight: FontWeight.bold),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 5 : 7),
          decoration: BoxDecoration(color: kAccent, borderRadius: BorderRadius.circular(20)),
          child: Text('${cartState.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, bool compact, VoidCallback? onPressed) {
    return SizedBox(
      width: compact ? 36 : 40,
      height: compact ? 36 : 40,
      child: IconButton(padding: EdgeInsets.zero, icon: Icon(icon, color: Colors.white, size: compact ? 18 : 20), onPressed: onPressed ?? () {}),
    );
  }

  Widget _buildEmptyState(bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: compact ? 36 : 48),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, color: kAccent, size: compact ? 44 : 56),
          SizedBox(height: compact ? 10 : 14),
          Text('Your cart is empty', style: TextStyle(color: Colors.white, fontSize: compact ? 15 : 17, fontWeight: FontWeight.bold)),
          SizedBox(height: compact ? 4 : 6),
          Text('Add aquarium essentials to continue.', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: kSub, fontSize: compact ? 11 : 13)),
          SizedBox(height: compact ? 16 : 20),
          ElevatedButton(
            onPressed: onBack,
            style: ElevatedButton.styleFrom(backgroundColor: kMid, foregroundColor: kAccent, minimumSize: Size(compact ? 120 : 150, compact ? 40 : 44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            child: Text('Back to Home', maxLines: 1, style: TextStyle(fontSize: compact ? 12 : 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(bool compact, List<CartItemModel> items, WidgetRef ref, BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => SizedBox(height: compact ? 10 : 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildCartItem(item, compact, ref, context);
      },
    );
  }

  Widget _buildCartItem(CartItemModel item, bool compact, WidgetRef ref, BuildContext ctx) {
    final imgUrl = item.image != null ? '${ApiEndpoints.baseUrl}${item.image}' : null;

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imgUrl != null
                ? CachedNetworkImage(imageUrl: imgUrl, width: compact ? 58 : 68, height: compact ? 58 : 68, fit: BoxFit.cover, placeholder: (_, __) => Container(width: compact ? 58 : 68, height: compact ? 58 : 68, color: kMid), errorWidget: (_, __, ___) => Container(width: compact ? 58 : 68, height: compact ? 58 : 68, color: kMid, child: Icon(Icons.image_not_supported, color: kSub, size: compact ? 18 : 22)))
                : Container(width: compact ? 58 : 68, height: compact ? 58 : 68, color: kMid, child: Icon(Icons.shopping_bag_outlined, color: kAccent, size: compact ? 22 : 26)),
          ),
          SizedBox(width: compact ? 9 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: compact ? 13 : 15, fontWeight: FontWeight.w600)),
                SizedBox(height: compact ? 3 : 4),
                Text(_formatPrice(item.price), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: kAccent, fontSize: compact ? 12 : 14, fontWeight: FontWeight.bold)),
                SizedBox(height: compact ? 6 : 8),
                Row(
                  children: [
                    _buildQuantityStepper(item, compact, ref),
                  ],
                ),
              ],
            ),
          ),
          _buildIconButton(Icons.delete_outline, compact, () => ref.read(cartViewModelProvider.notifier).removeFromCart(item.id)),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper(CartItemModel item, bool compact, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(color: kMid, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: compact ? 28 : 32, height: compact ? 28 : 32, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.remove, size: 16), color: Colors.white, onPressed: () => ref.read(cartViewModelProvider.notifier).updateQuantity(item.id, item.quantity - 1))),
          SizedBox(width: compact ? 24 : 28, child: Text('${item.quantity}', maxLines: 1, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
          SizedBox(width: compact ? 28 : 32, height: compact ? 28 : 32, child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.add, size: 16), color: Colors.white, onPressed: () => ref.read(cartViewModelProvider.notifier).updateQuantity(item.id, item.quantity + 1))),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool compact, cartState) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(color: kCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', _formatPrice(cartState.subtotal), compact),
          SizedBox(height: compact ? 7 : 9),
          _buildSummaryRow('Shipping', cartState.shipping == 0 ? 'Free' : _formatPrice(cartState.shipping), compact),
          Container(height: 1, margin: EdgeInsets.symmetric(vertical: compact ? 8 : 10), color: kAccent),
          _buildSummaryRow('Total', _formatPrice(cartState.total), compact, emphasized: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool compact, {bool emphasized = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: emphasized ? Colors.white : kSub, fontSize: compact ? 12 : 13, fontWeight: emphasized ? FontWeight.bold : FontWeight.w600))),
        Text(value, maxLines: 1, style: TextStyle(color: Colors.white, fontSize: compact ? 13 : 15, fontWeight: emphasized ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }

  Widget _buildCheckoutButton(bool compact, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen()));
        },
        style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.white, minimumSize: Size.fromHeight(compact ? 44 : 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
        child: Text('Checkout', maxLines: 1, style: TextStyle(fontSize: compact ? 13 : 15, fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _formatPrice(int value) {
    if (value == 0) return 'Rs. 0';
    return 'Rs. ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)},')}';
  }
}
