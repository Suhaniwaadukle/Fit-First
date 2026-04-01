import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:orka_sports/core/services/secure_storage_service.dart';
import 'package:orka_sports/data/models/auth/login_request.dart';
import 'package:orka_sports/data/models/auth/register_request.dart';
import 'package:orka_sports/data/repositories/auth_repository.dart';
import 'package:orka_sports/data/repositories/bmi_repository.dart';
import 'package:orka_sports/data/repositories/profile_repository.dart';
import 'package:orka_sports/data/models/auth/google_register_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  AuthBloc({required this.authRepository, required this.profileRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<GoogleRegisterRequested>(_onGoogleRegisterRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await authRepository.login(
        LoginRequest(email: event.email, password: event.password),
      );

      log('Login response received: success=${response.success}');

      if (response.success) {
        final token = response.token;
        final userId = response.userId;
        
        // ✅ Clean the token (remove "Bearer " if present)
        final cleanToken = token.toString().replaceFirst('Bearer ', '').trim();
        
        // ✅ Save token to SharedPreferences
        final sharedPreferences = await SharedPreferences.getInstance();
        await sharedPreferences.setString('access_token', cleanToken);
        await sharedPreferences.setString('userId', userId!);
              // ✅ NEW: Save refresh token if available
      if (response.refreshToken != null) {
        await sharedPreferences.setString('refresh_token', response.refreshToken!);
        log('✅ Refresh token saved to SharedPreferences');
      }
        
        // Keep existing SecureStorage save for backward compatibility
        await SecureStorageService().write(key: 'auth_token', value: token.toString());
        
        debugPrint('✅ Token saved to SharedPreferences: ${cleanToken.substring(0, 10)}...');
        
        emit(Authenticated());
      } else {
        emit(AuthError(response.message));
      }
    } catch (e, stackTrace) {
      debugPrint('Login error: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthRegistrationLoading());
    log('outside of try in the beginning');
    try {
      log('inside of try');
      final bool response = await authRepository.register(event.request);
      if (response == true) {
        log('User data saved, emitting Authenticated state');
        emit(AuthRegistrationSuccess());
        log('success');
      } else {
        log('failed to fetch');
        emit(AuthRegistrationError(error: 'authentication failed from the registration'));
      }
    } catch (e) {
      log('checking catch$e');
      emit(AuthRegistrationError(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint('Logout requested');
    try {
      // ✅ Clear token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('userId');
      await prefs.remove('refresh_token'); // ✅ Add this
      await prefs.remove('user_profile');
      await prefs.remove('profile_image_path');
      
      // Clear SecureStorage
      await SecureStorageService().delete(key: 'auth_token');
      await SecureStorageService().delete(key: 'google_user_email');
      await SecureStorageService().delete(key: 'google_user_id');
      
      await BmiRepository().clearBmiData();
      emit(Unauthenticated());
    } catch (e) {
      debugPrint('Error during logout: $e');
      emit(AuthError('Error during logout: $e'));
    }
  }

Future<void> _onAuthCheckRequested(
  AuthCheckRequested event,
  Emitter<AuthState> emit,
) async {
  try {
    // ✅ Check tokens from SharedPreferences (consistent with ProfileRepository)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');
    final userId = prefs.getString('userId');
    
    log('🔍 Auth check - Access Token: ${token?.substring(0, 20)}...');
    log('🔍 Auth check - Refresh Token: ${refreshToken?.substring(0, 20)}...');
    log('🔍 Auth check - User ID: $userId');

    if (token != null && token.isNotEmpty && 
        refreshToken != null && refreshToken.isNotEmpty && 
        userId != null && userId.isNotEmpty) {
      log('✅ Valid tokens found in SharedPreferences');
      emit(Authenticated());
    } else {
      log('❌ Missing or invalid tokens in SharedPreferences');
      emit(Unauthenticated());
    }
  } catch (e) {
    debugPrint("Auth check error: $e");
    emit(Unauthenticated());
  }
}


  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(ForgotPasswordLoading());

    try {
      final response = await authRepository.forgotPassword(event.email);
      log('Sending email: "${event.email}"');
      if (response.success) {
        debugPrint('Forgot password request successful');
        emit(ForgotPasswordSuccess());
      } else {
        debugPrint('Forgot password request failed: ${response.message}');
        emit(ForgotPasswordError(error: response.message));
      }
    } catch (e, stackTrace) {
      debugPrint('Forgot password error: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(ForgotPasswordError(error: e.toString()));
    }
  }

  // ✅ Google Register Logic (Updated to also save to SharedPreferences)
Future<void> _onGoogleRegisterRequested(
  GoogleRegisterRequested event,
  Emitter<AuthState> emit,
) async {
  emit(GoogleRegisterLoading());

  try {
    final GoogleRegisterResponse response = await authRepository.googleRegister(
      name: event.name,
      email: event.email,
      googleId: event.googleId,
      verifiedEmail: event.verifiedEmail,
      picture: event.picture,
    );

    debugPrint('🔍 Google Response Status: ${response.status}');
    debugPrint('🔍 Google Response Root Token: "${response.token}"');  // ✅ Root level token
    debugPrint('🔍 Google Response Data Token: "${response.data?.token}"');  // Data level token
    debugPrint('🔍 Google Response InsertLastId: ${response.insertLastId}');

    if (response.status == "success" && response.data != null) {
      // ✅ Use ROOT level token (same structure as regular login)
      final googleToken = response.token ?? '';  // ✅ Changed to response.token
      
      debugPrint('🔍 Using Root Level Token: "$googleToken"');
      if (googleToken.isEmpty) {
        debugPrint('❌ ERROR: Google token is EMPTY!');
        emit(GoogleRegisterError(error: 'No token received from Google registration'));
        return;
      }
      
      // Clean the token (remove Bearer prefix)
      final cleanGoogleToken = googleToken.replaceFirst('Bearer ', '').trim();
      debugPrint('🔍 Cleaned Google Token: "$cleanGoogleToken"');
      
      final sharedPreferences = await SharedPreferences.getInstance();
      
      // Save Google JWT token to SharedPreferences
      await sharedPreferences.setString('access_token', cleanGoogleToken);
      await sharedPreferences.setString('userId', response.insertLastId.toString());

            // ✅ NEW: Save Google refresh token if available
      if (response.refreshToken != null) {
        await sharedPreferences.setString('refresh_token', response.refreshToken!);
        log('✅ Google refresh token saved to SharedPreferences');
      }
      
      debugPrint('✅ Google JWT token saved: ${cleanGoogleToken.substring(0, 10)}...');
      debugPrint('✅ Google userId saved: ${response.insertLastId}');
      
      // Save to SecureStorage for backward compatibility
      await SecureStorageService().write(key: 'google_user_email', value: response.data?.email ?? '');
      await SecureStorageService().write(key: 'google_user_id', value: response.data?.googleId ?? '');
      await SecureStorageService().write(key: 'auth_token', value: googleToken);

      emit(GoogleRegisterSuccess());
    } else {
      debugPrint('❌ Google Registration Failed: ${response.message}');
      emit(GoogleRegisterError(error: response.message ?? 'Google registration failed'));
    }
  } catch (e, stackTrace) {
    debugPrint('💥 Google Register Exception: $e');
    debugPrint('Stack Trace: $stackTrace');
    emit(GoogleRegisterError(error: e.toString()));
  }
}



}
