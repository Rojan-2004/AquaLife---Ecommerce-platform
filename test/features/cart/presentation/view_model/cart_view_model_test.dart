import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:aqua_life/features/cart/presentation/state/cart_state.dart';
import 'package:aqua_life/features/cart/domain/entities/cart_item_model.dart';
import 'package:aqua_life/features/cart/data/cart_repository.dart';

class MockCartRepository extends Mock implements CartRepository {}

void main() {
  group('CartViewModel Tests', () {
    late MockCartRepository mockCartRepository;
    late ProviderContainer container;

    Future<ProviderContainer> createContainer(List<CartItemModel> items) async {
      mockCartRepository = MockCartRepository();
      when(() => mockCartRepository.fetchCart()).thenAnswer((_) async => items);

      final c = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockCartRepository),
        ],
      );

      await c.read(cartViewModelProvider.notifier).loadCart();

      return c;
    }

    test('loadCart should update items when repository returns data', () async {
      final items = [
        CartItemModel(
          id: 'item1',
          productId: 'prod1',
          name: 'Product 1',
          price: 100,
          quantity: 2,
          stock: 10,
        ),
      ];

      container = await createContainer(items);

      final state = container.read(cartViewModelProvider);
      expect(state.items.length, 1);
      expect(state.items.first.name, 'Product 1');
      expect(state.isLoading, false);
    });

    test('loadCart should return empty list when repository throws', () async {
      mockCartRepository = MockCartRepository();
      when(() => mockCartRepository.fetchCart()).thenThrow(Exception('Network error'));

      container = ProviderContainer(
        overrides: [
          cartRepositoryProvider.overrideWithValue(mockCartRepository),
        ],
      );

      await container.read(cartViewModelProvider.notifier).loadCart();

      final state = container.read(cartViewModelProvider);
      expect(state.items, isEmpty);
      expect(state.error, contains('Network error'));
    });

    test('addToCart should refresh cart when repository succeeds', () async {
      final items = [
        CartItemModel(
          id: 'item1',
          productId: 'prod1',
          name: 'Product 1',
          price: 100,
          quantity: 1,
          stock: 10,
        ),
      ];

      container = await createContainer(items);
      when(() => mockCartRepository.addToCart('prod1', quantity: 1))
          .thenAnswer((_) async => items.first);
      when(() => mockCartRepository.fetchCart()).thenAnswer((_) async => items);

      await container.read(cartViewModelProvider.notifier).addToCart('prod1');

      final state = container.read(cartViewModelProvider);
      expect(state.items.length, 1);
      verify(() => mockCartRepository.addToCart('prod1', quantity: 1)).called(1);
    });

    test('removeFromCart should remove item when repository succeeds', () async {
      final items = [
        CartItemModel(
          id: 'item1',
          productId: 'prod1',
          name: 'Product 1',
          price: 100,
          quantity: 1,
          stock: 10,
        ),
      ];

      container = await createContainer(items);
      when(() => mockCartRepository.removeFromCart('item1')).thenAnswer((_) async => true);

      await container.read(cartViewModelProvider.notifier).removeFromCart('item1');

      final state = container.read(cartViewModelProvider);
      expect(state.items, isEmpty);
    });

    test('updateQuantity should remove item when quantity is 0 or less', () async {
      final items = [
        CartItemModel(
          id: 'item1',
          productId: 'prod1',
          name: 'Product 1',
          price: 100,
          quantity: 1,
          stock: 10,
        ),
      ];

      container = await createContainer(items);
      when(() => mockCartRepository.removeFromCart('item1')).thenAnswer((_) async => true);

      await container.read(cartViewModelProvider.notifier).updateQuantity('item1', 0);

      final state = container.read(cartViewModelProvider);
      expect(state.items, isEmpty);
      verify(() => mockCartRepository.removeFromCart('item1')).called(1);
    });

    test('updateQuantity should error when quantity exceeds stock', () async {
      final items = [
        CartItemModel(
          id: 'item1',
          productId: 'prod1',
          name: 'Product 1',
          price: 100,
          quantity: 1,
          stock: 5,
        ),
      ];

      container = await createContainer(items);

      await container.read(cartViewModelProvider.notifier).updateQuantity('item1', 10);

      final state = container.read(cartViewModelProvider);
      expect(state.error, contains('Only 5 in stock'));
verifyNever(() => mockCartRepository.updateQuantity('item1', 10));
     });
   });
 }
