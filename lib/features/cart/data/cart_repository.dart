import 'package:aqua_life/core/api/api_client.dart';
import 'package:aqua_life/core/api/api_endpoints.dart';
import 'package:aqua_life/features/cart/domain/entities/cart_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartRepository {
  final ApiClient _apiClient;
  CartRepository(this._apiClient);

  Future<List<CartItemModel>> fetchCart() async {
    final res = await _apiClient.get(ApiEndpoints.cart);
    if (res.statusCode == 200 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      final items = data['data'] as List<dynamic>? ?? [];
      return items.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<CartItemModel?> addToCart(String productId, {int quantity = 1}) async {
    final res = await _apiClient.post(
      ApiEndpoints.cart,
      data: {'productId': productId, 'quantity': quantity},
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = res.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        return CartItemModel.fromJson(data['data'] as Map<String, dynamic>);
      }
    }
    return null;
  }

  Future<bool> removeFromCart(String cartItemId) async {
    final res = await _apiClient.delete(
      ApiEndpoints.cart,
      data: {'cartItemId': cartItemId},
    );
    if (res.statusCode == 200 && res.data != null) {
      final data = res.data as Map<String, dynamic>;
      return data['success'] == true;
    }
    return false;
  }

  Future<bool> clearCart() async {
    final items = await fetchCart();
    bool allDeleted = true;
    for (final item in items) {
      final deleted = await removeFromCart(item.id);
      if (!deleted) allDeleted = false;
    }
    return allDeleted;
  }
}

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return CartRepository(apiClient);
});
