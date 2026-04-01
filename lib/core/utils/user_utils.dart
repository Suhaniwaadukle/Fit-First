import 'package:shared_preferences/shared_preferences.dart';

class UserUtils {
  /// Get the current logged-in user ID from SharedPreferences
  static Future<String> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('userId') ?? "1545"; // Fallback for testing
    } catch (e) {
      print('Error getting user ID: $e');
      return "1545";
    }
  }
  
  /// Check if user is logged in
  static Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      return userId != null && userId.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
