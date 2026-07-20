import 'package:aqua_life/core/api/api_client.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:aqua_life/features/order/domain/entities/order_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderRepository {
  final ApiClient _apiClient;
  OrderRepository(this._apiClient);

  Future<List<OrderModel>> fetchOrders() async {
    final res = await _apiClient.get(ApiEndpoints.orders);
    if (res.statusCode == 200 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      final orders = data['data'] as List<dynamic>? ?? [];
      return orders.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<String?> placeOrder(Map<String, dynamic> shippingAddress) async {
    final res = await _apiClient.post(
      ApiEndpoints.orders,
      data: {'shippingAddress': shippingAddress},
    );
    if (res.statusCode == 201 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['orderId'] as String?;
      }
    }
    return null;
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return OrderRepository(apiClient);
});
