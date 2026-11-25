class CartItem {
  final String id;
  final String productId;
  final String title;
  final String photo;
  final num price;
  final int quantity;
  final String color;
  final String size;

  const CartItem({
    required this.id,
    required this.productId,
    required this.title,
    required this.photo,
    required this.price,
    required this.quantity,
    required this.color,
    required this.size,
  });
}
