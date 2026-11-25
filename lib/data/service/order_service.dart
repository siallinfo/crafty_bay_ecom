import 'dart:convert';

import '../../core/end_points.dart';
import '../../domain/entities/order.dart';
import '../model/order_model.dart';
import 'network/auth_headers.dart';
import 'network/network_caller.dart';

class OrderService {
  OrderService({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  Future<List<CustomerOrder>> getOrders() async {
    final response = await _networkCaller.get(
      Uri.parse(EndPoints.orders),
      headers: AuthHeaders.build(),
    );
    if (response.isSuccess != true) throw Exception(response.errorMessage);
    final decoded = jsonDecode(response.body!);
    final data = decoded is Map ? decoded['data'] : null;
    final results = data is List
        ? data
        : data is Map
        ? data['results'] ?? data['orders']
        : null;
    if (results is! List) {
      throw const FormatException('Expected a results list for orders.');
    }
    return results
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }

  Future<Map<String, dynamic>> createOrder({
    required String paymentMethod,
    required String shippingAddress,
  }) async {
    final response = await _networkCaller.post(
      Uri.parse(EndPoints.createOrder),
      headers: AuthHeaders.build(),
      body: {
        'payment_method': paymentMethod,
        'shipping_address': shippingAddress,
      },
    );
    if (response.isSuccess != true) throw Exception(response.errorMessage);
    final decoded = jsonDecode(response.body!);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  Future<CustomerOrder> getOrder(String id) async {
    final response = await _networkCaller.get(
      Uri.parse(EndPoints.order(id)),
      headers: AuthHeaders.build(),
    );
    if (response.isSuccess != true) throw Exception(response.errorMessage);
    final decoded = jsonDecode(response.body!);
    final data = decoded is Map ? decoded['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Expected an order object.');
    }
    return OrderModel.fromJson(data);
  }

  Future<void> cancelOrder(String id) async {
    final response = await _networkCaller.patch(
      Uri.parse(EndPoints.cancelOrder(id)),
      headers: AuthHeaders.build(),
      body: const {},
    );
    if (response.isSuccess != true) throw Exception(response.errorMessage);
  }
}
