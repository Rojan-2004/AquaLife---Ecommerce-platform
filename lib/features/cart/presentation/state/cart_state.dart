import 'package:aqua_life/features/cart/domain/entities/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return CartState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isEmpty => items.isEmpty;
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);
  int get subtotal => items.fold<int>(0, (sum, item) => sum + (item.price * item.quantity));
  int get shipping => subtotal > 5000 ? 0 : 149;
  int get total => subtotal + shipping;
}
