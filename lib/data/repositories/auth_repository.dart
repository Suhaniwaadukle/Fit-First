import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:orka_sports/data/models/auth/auth_response.dart';
import 'package:orka_sports/data/models/auth/google_register_response.dart';
import 'package:orka_sports/data/models/auth/login_request.dart';
import 'package:orka_sports/data/models/auth/register_request.dart';

class AuthRepository {
  final String baseUrl = 'https://fitfirst.online/api';

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/login'), body: request.toJson());
          // ✅ Print full API response in console
    print('=== FULL LOGIN API RESPONSE ===');
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        // ✅ fromJson will handle refreshToken from API response
        final authResponse = AuthResponse.fromJson(responseData);

        debugPrint('Parsed Auth Response: success=${authResponse.success}, message=${authResponse.message}');
        debugPrint('✅ Refresh Token: ${authResponse.refreshToken != null ? "Present" : "Not Present"}');
        
        if (authResponse.data != null) {
          log('User Data: ${authResponse.data!.toJson()}');
        }
        return authResponse;
      } else {
        // ✅ Provide refreshToken parameter for failed login
        return AuthResponse(
          success: false, 
          message: 'Login failed : ${response.statusCode}',
          refreshToken: null, // ✅ No refresh token for failed login
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Login Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      // ✅ Provide refreshToken parameter for error case
      return AuthResponse(
        success: false, 
        message: 'An error occurred: $e',
        refreshToken: null, // ✅ No refresh token for error case
      );
    }
  }

  Future<bool> register(RegisterRequest request) async {
    try {
      log('register entry');
      final response = await http.post(Uri.parse('$baseUrl/register'), body: request.toJson());
      log('response $response');
      final responseData = json.decode(response.body);
      log('responseData : $responseData');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        log('registration failed');
        return false;
      }
    } catch (e) {
      log('Registration catch error: $e');
      return false;
    }
  }

  Future<AuthResponse> forgotPassword(String email) async {
    try {
      debugPrint('Forgot Password Request for email: $email');

      final response = await http.post(Uri.parse('$baseUrl/forgot_password'), body: {'email': email});

      log(response.statusCode.toString());
      log(response.body);
      debugPrint('Forgot Password Response Status: ${response.statusCode}');
      debugPrint('Forgot Password Response Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ fromJson will handle refreshToken (likely null for forgot password)
        return AuthResponse.fromJson(responseData);
      } else {
        // ✅ Provide refreshToken parameter for failed forgot password
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Forgot password failed: ${response.statusCode}',
          refreshToken: null, // ✅ No refresh token for forgot password failure
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Forgot Password Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      // ✅ Provide refreshToken parameter for error case
      return AuthResponse(
        success: false, 
        message: 'An error occurred while processing your request: $e',
        refreshToken: null, // ✅ No refresh token for error case
      );
    }
  }

  // Google register function
  Future<GoogleRegisterResponse> googleRegister({
    required String name,
    required String email,
    required String googleId,
    required String verifiedEmail,
    required String picture,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/socialregister');

      final response = await http.post(
        url,
        body: {
          'name': name,
          'email': email,
          'google_id': googleId,
          'verified_email': verifiedEmail,
          'picture': picture,
        },
      );

      log('Google Register Status Code: ${response.statusCode}');
      log('Google Register Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final googleResponse = googleRegisterResponseFromJson(response.body);
        debugPrint('✅ Google Refresh Token: ${googleResponse.refreshToken != null ? "Present" : "Not Present"}');
        return googleResponse;
      } else {
        final decoded = json.decode(response.body);
        return GoogleRegisterResponse(
          status: 'error',
          message: decoded['message'] ?? 'Google Register failed: ${response.statusCode}',
          // ✅ Make sure GoogleRegisterResponse can handle null refreshToken
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Google Register Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      return GoogleRegisterResponse(
        status: 'error',
        message: 'An exception occurred: $e',
        // ✅ Make sure GoogleRegisterResponse can handle null refreshToken
      );
    }
  }
}
