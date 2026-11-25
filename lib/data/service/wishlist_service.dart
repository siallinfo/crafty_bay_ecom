import 'dart:convert';

import '../../core/end_points.dart';
import '../../domain/entities/wishlist_item.dart';
import '../model/wishlist_item_model.dart';
import 'network/auth_headers.dart';
import 'network/network_caller.dart';

class WishlistService {
  WishlistService({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  Future<List<WishlistItem>> getWishlist() async {
    final response = await _networkCaller.get(
      Uri.parse(EndPoints.wishlist),
      headers: AuthHeaders.build(),
    );
    if (response.isSuccess != true) throw Exception(response.errorMessage);
    final decoded = jsonDecode(response.body!);
    final data = decoded is Map ? decoded['data'] : null;
    final results = data is List
        ? data
        : data is Map
        ? data['results'] ?? data['items'] ?? data['wishlist']
        : null;
    if (results is! List) {
      throw const FormatException('Expected a results list for wishlist.');
    }
    return results
        .whereType<Map<String, dynamic>>()
        .map(WishlistItemModel.tryFromJson)
        .whereType<WishlistItem>()
        .toList();
  }

  Future<void> add(String productId) async {
    final response = await _networkCaller.post(
      Uri.parse(EndPoints.wishlist),
      headers: AuthHeaders.build(),
      body: {'product': productId},
    );
    if (response.isSuccess != true) throw Exception(response.errorMessage);
  }

  Future<void> remove(String wishlistItemId) async {
    final response = await _networkCaller.delete(
      Uri.parse(EndPoints.wishlistItem(wishlistItemId)),
      headers: AuthHeaders.build(),
    );
    if (response.isSuccess != true) throw Exception(response.errorMessage);
  }
}
