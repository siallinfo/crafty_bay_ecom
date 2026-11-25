import 'dart:convert';

import '../../core/end_points.dart';
import 'cache/cache_service.dart';
import 'network/auth_headers.dart';
import 'network/network_caller.dart';

class AuthService {
  AuthService({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  final NetworkCaller _networkCaller;

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await _networkCaller.post(
      Uri.parse(EndPoints.login),
      body: {'email': email, 'password': password},
    );
    final payload = _decodeSuccess(
      response.isSuccess,
      response.body,
      response.errorMessage,
    );
    await _saveTokenIfPresent(payload, required: true);
  }

  Future<void> signup(Map<String, dynamic> details) async {
    final response = await _networkCaller.post(
      Uri.parse(EndPoints.signup),
      body: details,
    );
    _decodeSuccess(response.isSuccess, response.body, response.errorMessage);
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    final response = await _networkCaller.post(
      Uri.parse(EndPoints.verifyOtp),
      body: {'email': email, 'otp': otp},
    );
    final payload = _decodeSuccess(
      response.isSuccess,
      response.body,
      response.errorMessage,
    );
    await _saveTokenIfPresent(payload, required: true);
  }

  Future<void> resendOtp(String email) async {
    final response = await _networkCaller.post(
      Uri.parse(EndPoints.resendOtp),
      body: {'email': email},
    );
    _decodeSuccess(response.isSuccess, response.body, response.errorMessage);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _networkCaller.get(
      Uri.parse(EndPoints.profile),
      headers: AuthHeaders.build(),
    );
    return _decodeSuccess(
      response.isSuccess,
      response.body,
      response.errorMessage,
    );
  }

  Future<void> updateProfile(Map<String, dynamic> details) async {
    final response = await _networkCaller.patch(
      Uri.parse(EndPoints.profile),
      headers: AuthHeaders.build(),
      body: details,
    );
    _decodeSuccess(
      response.isSuccess,
      response.body,
      response.errorMessage,
    );
  }

  static Future<void> _saveTokenIfPresent(
    Map<String, dynamic> payload, {
    bool required = false,
  }) async {
    final user = payload['user'];
    final token =
        payload['token'] ??
        payload['access_token'] ??
        (user is Map<String, dynamic> ? user['token'] : null);
    if (token is String && token.isNotEmpty) {
      await CacheService.saveAccessToken(token);
    } else if (required) {
      throw const FormatException(
        'Login response did not contain an access token.',
      );
    }
  }

  static Map<String, dynamic> _decodeSuccess(
    bool? isSuccess,
    String? body,
    String? errorMessage,
  ) {
    if (isSuccess != true) throw Exception(errorMessage);
    if (body == null || body.isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected an object in the API response.');
    }
    final data = decoded['data'];
    return data is Map<String, dynamic> ? data : decoded;
  }
}
