import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/cart/data/cart_repository.dart';
import 'package:aqua_life/features/cart/domain/entities/cart_item_model.dart';
import 'package:aqua_life/features/cart/presentation/state/cart_state.dart';

final cartViewModelProvider = StateNotifierProvider<CartViewModel, CartState>((ref) {
  final repo = ref.read(cartRepositoryProvider);
  return CartViewModel(repo);
});

class CartViewModel extends StateNotifier<CartState> {
  final CartRepository _repo;
  CartViewModel(this._repo) : super(const CartState()) {
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final items = await _repo.fetchCart();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addToCart(String productId, {int quantity = 1}) async {
    try {
      final item = await _repo.addToCart(productId, quantity: quantity);
      if (item != null) {
        final existingIndex = state.items.indexWhere((i) => i.productId == productId);
        if (existingIndex >= 0) {
          final updated = List<CartItemModel>.from(state.items);
          updated[existingIndex] = item;
          state = state.copyWith(items: updated);
        } else {
          state = state.copyWith(items: [...state.items, item]);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      final success = await _repo.removeFromCart(cartItemId);
      if (success) {
        state = state.copyWith(
          items: state.items.where((i) => i.id != cartItemId).toList(),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(cartItemId);
      return;
    }
    final index = state.items.indexWhere((i) => i.id == cartItemId);
    if (index >= 0) {
      final item = state.items[index];
      if (quantity > item.stock) {
        state = state.copyWith(error: 'Only ${item.stock} in stock');
        return;
      }
      final updated = List<CartItemModel>.from(state.items);
      updated[index] = item.copyWith(quantity: quantity);
      state = state.copyWith(items: updated);
    }
  }

  Future<void> refresh() async {
    await loadCart();
  }
}
