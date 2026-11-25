import 'dart:convert';

import '../../core/end_points.dart';
import '../../domain/entities/slide.dart';
import '../model/slide_model.dart';
import 'network/network_caller.dart';

class SlideService {
  SlideService({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  Future<List<Slide>> getSlides() async {
    final response = await _networkCaller.get(Uri.parse(EndPoints.slides));
    if (response.isSuccess != true) throw Exception(response.errorMessage);
    final decoded = jsonDecode(response.body!);
    final data = decoded is Map ? decoded['data'] : null;
    final results = data is Map ? data['results'] : null;
    if (results is! List) {
      throw const FormatException('Expected a results list for slides.');
    }
    return results
        .whereType<Map<String, dynamic>>()
        .map(SlideModel.fromJson)
        .toList();
  }
}
