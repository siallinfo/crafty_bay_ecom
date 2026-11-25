import 'dart:convert';

import '../../core/end_points.dart';
import '../../domain/entities/product_review.dart';
import '../model/product_review_model.dart';
import 'network/auth_headers.dart';
import 'network/network_caller.dart';

class ReviewService {
  ReviewService({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  Future<List<ProductReview>> getReviews(String productId) async {
    final uri = Uri.parse(EndPoints.reviews).replace(
      queryParameters: {'product': productId},
    );
    final response = await _networkCaller.get(uri);
    if (response.isSuccess != true) throw Exception(response.errorMessage);
    final decoded = jsonDecode(response.body!);
    final data = decoded is Map ? decoded['data'] : null;
    final results = data is Map ? data['results'] : null;
    if (results is! List) {
      throw const FormatException('Expected a results list for reviews.');
    }
    return results
        .whereType<Map<String, dynamic>>()
        .map(ProductReviewModel.fromJson)
        .toList();
  }

  Future<void> createReview({
    required String productId,
    required num rating,
    required String comment,
  }) async {
    final response = await _networkCaller.post(
      Uri.parse(EndPoints.createReview),
      headers: AuthHeaders.build(),
      body: {'product': productId, 'rating': rating, 'comment': comment},
    );
    if (response.isSuccess != true) throw Exception(response.errorMessage);
  }
}
