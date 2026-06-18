import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<_CartItem> _items = [
    _CartItem(
      name: 'Neon Tetra Bundle',
      variant: 'Pack of 10 schoolers',
      price: 1299,
      quantity: 2,
    ),
    _CartItem(
      name: 'Premium Coral',
      variant: 'Handcrafted aquarium decor',
      price: 4499,
      quantity: 1,
    ),
    _CartItem(
      name: 'Mineral Stone Filter',
      variant: 'Compact 3-stage unit',
      price: 2199,
      quantity: 1,
    ),
  ];

  bool get _isEmpty => _items.isEmpty;

  int get _itemCount => _items.fold<int>(0, (sum, item) => sum + item.quantity);

  int get _subtotal =>
      _items.fold<int>(0, (sum, item) => sum + (item.price * item.quantity));

  int get _shipping => _subtotal > 5000 ? 0 : 149;

  int get _total => _subtotal + _shipping;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: compact ? 12 : 16,
            ),
            child: Column(
              children: [
                _buildAppBar(compact),
                SizedBox(height: compact ? 14 : 18),
                _isEmpty ? _buildEmptyState(compact) : _buildCartList(compact),
                SizedBox(height: compact ? 16 : 20),
                _buildOrderSummary(compact),
                SizedBox(height: compact ? 12 : 16),
                _buildCheckoutButton(compact),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool compact) {
    return Row(
      children: [
        _buildIconButton(Icons.arrow_back_ios_new, compact, widget.onBack),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Your Cart',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 5 : 7,
          ),
          decoration: BoxDecoration(
            color: kAccent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$_itemCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon,
    bool compact,
    VoidCallback? onPressed,
  ) {
    return SizedBox(
      width: compact ? 36 : 40,
      height: compact ? 36 : 40,
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: Colors.white, size: compact ? 18 : 20),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  Widget _buildEmptyState(bool compact) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: compact ? 36 : 48),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            color: kAccent,
            size: compact ? 44 : 56,
          ),
          SizedBox(height: compact ? 10 : 14),
          Text(
            'Your cart is empty',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 15 : 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: compact ? 4 : 6),
          Text(
            'Add aquarium essentials to continue.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: kSub, fontSize: compact ? 11 : 13),
          ),
          SizedBox(height: compact ? 16 : 20),
          ElevatedButton(
            onPressed: widget.onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: kMid,
              foregroundColor: kAccent,
              minimumSize: Size(compact ? 120 : 150, compact ? 40 : 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              'Back to Home',
              maxLines: 1,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(bool compact) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (_, _) => SizedBox(height: compact ? 10 : 12),
      itemBuilder: (context, index) {
        final item = _items[index];
        return _buildCartItem(item, compact);
      },
    );
  }

  Widget _buildCartItem(_CartItem item, bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 58 : 68,
            height: compact ? 58 : 68,
            decoration: BoxDecoration(
              color: kMid,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: kAccent,
              size: 26,
            ),
          ),
          SizedBox(width: compact ? 9 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 13 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: compact ? 3 : 4),
                Text(
                  item.variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: kSub, fontSize: compact ? 10 : 12),
                ),
                SizedBox(height: compact ? 6 : 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _formatPrice(item.price),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kAccent,
                          fontSize: compact ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildQuantityStepper(item, compact),
                  ],
                ),
              ],
            ),
          ),
          _buildIconButton(Icons.delete_outline, compact, () {
            setState(() => _items.remove(item));
          }),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper(_CartItem item, bool compact) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: kMid,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: compact ? 28 : 32,
            height: compact ? 28 : 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.remove, size: 16),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  if (item.quantity > 1) {
                    item.quantity--;
                  }
                });
              },
            ),
          ),
          SizedBox(
            width: compact ? 24 : 28,
            child: Text(
              '${item.quantity}',
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: compact ? 28 : 32,
            height: compact ? 28 : 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add, size: 16),
              color: Colors.white,
              onPressed: () {
                setState(() => item.quantity++);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', _formatPrice(_subtotal), compact),
          SizedBox(height: compact ? 7 : 9),
          _buildSummaryRow(
            'Shipping',
            _shipping == 0 ? 'Free' : _formatPrice(_shipping),
            compact,
          ),
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(vertical: compact ? 8 : 10),
            color: kAccent,
          ),
          _buildSummaryRow(
            'Total',
            _formatPrice(_total),
            compact,
            emphasized: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool compact, {
    bool emphasized = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: emphasized ? Colors.white : kSub,
              fontSize: compact ? 12 : 13,
              fontWeight: emphasized ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          maxLines: 1,
          style: TextStyle(
            color: emphasized ? Colors.white : Colors.white,
            fontSize: compact ? 13 : 15,
            fontWeight: emphasized ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutButton(bool compact) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: Colors.white,
          minimumSize: Size.fromHeight(compact ? 44 : 50),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          'Checkout',
          maxLines: 1,
          style: TextStyle(
            fontSize: compact ? 13 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatPrice(int value) {
    if (value == 0) return 'Rs. 0';
    return 'Rs. ${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)},')}';
  }
}

class _CartItem {
  _CartItem({
    required this.name,
    required this.variant,
    required this.price,
    required int quantity,
  }) : _quantity = quantity;

  final String name;
  final String variant;
  final int price;
  int _quantity;

  int get quantity => _quantity;

  set quantity(int value) {
    if (value > 0) {
      _quantity = value;
    }
  }
}
