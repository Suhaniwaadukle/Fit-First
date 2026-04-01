import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orka_sports/core/services/secure_storage_service.dart';
import 'package:orka_sports/data/repositories/bmi_repository.dart';
import 'package:orka_sports/data/repositories/profile_repository.dart';

class DataClearingService {
  // ✅ Clear ALL user-specific data
  static Future<void> clearAllUserData() async {
    log('🧹 Starting comprehensive user data clearing...');
    
    try {
      await Future.wait([
        _clearSharedPreferencesUserData(),
        //_clearSecureStorage(),
        _clearRepositoryData(),
      ]);
      
      log('✅ All user data cleared successfully');
    } catch (e) {
      log('❌ Error clearing user data: $e');
      rethrow;
    }
  }

  // ✅ Clear user-specific SharedPreferences while preserving app settings
  static Future<void> _clearSharedPreferencesUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // ✅ App settings to preserve (add your app-specific settings)
    final appSettingsToPreserve = {
      'app_theme',
      'language_preference',
      'notification_settings',
      'first_launch',
      // Add other app-level settings you want to keep
    };
    
    // ✅ Get all keys and identify user data keys
    final allKeys = prefs.getKeys();
    final userDataKeys = allKeys.where((key) => !appSettingsToPreserve.contains(key));
    
    // ✅ Clear all user data keys
    for (String key in userDataKeys) {
      await prefs.remove(key);
      log('🗑️ Removed key: $key');
    }
    
    log('✅ SharedPreferences user data cleared');
  }

  // ✅ Clear all secure storage
  // static Future<void> _clearSecureStorage() async {
  //   await SecureStorageService().deleteAll();
  //   log('✅ Secure storage cleared');
  // }

  // ✅ Clear repository-specific data
  static Future<void> _clearRepositoryData() async {
    await Future.wait([
      BmiRepository().clearBmiData(),
      ProfileRepository().clearProfileData(),
      // ✅ Add other repository clearing methods as needed
    ]);
    
    log('✅ Repository data cleared');
  }
}
