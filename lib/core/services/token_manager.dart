import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';

class TokenManager {
  // ✅ Singleton pattern for global access
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  static const String _tokenKey = 'login_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ✅ Save token from login API
  Future<void> saveToken(String token) async {
    try {
      // Remove 'Bearer ' prefix if present
      final cleanToken = token.replaceFirst('Bearer ', '').trim();
      await _storage.write(key: _tokenKey, value: cleanToken);
      debugPrint('✅ Token saved: ${cleanToken.substring(0, 10)}...');
    } catch (e) {
      debugPrint('❌ Error saving token: $e');
    }
  }

  // ✅ Get raw token
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        debugPrint('✅ Token retrieved: ${token.substring(0, 10)}...');
      } else {
        debugPrint('❌ No token found');
      }
      return token;
    } catch (e) {
      debugPrint('❌ Error getting token: $e');
      return null;
    }
  }

  // ✅ Get Bearer formatted token for API headers
  Future<String?> getBearerToken() async {
    final token = await getToken();
    return token != null ? 'Bearer $token' : null;
  }

  // ✅ Check if token exists
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ✅ Delete token (for logout)
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      debugPrint('✅ Token deleted');
    } catch (e) {
      debugPrint('❌ Error deleting token: $e');
    }
  }

  // ✅ Clear all tokens
  Future<void> clearAllTokens() async {
    try {
      await _storage.deleteAll();
      debugPrint('✅ All tokens cleared');
    } catch (e) {
      debugPrint('❌ Error clearing tokens: $e');
    }
  }
}
