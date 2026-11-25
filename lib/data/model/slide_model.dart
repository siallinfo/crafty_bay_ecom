import '../../domain/entities/slide.dart';

class SlideModel extends Slide {
  SlideModel({
    required super.id,
    required super.photoUrl,
    required super.description,
    super.product,
    super.brand,
    super.category,
  });

  factory SlideModel.fromJson(Map<String, dynamic> json) {
    return SlideModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      photoUrl: (json['photo_url'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      product: json['product'],
      brand: json['brand'],
      category: json['category'],
    );
  }
}
