import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile/profile_model.dart';

class ProfileRepository {
  final String baseUrl = 'https://fitfirst.online/Api';
  
  // ✅ Concurrency protection variables
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  // ✅ Helper method to get access token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    log('🔧 _getToken() retrieved: ${token != null ? "${token.substring(0, 20)}..." : "null"}');
    return token;
  }

  // ✅ Helper method to get refresh token
  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    log('🔧 _getRefreshToken() retrieved: ${refreshToken != null ? "${refreshToken.substring(0, 20)}..." : "null"}');
    return refreshToken;
  }

  // ✅ Helper method to create authenticated headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ✅ User Profile Save to Shared Preferences
  Future<void> saveProfileToPrefs(ProfileData profile) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_profile', jsonEncode(profile.toJson()));
    prefs.setString('profile_image_path', profile.profileImage ?? '');
  }

  // ✅ Get User Profile with Auto Token Refresh
  Future<ProfileResponse> getProfile() async {
    try {
      log('🚀 Starting getProfile()');
      
      // First attempt
      ProfileResponse response = await _attemptGetProfile();
      log('🔧 First attempt result: success=${response.success}');
      
      // Check if token expired
      bool tokenExpired = (!response.success && 
          (response.message.toLowerCase().contains('invalid') || 
           response.message.toLowerCase().contains('expired') ||
           response.message.toLowerCase().contains('token')));
      
      if (tokenExpired) {
        log('🔄 Token expired detected, attempting refresh...');
        
        bool refreshSuccess = await _refreshTokenIfNeeded();
        if (refreshSuccess) {
          log('✅ Token refreshed successfully, retrying API call...');
          
          // Small delay to ensure token propagation
          await Future.delayed(Duration(milliseconds: 500));
          
          log('🔄 Starting retry API call...');
          response = await _attemptGetProfile();
          
          log('🔧 Retry attempt result: success=${response.success}');
          log('🔧 Retry attempt message: ${response.message}');
        } else {
          log('❌ Token refresh failed, clearing session...');
          await _clearUserSession();
          return ProfileResponse(
            success: false,
            message: 'Session expired. Please login again.',
          );
        }
      }
      
      log('🏁 Final response: success=${response.success}');
      return response;
    } catch (e, stackTrace) {
      log('❌ Profile fetch error: $e');
      log('❌ Stack trace: $stackTrace');
      return ProfileResponse(success: false, message: e.toString());
    }
  }

  // ✅ Attempt to get profile (core logic)
  Future<ProfileResponse> _attemptGetProfile() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userId = sharedPreferences.getString('userId');
    final token = await _getToken();

    if (token == null || token.isEmpty) {
      log('❌ No token available for API call');
      return ProfileResponse(
        success: false,
        message: 'No authentication token found.',
      );
    }

    final headers = await _getAuthHeaders();
    
    log('=== SHOW PROFILE API CALL ===');
    log('Profile API URL: $baseUrl/showProfile?userid=$userId');
    log('🔐 Authorization header: Bearer ${token.substring(0, 20)}...');

    final response = await http.get(
      Uri.parse('$baseUrl/showProfile?userid=$userId'),
      headers: headers,
    );

    log('=== SHOW PROFILE API RESPONSE ===');
    log('Profile API Response Status: ${response.statusCode}');
    log('Profile API Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      if (responseData['status'] == 'success' && responseData['data'] != null) {
        await saveProfileToPrefs(ProfileData.fromJson(responseData['data']));
        log('✅ Profile API SUCCESS - Data saved');
        return ProfileResponse.fromJson(responseData);
      } else {
        log('❌ Profile API returned error: ${responseData['message']}');
        return ProfileResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to load profile',
        );
      }
    } else if (response.statusCode == 401) {
      log('❌ Profile API returned 401 Unauthorized');
      return ProfileResponse(
        success: false,
        message: 'Authentication failed. Please login again.',
      );
    } else {
      log('❌ Profile API HTTP error: ${response.statusCode}');
      return ProfileResponse(
        success: false,
        message: 'Failed to load profile: ${response.statusCode}',
      );
    }
  }

  // ✅ Protected Refresh Token Method with Concurrency Control
  Future<bool> _refreshTokenIfNeeded() async {
    // If already refreshing, wait for completion
    if (_isRefreshing) {
      log('🔄 Token refresh already in progress, waiting...');
      return await _refreshCompleter!.future;
    }

    // Start refresh process
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');
      
      if (refreshToken == null || refreshToken.isEmpty) {
        log('❌ No refresh token available');
        _refreshCompleter!.complete(false);
        _isRefreshing = false;
        return false;
      }

      log('🔄 Starting token refresh process...');
      log('🔧 Using refresh token: ${refreshToken.substring(0, 20)}...');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/refreshToken'),
      );
      
      request.fields['refresh_token'] = refreshToken;
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      log('🔄 Refresh Response Status: ${response.statusCode}');
      log('🔄 Refresh Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Check for success status in response
        if (responseData['status'] == 'success' && responseData['token'] != null) {
          final newAccessToken = responseData['token'].toString().replaceFirst('Bearer ', '').trim();
          
          log('🔧 Saving new tokens...');
          
          // Save new access token
          await prefs.setString('access_token', newAccessToken);
          
          // Save new refresh token if provided
          if (responseData['refresh_token'] != null) {
            await prefs.setString('refresh_token', responseData['refresh_token']);
          }
          
          // Verify tokens were saved
          final savedToken = await prefs.getString('access_token');
          log('🔧 New token verification: ${savedToken?.substring(0, 20)}...');
          
          log('✅ Token refresh completed successfully');
          _refreshCompleter!.complete(true);
          _isRefreshing = false;
          return true;
        } else {
          log('❌ Refresh response indicates failure: ${responseData['message']}');
          _refreshCompleter!.complete(false);
          _isRefreshing = false;
          return false;
        }
      } else {
        log('❌ Refresh failed with HTTP status: ${response.statusCode}');
        _refreshCompleter!.complete(false);
        _isRefreshing = false;
        return false;
      }
    } catch (e) {
      log('❌ Refresh error: $e');
      _refreshCompleter!.complete(false);
      _isRefreshing = false;
      return false;
    }
  }

  // ✅ Update User Profile with Auto Token Refresh
  Future<void> updateProfile(ProfileData profile) async {
    try {
      // First attempt
      await _attemptUpdateProfile(profile);
    } catch (e) {
      // Check if it's a token expiration error
      if (e.toString().toLowerCase().contains('authentication failed') ||
          e.toString().toLowerCase().contains('401')) {
        
        log('🔄 Token expired during update, attempting refresh...');
        
        bool refreshSuccess = await _refreshTokenIfNeeded();
        if (refreshSuccess) {
          log('✅ Token refreshed successfully, retrying update...');
          await _attemptUpdateProfile(profile);
        } else {
          log('❌ Token refresh failed during update');
          await _clearUserSession();
          throw Exception('Session expired. Please login again.');
        }
      } else {
        rethrow;
      }
    }
  }

  // ✅ Attempt to update profile (core logic)
  Future<void> _attemptUpdateProfile(ProfileData profile) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final userId = sharedPreferences.getString('userId');
    final token = await _getToken();

    if (userId == null) {
      throw Exception('User ID not found. Please login again.');
    }

    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found. Please login again.');
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/updateProfile'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    log('Update Profile URL: $baseUrl/updateProfile');
    log('Update Profile Headers: ${request.headers}');

    // Add form fields
    request.fields['userid'] = userId;
    request.fields['name'] = profile.name;
    request.fields['email'] = profile.email;
    request.fields['country_code'] = profile.phonecode ?? '+91';
    request.fields['mobile_number'] = profile.mobile ?? '';
    request.fields['gender'] = profile.gender ?? '';
    request.fields['height'] = profile.height ?? '';
    request.fields['weight'] = profile.weight ?? '';
    request.fields['dob'] = profile.dob ?? '';

    // Add profile image if exists
    if (profile.profileImage != null && profile.profileImage!.isNotEmpty) {
      final file = File(profile.profileImage!);
      if (await file.exists()) {
        request.files.add(
          await http.MultipartFile.fromPath('image', profile.profileImage!),
        );
        log('Profile image added to request');
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    log('Update Profile Response: ${response.statusCode}');
    log('Update Profile Message: ${response.body}');

    if (response.statusCode == 401) {
      throw Exception('Authentication failed. Please login again.');
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      final responseData = json.decode(response.body);
      throw Exception(responseData['message'] ?? 'Failed to update profile');
    }

    log('Profile updated successfully');
  }

  // ✅ Clear User Session
  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('userId');
    await prefs.remove('user_profile');
    await prefs.remove('profile_image_path');
    log('✅ User session cleared');
  }

  // ✅ Load User Profile from Shared Preferences
  Future<ProfileData?> loadProfileFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('user_profile');
      if (jsonString != null) {
        final jsonMap = jsonDecode(jsonString);
        return ProfileData.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      log('❌ Error loading profile from preferences: $e');
      return null;
    }
  }

  // ✅ Clear Profile Data (for logout)
  Future<void> clearProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_profile');
      await prefs.remove('profile_image_path');
      log('✅ Profile data cleared from preferences');
    } catch (e) {
      log('❌ Error clearing profile data: $e');
    }
  }
}
