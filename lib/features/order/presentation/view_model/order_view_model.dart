import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/order/data/order_repository.dart';
import 'package:aqua_life/features/order/domain/entities/order_model.dart';
import 'package:aqua_life/features/order/presentation/state/order_state.dart';

final orderViewModelProvider = StateNotifierProvider<OrderViewModel, OrderState>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  return OrderViewModel(repo);
});

class OrderViewModel extends StateNotifier<OrderState> {
  final OrderRepository _repo;
  OrderViewModel(this._repo) : super(const OrderState());

  Future<void> loadOrders() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final orders = await _repo.fetchOrders();
      state = state.copyWith(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<String?> placeOrder(Map<String, dynamic> shippingAddress) async {
    try {
      final orderId = await _repo.placeOrder(shippingAddress);
      if (orderId != null) {
        await loadOrders();
      }
      return orderId;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }
}
