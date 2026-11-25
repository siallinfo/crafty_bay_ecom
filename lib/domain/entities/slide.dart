class Slide {
  final String id;
  final String photoUrl;
  final String description;
  final Object? product;
  final Object? brand;
  final Object? category;

  const Slide({
    required this.id,
    required this.photoUrl,
    required this.description,
    this.product,
    this.brand,
    this.category,
  });
}
