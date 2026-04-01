import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:orka_sports/config/api_constants.dart';
import 'package:orka_sports/config/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiInterceptor {
  final SharedPreferences prefs = GetItService.getIt<SharedPreferences>();
  Dio dio = Dio();

  ApiInterceptor()
      : dio = Dio(BaseOptions(
          baseUrl: ApiConstants.apiBaseUrl,
          headers: {'Content-Type': 'application/json'},
        )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // ✅ Define which endpoints need authentication
          final authRequiredEndpoints = [
            ApiConstants.getAllPartners, // Partners API needs auth
            // Add more protected endpoints here as needed:
            // ApiConstants.getUserProfile,
            // ApiConstants.updateSettings,
          ];
          
          // Check if current request needs authentication
          final needsAuth = authRequiredEndpoints.any((endpoint) => 
            options.path.contains(endpoint) || options.uri.path.contains(endpoint)
          );
          
          if (needsAuth) {
            // ✅ Get token from SharedPreferences
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('access_token');
            
            if (token != null && token.isNotEmpty) {
              // ✅ Add Bearer prefix and set Authorization header
              options.headers['Authorization'] = 'Bearer $token';
              log('🔐 Added Authorization header for ${options.path}: Bearer ${token.substring(0, 10)}...');
            } else {
              log('❌ No access token found in SharedPreferences for ${options.path}');
            }
          } else {
            log('🌐 Public API call (no auth needed): ${options.path}');
          }

          return handler.next(options);
        },
        
        onResponse: (response, handler) {
          log('✅ API Response: ${response.statusCode} - ${response.requestOptions.path}');
          return handler.next(response);
        },
        
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            log('❌ Unauthorized (401) - Token may be expired: ${e.requestOptions.path}');
            // ✅ Optional: Auto-logout or show login screen on 401
          } else if (e.response?.statusCode == 403) {
            log('❌ Forbidden (403) - Access denied: ${e.requestOptions.path}');
          } else if (e.response?.statusCode == 500) {
            log('❌ Server Error (500): ${e.requestOptions.path}');
          } else {
            log('❌ API Error: ${e.response?.statusCode} - ${e.message} - ${e.requestOptions.path}');
          }
          return handler.next(e);
        },
      ),
    );
  }
}
