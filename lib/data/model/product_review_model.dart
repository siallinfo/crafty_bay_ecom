import '../../domain/entities/product_review.dart';

class ProductReviewModel extends ProductReview {
  ProductReviewModel({
    required super.id,
    required super.author,
    required super.avatarUrl,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map<String, dynamic>
        ? json['user'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final firstName = (user['first_name'] ?? '').toString().trim();
    final lastName = (user['last_name'] ?? '').toString().trim();
    final ratingValue = json['rating'];

    return ProductReviewModel(
      id: (json['_id'] ?? '').toString(),
      author: [firstName, lastName].where((name) => name.isNotEmpty).join(' '),
      avatarUrl: user['avatar_url']?.toString(),
      rating: ratingValue is num
          ? ratingValue
          : num.tryParse(ratingValue?.toString() ?? '') ?? 0,
      comment: (json['comment'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
