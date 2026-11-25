class ProductReview {
  final String id;
  final String author;
  final String? avatarUrl;
  final num rating;
  final String comment;
  final DateTime? createdAt;

  ProductReview({
    required this.id,
    required this.author,
    required this.avatarUrl,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
