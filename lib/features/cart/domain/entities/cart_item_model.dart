class CartItemModel {
  final String id;
  final String productId;
  final String name;
  final String? image;
  final int price;
  int quantity;
  final int stock;
  final String? category;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.name,
    this.image,
    required this.price,
    required this.quantity,
    required this.stock,
    this.category,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    final images = product['images'] as List<dynamic>?;
    final imageUrl = (images != null && images.isNotEmpty) ? images.first as String : null;

    return CartItemModel(
      id: json['id'] as String,
      productId: product['id'] as String? ?? json['product']?.toString() ?? '',
      name: product['name'] as String? ?? 'Unknown Product',
      image: imageUrl,
      price: (product['price'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      stock: (product['stock'] as num?)?.toInt() ?? 0,
      category: product['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
      'stock': stock,
      'category': category,
    };
  }

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      id: id,
      productId: productId,
      name: name,
      image: image,
      price: price,
      quantity: quantity ?? this.quantity,
      stock: stock,
      category: category,
    );
  }
}
