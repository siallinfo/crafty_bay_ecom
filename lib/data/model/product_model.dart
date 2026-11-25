import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.title,
    required super.slug,
    required super.description,
    required super.photos,
    required super.regularPrice,
    required super.currentPrice,
    required super.quantity,
    super.categoryIds,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final categories = json['categories'];
    final categoryIds = categories is List
      ? categories
            .map(
              (category) => category is Map<String, dynamic>
                  ? (category['_id'] ?? '').toString()
                  : category.toString(),
            )
            .where((id) => id.isNotEmpty)
            .toList()
      : <String>[];
    final regularPrice = json['regular_price'];
    final currentPrice = json['current_price'];
    final quantity = json['quantity'];

    return ProductModel(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    slug: (json['slug'] ?? '').toString(),
    description: (json['description'] ?? '').toString(),
    photos: _stringList(json['photos']),
    regularPrice: regularPrice is num
        ? regularPrice
        : num.tryParse(regularPrice?.toString() ?? ''),
    currentPrice: currentPrice is num
        ? currentPrice
        : num.tryParse(currentPrice?.toString() ?? '') ?? 0,
    quantity: quantity is num
        ? quantity.toInt()
        : int.tryParse(quantity?.toString() ?? '') ?? 0,
    categoryIds: categoryIds,
    );
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList();
  }
}
