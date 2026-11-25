import 'dart:convert';

import '../../core/end_points.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_details.dart';
import '../model/product_details_model.dart';
import '../model/product_model.dart';
import 'network/network_caller.dart';

class ProductService {
  ProductService({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  Future<List<Product>> getProducts({
    int count = 20,
    String? brandId,
    String? categoryId,
    String? tag,
  }) async {
    final products = <Product>[];
    var page = 1;
    while (true) {
      final query = <String, String>{
        'count': '$count',
        'page': '$page',
        if (brandId != null && brandId.isNotEmpty) 'brand': brandId,
        if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
        if (tag != null && tag.isNotEmpty) 'tag': tag,
      };
      final uri = Uri.parse(EndPoints.products).replace(queryParameters: query);
      final response = await _networkCaller.get(uri);
      if (response.isSuccess != true) throw Exception(response.errorMessage);

      final decoded = jsonDecode(response.body!);
      final data = decoded is Map ? decoded['data'] : null;
      final results = data is Map ? data['results'] : null;
      if (results is! List) {
        throw const FormatException('Expected a results list for products.');
      }
      products.addAll(
        results.whereType<Map<String, dynamic>>().map(ProductModel.fromJson),
      );

      final next = data is Map ? data['next'] : null;
      if (next == null) return products;
      final nextPage = int.tryParse(next.toString());
      if (nextPage == null || nextPage <= page || nextPage > 1000) {
        throw const FormatException('Invalid product pagination response.');
      }
      page = nextPage;
    }
  }

  Future<ProductDetails> getProductDetails(String id) async {
    final response = await _networkCaller.get(
      Uri.parse(EndPoints.productById(id)),
      headers: {'accept': 'application/json'},
    );
    if (response.isSuccess != true) {
      throw Exception(response.errorMessage);
    }
    final json = jsonDecode(response.body!);
    return ProductDetailsModel.fromJson(json['data']);
  }
}
