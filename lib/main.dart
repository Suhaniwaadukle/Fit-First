import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; 
import 'package:location/location.dart';
import 'package:orka_sports/app/config/themes.dart';
import 'package:orka_sports/app/routes/routes.dart';
import 'package:orka_sports/config/service_locator.dart';
import 'package:orka_sports/core/enum/app_theme.dart';
import 'package:orka_sports/core/services/fcm_service.dart';
import 'package:orka_sports/core/services/secure_storage_service.dart';
import 'package:orka_sports/core/services/shared_prefs.dart';
import 'package:orka_sports/data/repositories/activity_repository.dart';
import 'package:orka_sports/data/repositories/goal_repository_.dart';
import 'package:orka_sports/firebase_options.dart';
import 'package:orka_sports/presentation/blocs/activity/activity_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_event.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/blocs/connectivity/connectivity_bloc.dart';
import 'package:orka_sports/presentation/blocs/goal/goal_bloc.dart';
import 'package:orka_sports/presentation/blocs/location/location_bloc.dart';
import 'package:orka_sports/presentation/blocs/product/product_bloc.dart';
import 'package:orka_sports/presentation/blocs/product_details/product_details_bloc.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/data/repositories/profile_repository.dart';
import 'package:orka_sports/core/services/connectivity_services.dart';
import 'package:orka_sports/presentation/blocs/theme/theme_bloc.dart';
import 'package:orka_sports/presentation/blocs/theme/theme_state.dart';
import 'package:orka_sports/presentation/view/connectivity_checker/connectivity_checker.dart';
import 'package:orka_sports/presentation/view/splash_screen/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'data/repositories/auth_repository.dart';
import 'dart:developer'; // ✅ Add this import

// ✅ Add this token verification function
Future<void> verifyStoredTokensAtStartup() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    final refreshToken = prefs.getString('refresh_token');
    final userId = prefs.getString('userId');
    
    log('🔍 App Startup Token Check:');
    log('🔍 Access Token: ${accessToken != null ? "${accessToken.substring(0, 20)}..." : "null"}');
    log('🔍 Refresh Token: ${refreshToken != null ? "${refreshToken.substring(0, 20)}..." : "null"}');
    log('🔍 User ID: ${userId ?? "null"}');
    
    if (accessToken != null && refreshToken != null && userId != null) {
      log('✅ All tokens found at app startup - user should stay logged in');
    } else {
      log('❌ Missing tokens at app startup - user needs to login');
    }
  } catch (e) {
    log('❌ Error checking stored tokens at startup: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final sharedPrefs = await SharedPreferences.getInstance();
  final prefsService = SharedPreferencesService(sharedPrefs);
  final secureStorage = SecureStorageService();
  GetItService().setupLocator();

  await FCMService.init();
  await verifyStoredTokensAtStartup();

  runApp(
    ProviderScope(
      child: MyApp(
        prefsService: prefsService,
        secureStorage: secureStorage,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository = AuthRepository();
  final ProfileRepository profileRepository = ProfileRepository();
  final SharedPreferencesService prefsService;
  final SecureStorageService secureStorage;
  final ActivityRepository activityRepository = ActivityRepository();

  MyApp({required this.prefsService, required this.secureStorage, super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ConnectivityBloc(connectivityService: ConnectivityService())),
            BlocProvider(create: (context) => ThemeBloc(prefsService)),
            BlocProvider(create: (context) => GoalBloc(goalRepository: GoalRepository())),
            BlocProvider(create: (_) => AuthBloc(authRepository: authRepository, profileRepository: profileRepository)),
            BlocProvider(create: (context) => ActivityBloc(activityRepository: ActivityRepository())),
            BlocProvider(create: (context) => ProfileBloc(profileRepository: ProfileRepository())..add(LoadProfile())),
            BlocProvider(create: (context) => LocationBloc(locationController: Location())),
            BlocProvider(create: (context) => ActivityListBloc(activityRepository: ActivityRepository())..add(LoadActivityList())),
            BlocProvider(create: (context) => ActivitySubCategoryBloc(activityRepository: ActivityRepository())),
            BlocProvider(create: (context) => ProductBloc(activityRepository)),
            BlocProvider(create: (context) => ProductDetailsBloc(repository: activityRepository)),
          ],
          child: BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return MaterialApp(
                title: 'Fit First',
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                themeMode: state.appTheme == AppTheme.dark ? ThemeMode.dark : ThemeMode.light,
                debugShowCheckedModeBanner: false,
                home: const SplashScreen(),
                builder: (context, child) {
                  return ConnectivityChecker(child: child!);
                },
                onGenerateRoute: AppRoutes.generateRoute,
              );
            },
          ),
        );
      },
    );
  }
}
