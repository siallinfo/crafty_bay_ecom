import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_strings.dart';

/// Stores the login bearer token on the device with `shared_preferences`.
///
/// Call [init] once in `main()` before `runApp`. After that the token can be
/// read synchronously from anywhere, e.g. when building request headers.
class CacheService {
  CacheService._();

  static late SharedPreferences _sharedPreferences;
  static bool _isInitialized = false;

  /// Loads the preferences instance. Must be awaited before any other call.
  static Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  static bool get isInitialized => _isInitialized;

  /// The cached API token, or `null` when the user is logged out.
  static String? get accessToken => _isInitialized
      ? _sharedPreferences.getString(AppStrings.accessTokenCacheKey)
      : null;

  static bool get isLoggedIn => accessToken != null && accessToken!.isNotEmpty;

  /// Saves the bearer token received at login.
  static Future<void> saveAccessToken(String token) {
    if (!_isInitialized) {
      throw StateError(
        'CacheService.init() must be called before saving a token.',
      );
    }
    return _sharedPreferences.setString(AppStrings.accessTokenCacheKey, token);
  }

  /// Removes the token (logout).
  static Future<void> clearAccessToken() {
    if (!_isInitialized) return Future<void>.value();
    return _sharedPreferences.remove(AppStrings.accessTokenCacheKey);
  }
}
