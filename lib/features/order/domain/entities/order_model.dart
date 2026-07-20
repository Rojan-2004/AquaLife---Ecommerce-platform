class OrderModel {
  final String id;
  final int total;
  final int subtotal;
  final int deliveryFee;
  final String status;
  final Map<String, dynamic> shippingAddress;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.total,
    required this.subtotal,
    required this.deliveryFee,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] as List<dynamic>? ?? []);
    return OrderModel(
      id: json['id'] as String,
      total: (json['total'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
      deliveryFee: (json['deliveryFee'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      shippingAddress: json['shippingAddress'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      items: items.map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class OrderItemModel {
  final String? productId;
  final String name;
  final int price;
  final int quantity;
  final String? image;

  OrderItemModel({
    this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as String?,
      name: json['name'] as String? ?? 'Unknown Product',
      price: (json['price'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: json['image'] as String?,
    );
  }
}
