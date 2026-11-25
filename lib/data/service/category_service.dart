import 'dart:convert';

import '../../core/end_points.dart';
import '../../domain/entities/category.dart';
import '../model/category_model.dart';
import 'network/network_caller.dart';

class CategoryService {
  CategoryService({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  Future<List<Category>> getCategories({int count = 20}) async {
    final categories = <Category>[];
    var page = 1;
    while (true) {
      final uri = Uri.parse(EndPoints.categories).replace(
        queryParameters: {'count': '$count', 'page': '$page'},
      );
      final response = await _networkCaller.get(uri);
      if (response.isSuccess != true) throw Exception(response.errorMessage);

      final decoded = jsonDecode(response.body!);
      final data = decoded is Map ? decoded['data'] : null;
      final results = data is Map ? data['results'] : null;
      if (results is! List) {
        throw const FormatException('Expected a results list for categories.');
      }
      categories.addAll(
        results
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson),
      );

      final next = data is Map ? data['next'] : null;
      if (next == null) return categories;
      final nextPage = int.tryParse(next.toString());
      if (nextPage == null || nextPage <= page || nextPage > 1000) {
        throw const FormatException('Invalid category pagination response.');
      }
      page = nextPage;
    }
  }
}
