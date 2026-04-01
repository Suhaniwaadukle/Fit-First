import 'package:orka_sports/data/models/auth/user_data.dart';

class AuthResponse {
  final bool success;
  final String message;
  final String? refreshToken;
  final UserData? data;
  final String? token;
  final String? userId;

  AuthResponse({
    required this.success,
    required this.message,
    this.refreshToken, // ✅ Made optional (not required)
    this.data,
    this.token,
    this.userId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // ✅ Debug logging 
    print('🔍 Raw JSON: $json');
    print('🔍 Data object: ${json['data']}');
    
    final bool isSuccess = json['status'] == 'success';
    
    // ✅ Extract the nested 'data' object
    final dataObject = json['data'] as Map<String, dynamic>?;
    
    // ✅ Debug the nested values
    print('🔍 Nested token: ${dataObject?['token']}');
    print('🔍 Nested refresh_token: ${dataObject?['refresh_token']}');
    print('🔍 Nested id: ${dataObject?['id']}');
    
    // Create UserData from the response
    UserData? userData;
    if (isSuccess && dataObject != null) {
      userData = UserData(
        id: dataObject['id']?.toString() ?? '',
        name: dataObject['name'] ?? '',
        email: dataObject['email'] ?? '',
        profileImage: dataObject['profile_image'] ?? '',
        phonecode: dataObject['phonecode'] ?? '',
        mobile: dataObject['mobile'] ?? '',
      );
    }

    return AuthResponse(
      success: isSuccess,
      message: json['message'] ?? '',
      refreshToken: dataObject?['refresh_token'], // ✅ Get from nested data object
      data: userData,
      token: dataObject?['token'], // ✅ Get from nested data object
      userId: dataObject?['id']?.toString(), // ✅ Get from nested data object
    );
  }
}
