import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  CartItemModel({
    required super.id,
    required super.productId,
    required super.title,
    required super.photo,
    required super.price,
    required super.quantity,
    required super.color,
    required super.size,
  });

  /// `product` may arrive populated (a map) or as a bare id string, so both
  /// are handled.
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'];
    final productMap = product is Map<String, dynamic> ? product : null;
    final photos = productMap?['photos'];
    final rawPrice = productMap?['current_price'] ?? json['price'] ?? 0;
    final rawQuantity = json['quantity'] ?? 1;

    return CartItemModel(
      id: json['_id'].toString(),
      productId: (productMap?['_id'] ?? product ?? '').toString(),
      title: (productMap?['title'] ?? json['title'] ?? '').toString(),
      photo: photos is List && photos.isNotEmpty ? photos.first.toString() : '',
      price: rawPrice is num
          ? rawPrice
          : num.tryParse(rawPrice.toString()) ?? 0,
      quantity: rawQuantity is num
          ? rawQuantity.toInt()
          : int.tryParse(rawQuantity.toString()) ?? 1,
      color: (json['color'] ?? '').toString(),
      size: (json['size'] ?? '').toString(),
    );
  }
}
