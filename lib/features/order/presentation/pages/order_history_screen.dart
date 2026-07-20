import 'package:aqua_life/app/theme/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:aqua_life/features/order/presentation/view_model/order_view_model.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderState = ref.watch(orderViewModelProvider);
    final compact = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(orderViewModelProvider.notifier).loadOrders(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 16, vertical: compact ? 12 : 16),
          child: orderState.isLoading && orderState.orders.isEmpty
              ? const Center(child: CircularProgressIndicator(color: kAccent))
              : orderState.error != null
                  ? Center(child: Text('Failed to load: ${orderState.error}', style: const TextStyle(color: Colors.white54)))
                  : orderState.orders.isEmpty
                      ? Center(child: Text('No orders yet', style: TextStyle(color: kSub, fontSize: compact ? 14 : 16)))
                      : Column(
                          children: orderState.orders.map((order) {
                            return Container(
                              margin: EdgeInsets.only(bottom: compact ? 10 : 12),
                              padding: EdgeInsets.all(compact ? 12 : 14),
                              decoration: BoxDecoration(
                                color: kCard,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: kBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '#${order.id.substring(0, 8)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(color: Colors.white, fontSize: compact ? 13 : 14, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 8, vertical: compact ? 3 : 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(order.status),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          order.status.toUpperCase(),
                                          maxLines: 1,
                                          style: TextStyle(color: Colors.white, fontSize: compact ? 9 : 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: compact ? 6 : 8),
                                  Text('Rs. ${order.total.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match.group(1)},')}', style: TextStyle(color: kAccent, fontSize: compact ? 14 : 16, fontWeight: FontWeight.bold)),
                                  SizedBox(height: compact ? 4 : 6),
                                  ...order.items.map((item) {
                                    final imgUrl = item.image != null ? '${ApiEndpoints.baseUrl}${item.image}' : null;
                                    return Padding(
                                      padding: EdgeInsets.only(top: compact ? 6 : 8),
                                      child: Row(
                                        children: [
                                          if (imgUrl != null)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: CachedNetworkImage(
                                                imageUrl: imgUrl,
                                                width: compact ? 36 : 44,
                                                height: compact ? 36 : 44,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) => Container(width: compact ? 36 : 44, height: compact ? 36 : 44, color: kMid),
                                                errorWidget: (_, __, ___) => Container(width: compact ? 36 : 44, height: compact ? 36 : 44, color: kMid, child: Icon(Icons.image_not_supported, size: compact ? 14 : 16, color: kSub)),
                                              ),
                                            ),
                                          SizedBox(width: compact ? 8 : 10),
                                          Expanded(
                                            child: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white, fontSize: compact ? 12 : 13)),
                                          ),
                                          Text('x${item.quantity}', style: TextStyle(color: kSub, fontSize: compact ? 11 : 12)),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return kSub;
    }
  }
}
