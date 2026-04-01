// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/config/service_locator.dart';
import 'package:orka_sports/presentation/view/home/data/repositories/home_repo_impl.dart';
import 'package:orka_sports/presentation/view/home/domain/entities/home_entity.dart';
import 'package:orka_sports/presentation/view/home/domain/repositories/home_repo.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends StateNotifier<HomeEntity> {
  HomeController() : super(HomeEntity.initial());

  final HomeRepo _homeRepo = HomeRepoImpl();
  final SharedPreferences prefs = GetItService.getIt<SharedPreferences>();

  Future<void> getAllUsersHome(BuildContext context) async {
    try {
      state = state.copyWith(isAllUsersLoading: true);
      final result = await _homeRepo.getAllUsersRepo();
      state = state.copyWith(getAllUsersList: result);
    } catch (e) {
      log("home users error : ${e.toString()}");
      showCustomSnackbar(context, "Something went wrong. Please try again.");
    } finally {
      state = state.copyWith(isAllUsersLoading: false);
    }
  }

Future<void> getAllPartnersHome(BuildContext context) async {
  try {
    // ✅ CRITICAL DEBUG - Check what's in SharedPreferences
    final userId = prefs.getString("userId");
    final token = prefs.getString("access_token");
    
    debugPrint('=== PARTNERS API DEBUG ===');
    debugPrint('🕐 Current time: ${DateTime.now()}');
    debugPrint('👤 User ID: $userId');
    debugPrint('🔐 Token exists: ${token != null}');
    debugPrint('🔐 Token first 10 chars: ${token?.substring(0, 10)}...');
    debugPrint('=========================');

    if (userId == null || userId.isEmpty) {
      debugPrint('❌ CRITICAL: No user ID found in SharedPreferences!');
      showCustomSnackbar(context, "Session expired. Please login again.");
      return;
    }

    state = state.copyWith(isAllPartnersLoading: true);
    
    debugPrint('🌐 Making API call to getAllPartnersRepo...');
    
    final result = await _homeRepo.getAllPartnersRepo(data: {
      "user_id": userId,
    });
    
    debugPrint('✅ API Response received');
    debugPrint('📊 Partners count: ${result.data?.length ?? 0}');
    debugPrint('📨 API Status: ${result.status}');
    debugPrint('📝 API Message: ${result.message}');
    
    state = state.copyWith(getAllPartnersList: result);
    
  } catch (e) {
    debugPrint('❌ API ERROR: ${e.toString()}');
    debugPrint('❌ Error type: ${e.runtimeType}');
    showCustomSnackbar(context, "Something went wrong. Please try again.");
  } finally {
    state = state.copyWith(isAllPartnersLoading: false);
  }
}

}
