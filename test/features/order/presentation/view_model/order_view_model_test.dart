import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aqua_life/features/order/presentation/view_model/order_view_model.dart';
import 'package:aqua_life/features/order/presentation/state/order_state.dart';
import 'package:aqua_life/features/order/data/order_repository.dart';
import 'package:aqua_life/features/order/domain/entities/order_model.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  group('OrderViewModel Tests', () {
    late MockOrderRepository mockOrderRepository;
    late ProviderContainer container;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      container = ProviderContainer(
        overrides: [
          orderRepositoryProvider.overrideWithValue(mockOrderRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have empty orders and not loading', () async {
      final state = container.read(orderViewModelProvider);

      expect(state.orders, isEmpty);
      expect(state.isLoading, false);
      expect(state.error, isNull);
    });

    test('loadOrders should populate orders when repository succeeds', () async {
      final orders = [
        OrderModel(
          id: 'order1',
          total: 100,
          subtotal: 90,
          deliveryFee: 10,
          status: 'pending',
          shippingAddress: {'fullName': 'Test'},
          createdAt: DateTime.now(),
          items: [],
        ),
        OrderModel(
          id: 'order2',
          total: 200,
          subtotal: 180,
          deliveryFee: 20,
          status: 'delivered',
          shippingAddress: {'fullName': 'Test'},
          createdAt: DateTime.now(),
          items: [],
        ),
      ];

      when(() => mockOrderRepository.fetchOrders()).thenAnswer((_) async => orders);

      await container.read(orderViewModelProvider.notifier).loadOrders();

      final state = container.read(orderViewModelProvider);
      expect(state.isLoading, false);
      expect(state.orders.length, 2);
      expect(state.error, isNull);

      verify(() => mockOrderRepository.fetchOrders()).called(1);
    });

    test('loadOrders should emit error state when repository throws', () async {
      when(() => mockOrderRepository.fetchOrders()).thenThrow(Exception('Network error'));

      await container.read(orderViewModelProvider.notifier).loadOrders();

      final state = container.read(orderViewModelProvider);
      expect(state.isLoading, false);
      expect(state.orders, isEmpty);
      expect(state.error, contains('Network error'));
    });

test('placeOrder should return null when repository fails', () async {
      when(() => mockOrderRepository.placeOrder(any())).thenThrow(Exception('Failed'));

      final result = await container
          .read(orderViewModelProvider.notifier)
          .placeOrder({'fullName': 'Test User'});

      expect(result, isNull);

      final state = container.read(orderViewModelProvider);
      expect(state.error, contains('Failed'));
    });
  });
}
