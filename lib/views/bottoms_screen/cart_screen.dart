import 'package:flutter/material.dart';
import 'app_theme.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<Map<String, dynamic>> _items = [
    {'name': 'Neon Tetra Bundle', 'sub': 'Pack of 10', 'price': 1299, 'qty': 1},
    {'name': 'Premium Coral', 'sub': 'Decor piece', 'price': 4499, 'qty': 1},
  ];

  int get _total =>
      _items.fold(0, (sum, i) => sum + (i['price'] as int) * (i['qty'] as int));

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: const [
                Icon(Icons.water_drop, color: kAccent, size: 20),
                SizedBox(width: 8),
                Text(
                  'My Cart',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Items
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(color: kSub),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _cartItem(i),
                  ),
          ),

          // Total + checkout
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: kCard,
              border: Border(top: BorderSide(color: kBorder)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(color: kSub, fontSize: 16),
                    ),
                    Text(
                      'Rs. $_total',
                      style: const TextStyle(
                        color: kAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cartItem(int i) {
    final item = _items[i];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kBorder),
      ),
      child: Row(
        children: [
          // Placeholder image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: kInput,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.image, color: kBorder, size: 28),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  item['sub'],
                  style: const TextStyle(color: kSub, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs. ${item['price']}',
                  style: const TextStyle(
                    color: kAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Qty controls
          Row(
            children: [
              _qtyBtn(Icons.remove, () {
                if (item['qty'] > 1)
                  setState(() => _items[i]['qty']--);
                else
                  setState(() => _items.removeAt(i));
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${item['qty']}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _qtyBtn(Icons.add, () => setState(() => _items[i]['qty']++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: kMid,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: kAccent, size: 16),
    ),
  );
}
