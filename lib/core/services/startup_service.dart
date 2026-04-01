import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_event.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_state.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_bloc.dart';

class StartupService {
  static Future<void> loadAllParallelData(BuildContext context, WidgetRef ref) async {
    print("🚀 Starting parallel data loading...");
    final startTime = DateTime.now();
    
    try {
      // ✅ RUN ALL STARTUP OPERATIONS IN PARALLEL
      await Future.wait([
        _loadProfile(context),
        _loadActivities(context), 
      //  _loadBodyIQData(context, ref),
      ]);
      
      final duration = DateTime.now().difference(startTime);
      print("⚡ All startup data loaded in ${duration.inMilliseconds}ms");
      
    } catch (e) {
      print("❌ Error in parallel loading: $e");
    }
  }
  
  static Future<void> _loadProfile(BuildContext context) async {
    if (context.read<ProfileBloc>().state is! ProfileLoaded) {
      context.read<ProfileBloc>().add(LoadProfile());
      // Wait for profile to load
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
  
  static Future<void> _loadActivities(BuildContext context) async {
    if (context.read<ActivityListBloc>().state is! ActivityListLoaded) {
      context.read<ActivityListBloc>().add(LoadActivityList());
      // Wait for activities to load
      await Future.delayed(Duration(milliseconds: 100));
    }
  }
  

}
