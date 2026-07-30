import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:aqua_life/app/constants/api_constants.dart';
import 'package:aqua_life/app/services/api_service.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetch orders history or stats containing orders
      final res = await ApiService.get('/api/orders');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['data'] ?? data['orders'] ?? data;
        setState(() {
          _orders = list is List ? list : [];
          _isLoading = false;
        });
      } else {
        throw Exception();
      }
    } catch (_) {
      setState(() {
        _error = 'Failed to load order history';
        _isLoading = false;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFfbbf24);
      case 'shipped':
        return const Color(0xFF818cf8);
      case 'delivered':
        return const Color(0xFF4ade80);
      case 'cancelled':
        return const Color(0xFFf87171);
      default:
        return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.54);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
        title: Text('Order History', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: cs.onSurface.withValues(alpha: 0.24), size: 48),
                  const SizedBox(height: 12),
                  Text('Failed to load order history', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.54))),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchOrders,
                    style: ElevatedButton.styleFrom(backgroundColor: cs.tertiary),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _orders.isEmpty
              ? Center(
                  child: Text('No orders placed yet', style: TextStyle(color: cs.onSurface.withValues(alpha: 0.72))),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final orderId = order['id'] ?? order['_id'] ?? '';
                    final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
                    final total = order['total'] ?? order['amount'] ?? 0;
                    final status = order['status'] ?? 'pending';
                    final dateStr = order['createdAt'] ?? '';
                    final items = order['items'] as List<dynamic>? ?? [];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF112240),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF1E3A5C)),
                      ),
                      child: ExpansionTile(
                        iconColor: const Color(0xFF00B4D8),
                        collapsedIconColor: const Color(0xFF7AB8CC),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #$shortId',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _statusColor(status)),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(color: _statusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            'Total: Rs. ${total.toStringAsFixed(0)}',
                            style: const TextStyle(color: Color(0xFF00B4D8), fontWeight: FontWeight.bold),
                          ),
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            color: const Color(0xFF0D1F35),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (dateStr.isNotEmpty) ...[
                                  Text('Date: ${dateStr.split("T").first}', style: const TextStyle(color: Color(0xFF7AB8CC), fontSize: 12)),
                                  const SizedBox(height: 8),
                                ],
                                const Text('Items:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                ...items.map((item) {
                                  final prod = item['product'] ?? {};
                                  final name = prod['name'] ?? 'Aquarium Product';
                                  final qty = item['quantity'] ?? 1;
                                  final price = item['price'] ?? prod['price'] ?? 0;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '$name (x$qty)',
                                            style: const TextStyle(color: Color(0xFF7AB8CC), fontSize: 12),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          'Rs. ${(price * qty).toStringAsFixed(0)}',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
