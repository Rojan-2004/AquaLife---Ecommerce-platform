import 'package:aqua_life/features/order/domain/entities/order_model.dart';

class OrderState {
  final List<OrderModel> orders;
  final bool isLoading;
  final String? error;
  final bool isFetchingAddress;
  final bool isAuthenticating;
  final Map<String, String?>? address;

  const OrderState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.isFetchingAddress = false,
    this.isAuthenticating = false,
    this.address,
  });

  OrderState copyWith({
    List<OrderModel>? orders,
    bool? isLoading,
    String? error,
    bool? isFetchingAddress,
    bool? isAuthenticating,
    Map<String, String?>? address,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFetchingAddress: isFetchingAddress ?? this.isFetchingAddress,
      isAuthenticating: isAuthenticating ?? this.isAuthenticating,
      address: address ?? this.address,
    );
  }
}
