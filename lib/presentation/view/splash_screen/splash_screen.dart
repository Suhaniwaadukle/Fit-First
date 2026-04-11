import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/core/services/secure_storage_service.dart';
import 'package:orka_sports/presentation/blocs/connectivity/connectivity_event.dart';
import 'package:orka_sports/presentation/blocs/connectivity/connectivity_state.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/presentation/view/auth/login_screen/login_screen.dart';
import 'package:orka_sports/presentation/view/main_screen/main_screen.dart';
import 'package:orka_sports/presentation/blocs/auth/auth_bloc.dart';
import 'package:orka_sports/presentation/blocs/connectivity/connectivity_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {
  bool _hasAttemptedNavigation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ConnectivityBloc>().add(CheckConnectivity());
    }
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      context.read<ProfileBloc>().add(LoadProfile());
      await _checkAuthStatus();
    }
  }

  Future<void> _checkAuthStatus() async {
    log('Checking authentication status...');
    try {
      final token = await SecureStorageService().readToken();
      log('Token status: ${token != null ? 'exists' : 'null'}');

      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested(token));
      }
    } catch (e) {
      log('Error checking auth status: $e');
      if (mounted) _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    if (!_hasAttemptedNavigation && mounted) {
      log('Navigating to login screen');
      _hasAttemptedNavigation = true;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _navigateToMain() {
    try {
      if (!_hasAttemptedNavigation && mounted) {
        log('Navigating to main screen');
        _hasAttemptedNavigation = true;
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainScreen()));
      }
    } catch (e) {
      log("Error in navigation: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              log('Auth state changed: $state');
              debugPrint('AuthBloc emitted state: $state');
              // Navigation now handled inside BlocBuilder to catch pre-emitted state
            },
          ),
          BlocListener<ConnectivityBloc, ConnectivityState>(
            listener: (context, state) {
              if (state.isConnected && !_hasAttemptedNavigation) {
                _checkAuthStatus();
              }
            },
          ),
        ],
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (!_hasAttemptedNavigation) {
              if (state is Authenticated) {
                Future.microtask(() => _navigateToMain());
              } else if (state is Unauthenticated || state is AuthError) {
                Future.microtask(() => _navigateToLogin());
              }
            }

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/ff1.png', width: 160, height: 160),
                  const SizedBox(height: 20),
                  BlocBuilder<ConnectivityBloc, ConnectivityState>(
                    builder: (context, state) {
                      if (!state.isConnected) {
                        return const Column(
                          children: [
                            Icon(Icons.wifi_off, color: Colors.red, size: 24),
                            SizedBox(height: 8),
                            Text('No Internet Connection', style: TextStyle(color: Colors.red, fontSize: 14)),
                            Text('Please check your connection', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        );
                      }
                      return const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading...', style: TextStyle(color: Colors.grey)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
