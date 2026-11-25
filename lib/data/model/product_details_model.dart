import '../../domain/entities/product_details.dart';

class ProductDetailsModel extends ProductDetails {
  ProductDetailsModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.description,
    required super.photos,
    required super.colors,
    required super.sizes,
    required super.regularPrice,
    required super.currentPrice,
    required super.quantity,
  });

  factory ProductDetailsModel.fromJson(Map<String, dynamic> json) {
    final regularPrice = json['regular_price'];
    final currentPrice = json['current_price'];
    final quantity = json['quantity'];
    return ProductDetailsModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      slug: (json['slug'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      photos: _stringList(json['photos']),
      colors: _stringList(json['colors']),
      sizes: _stringList(json['sizes']),
      regularPrice: regularPrice is num
          ? regularPrice
          : num.tryParse(regularPrice?.toString() ?? ''),
      currentPrice: currentPrice is num
          ? currentPrice
          : num.tryParse(currentPrice?.toString() ?? '') ?? 0,
      quantity: quantity is num
          ? quantity.toInt()
          : int.tryParse(quantity?.toString() ?? '') ?? 0,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }
}
