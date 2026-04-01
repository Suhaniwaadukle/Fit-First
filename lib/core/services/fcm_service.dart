import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // ✅ Add this import

class FCMService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? currentFCMToken;
  
  static Future<void> init() async {
    // Request permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted permission');
      
      // ✅ Platform-specific token handling
      if (Platform.isIOS) {
        await _handleiOSToken();
      } else {
        // Android - directly get FCM token
        await _getFCMTokenAndSave();
      }
      
      // Listen to token refresh
      messaging.onTokenRefresh.listen((newToken) async {
        currentFCMToken = newToken;
        await _saveTokenToBackend(newToken);
        await _saveTokenSimple(newToken);
      });
      
      // Message handling remains the same
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Foreground notification: ${message.notification?.title}");
        if (message.data['type'] == 'meal') {
          print('🍽️ Meal reminder: ${message.data['mealName']}');
        }
      });
      
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("Notification tapped: ${message.data}");
        if (message.data['type'] == 'meal') {
          print('🍽️ User wants to log: ${message.data['mealName']}');
        }
      });
    } else {
      print('❌ User declined or has not accepted permission');
    }
  }
  
  // ✅ New method specifically for iOS token handling
  static Future<void> _handleiOSToken() async {
    print('🍎 Handling iOS APNS token...');
    
    // Try to get APNS token with retries
    String? apnsToken;
    int retries = 0;
    const maxRetries = 5;
    
    while (apnsToken == null && retries < maxRetries) {
      try {
        apnsToken = await messaging.getAPNSToken();
        if (apnsToken != null) {
          print('✅ APNS Token obtained: ${apnsToken.substring(0, 20)}...');
          break;
        }
      } catch (e) {
        print('⚠️ Error getting APNS token (attempt ${retries + 1}): $e');
      }
      
      retries++;
      if (apnsToken == null) {
        print('⏳ APNS token not ready, waiting ${retries * 2} seconds...');
        await Future.delayed(Duration(seconds: retries * 2));
      }
    }
    
    if (apnsToken != null) {
      // APNS token is available, now get FCM token
      await _getFCMTokenAndSave();
    } else {
      print('❌ Could not obtain APNS token after $maxRetries attempts');
      print('ℹ️  This might be normal in iOS Simulator - try physical device');
    }
  }

  // ✅ Helper method to get FCM token and save
  static Future<void> _getFCMTokenAndSave() async {
    try {
      print('🔑 Getting FCM token...');
      String? token = await messaging.getToken();
      currentFCMToken = token;
      print("✅ FCM Token: $token");
      
      if (token != null) {
        await _saveTokenToBackend(token);
        await _saveTokenSimple(token);
      }
    } catch (e) {
      print("❌ Error getting FCM token: $e");
    }
  }
  
  // Existing method for /updateNotificationPreference (with preferences)
  static Future<void> _saveTokenToBackend(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    
    if (userId != null) {
      try {
        final response = await http.post(
          Uri.parse('https://fitfirst.online/Api/updateNotificationPreference'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': int.parse(userId),
            'fcm_token': token,
            'notifications_enabled': 1,
          }),
        );
        
        if (response.statusCode == 200) {
          print("✅ FCM token with preferences saved successfully: ${response.body}");
        } else {
          print("❌ Error saving FCM token with preferences: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ Error saving FCM token with preferences: $e");
      }
    }
  }
  
  // New method for simple /saveToken endpoint
  static Future<void> _saveTokenSimple(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    
    if (userId != null) {
      try {
        final response = await http.post(
          Uri.parse('https://fitfirst.online/Api/saveToken'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': userId,
            'fcm_token': token,
          }),
        );
        
        if (response.statusCode == 200) {
          print("✅ FCM token saved to simple endpoint successfully");
        } else {
          print("❌ Error saving FCM token to simple endpoint: ${response.statusCode}");
        }
      } catch (e) {
        print("❌ Error saving FCM token to simple endpoint: $e");
      }
    }
  }
  
  // Existing method for updating notification preferences
  static Future<bool> updateNotificationPreference(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("userId");
    
    if (userId != null && currentFCMToken != null) {
      try {
        final response = await http.post(
          Uri.parse('https://fitfirst.online/Api/updateNotificationPreference'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'user_id': int.parse(userId),
            'fcm_token': currentFCMToken!,
            'notifications_enabled': enabled ? 1 : 0,
          }),
        );
        
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print("✅ Notification preference updated: ${responseData['status']}");
          return responseData['status'] == 'success';
        } else {
          print("❌ Error updating notification preference: ${response.statusCode}");
          return false;
        }
      } catch (e) {
        print("❌ Error updating notification preference: $e");
        return false;
      }
    }
    return false;
  }

  static Future<String?> getCurrentToken() async {
    return currentFCMToken ?? await messaging.getToken();
  }
}
