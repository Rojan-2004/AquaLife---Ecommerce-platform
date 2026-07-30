import 'package:flutter_test/flutter_test.dart';
import 'package:aqua_life/features/cart/domain/entities/cart_item_model.dart';

void main() {
  group('CartItemModel Tests', () {
    test('should create CartItemModel from JSON with product object', () {
      final json = {
        'id': 'item1',
        'productId': 'prod1',
        'quantity': 2,
        'product': {
          'id': 'prod1',
          'name': 'Test Product',
          'price': 100,
          'stock': 10,
          'category': 'Fish',
          'images': ['img1.jpg'],
        },
      };

      final item = CartItemModel.fromJson(json);

      expect(item.id, 'item1');
      expect(item.productId, 'prod1');
      expect(item.name, 'Test Product');
      expect(item.price, 100);
      expect(item.quantity, 2);
      expect(item.stock, 10);
      expect(item.category, 'Fish');
      expect(item.image, 'img1.jpg');
    });

    test('should handle missing product in JSON gracefully', () {
      final json = {
        'id': 'item1',
        'productId': 'prod1',
        'quantity': 1,
      };

      final item = CartItemModel.fromJson(json);

      expect(item.id, 'item1');
      expect(item.name, 'Unknown Product');
      expect(item.price, 0);
      expect(item.quantity, 1);
      expect(item.stock, 0);
      expect(item.category, isNull);
      expect(item.image, isNull);
    });

    test('should convert to JSON correctly', () {
      final item = CartItemModel(
        id: 'item1',
        productId: 'prod1',
        name: 'Test Product',
        price: 100,
        quantity: 2,
        stock: 10,
        category: 'Fish',
        image: 'img1.jpg',
      );

      final json = item.toJson();

      expect(json['id'], 'item1');
      expect(json['productId'], 'prod1');
      expect(json['name'], 'Test Product');
      expect(json['price'], 100);
      expect(json['quantity'], 2);
      expect(json['stock'], 10);
      expect(json['category'], 'Fish');
      expect(json['image'], 'img1.jpg');
    });

test('copyWith without arguments should return identical copy', () {
      final item = CartItemModel(
        id: 'item1',
        productId: 'prod1',
        name: 'Test Product',
        price: 100,
        quantity: 2,
        stock: 10,
      );

      final copy = item.copyWith();

      expect(copy.id, item.id);
      expect(copy.quantity, item.quantity);
      expect(copy.price, item.price);
      expect(copy.name, item.name);
    });
  });
}
