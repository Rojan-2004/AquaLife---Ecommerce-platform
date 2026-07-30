import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/core/services/biometric/biometric_service.dart';
import 'package:aqua_life/features/order/data/order_repository.dart';
import 'package:aqua_life/features/order/presentation/state/order_state.dart';

final orderViewModelProvider = StateNotifierProvider<OrderViewModel, OrderState>((ref) {
  final repo = ref.read(orderRepositoryProvider);
  final biometricService = ref.read(biometricServiceProvider);
  return OrderViewModel(repo, biometricService);
});

class OrderViewModel extends StateNotifier<OrderState> {
  final OrderRepository _repo;
  final BiometricService _biometricService;
  OrderViewModel(this._repo, this._biometricService) : super(const OrderState());

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
    state = state.copyWith(isAuthenticating: true, error: null);

    final isBiometricAvailable = await _biometricService.isBiometricAvailable();

    if (isBiometricAvailable) {
      try {
        final authenticated = await _biometricService.authenticate();
        if (!authenticated) {
          state = state.copyWith(isAuthenticating: false);
          return null;
        }
      } catch (e) {
        state = state.copyWith(isAuthenticating: false, error: e.toString());
        return null;
      }
    }

    try {
      final orderId = await _repo.placeOrder(shippingAddress);
      if (orderId != null) {
        await loadOrders();
      }
      state = state.copyWith(isAuthenticating: false);
      return orderId;
    } catch (e) {
      state = state.copyWith(isAuthenticating: false, error: e.toString());
      return null;
    }
  }

  Future<void> fetchCurrentAddress() async {
    try {
      state = state.copyWith(isFetchingAddress: true, error: null);
      final address = await _repo.getCurrentAddress();
      state = state.copyWith(isFetchingAddress: false, address: address);
    } catch (e) {
      state = state.copyWith(isFetchingAddress: false, error: e.toString());
    }
  }
}
