import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_life/features/order/domain/entities/order_model.dart';

void main() {
  group('OrderModel Tests', () {
    test('should create OrderModel from JSON', () {
      final json = {
        'id': 'order1',
        'total': 150,
        'subtotal': 130,
        'deliveryFee': 20,
        'status': 'pending',
        'shippingAddress': {'fullName': 'Test User'},
        'createdAt': '2024-01-01T00:00:00.000Z',
        'items': [
          {
            'productId': 'prod1',
            'name': 'Fish Food',
            'price': 50,
            'quantity': 2,
          }
        ],
      };

      final order = OrderModel.fromJson(json);

      expect(order.id, 'order1');
      expect(order.total, 150);
      expect(order.subtotal, 130);
      expect(order.deliveryFee, 20);
      expect(order.status, 'pending');
      expect(order.shippingAddress['fullName'], 'Test User');
      expect(order.items.length, 1);
      expect(order.items.first.name, 'Fish Food');
expect(order.items.first.price, 50);
     });

     test('should handle empty items list', () {
      final json = <String, dynamic>{
        'id': 'order1',
        'total': 100,
        'subtotal': 100,
        'deliveryFee': 0,
        'status': 'delivered',
        'shippingAddress': <String, dynamic>{},
        'createdAt': '2024-01-01T00:00:00.000Z',
        'items': <Map<String, dynamic>>[],
      };

      final order = OrderModel.fromJson(json);

      expect(order.items, isEmpty);
    });

    test('should handle missing createdAt', () {
      final json = <String, dynamic>{
        'id': 'order1',
        'total': 100,
        'subtotal': 100,
        'deliveryFee': 0,
        'status': 'pending',
        'items': <Map<String, dynamic>>[],
      };

      final order = OrderModel.fromJson(json);

      expect(order.createdAt, isNotNull);
    });
  });

  group('OrderItemModel Tests', () {
    test('should create OrderItemModel from JSON', () {
      final json = {
        'productId': 'prod1',
        'name': 'Test Product',
        'price': 100,
        'quantity': 2,
        'image': 'image.jpg',
      };

      final item = OrderItemModel.fromJson(json);

      expect(item.productId, 'prod1');
      expect(item.name, 'Test Product');
      expect(item.price, 100);
      expect(item.quantity, 2);
      expect(item.image, 'image.jpg');
    });

test('should use default values when fields are null', () {
      final json = <String, dynamic>{};

      final item = OrderItemModel.fromJson(json);

      expect(item.productId, isNull);
      expect(item.name, 'Unknown Product');
      expect(item.price, 0);
      expect(item.quantity, 1);
      expect(item.image, isNull);
    });
  });
}
