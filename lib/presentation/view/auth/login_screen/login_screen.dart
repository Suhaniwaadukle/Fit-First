// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/view/auth/forgot_screen/forgot_password_screen.dart';
import 'package:orka_sports/presentation/view/auth/signup_screen.dart/signup_screen.dart';
import 'package:orka_sports/presentation/view/main_screen/main_screen.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/widgets/custom_textfield.dart';
import 'package:orka_sports/presentation/blocs/auth/auth_bloc.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  Future<void> _handleGoogleRegister() async {
    try {
      setState(() {
        _isGoogleLoading = true;
      });

      final GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        serverClientId: '473802444400-ga78ufnjintglbci4rctg7nvqljnaf1s.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isGoogleLoading = false);
        return;
      }

      final String name = googleUser.displayName ?? '';
      final String email = googleUser.email;
      final String googleId = googleUser.id;
      final String picture = googleUser.photoUrl ?? '';
      const String verifiedEmail = "1";

      context.read<AuthBloc>().add(
            GoogleRegisterRequested(
              name: name,
              email: email,
              googleId: googleId,
              verifiedEmail: verifiedEmail,
              picture: picture,
            ),
          );
    } catch (error) {
      setState(() => _isGoogleLoading = false);
      log('Google Sign-In failed: $error');
      showCustomSnackbar(
        context,
        'Google Sign-In failed. Please try again}',
        isError: true,
      );
      print('Google Login errorRRRRRRRRRRRRR: $error');
    }
  }

  Future<void> _handleAppleRegister() async {
    try {
      setState(() {
        _isAppleLoading = true;
      });

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],

        webAuthenticationOptions: WebAuthenticationOptions(
          clientId: "com.fitfirst.service",
          redirectUri: Uri.parse(
            "https://fitfirst.online/auth/apple/callback",
          ),
        ),
      );

      final String name =
      "${credential.givenName ?? ''} ${credential.familyName ?? ''}".trim();

      final String email = credential.email ?? "";
      final String appleId = credential.userIdentifier ?? "";
      const String verifiedEmail = "1";

      context.read<AuthBloc>().add(
        AppleRegisterRequested(
          name: name,
          email: email,
          appleId: appleId,
          verifiedEmail: verifiedEmail,
        ),
      );

      setState(() {
        _isAppleLoading = false;
      });

    } catch (error) {
      setState(() {
        _isAppleLoading = false;
      });

      print("Apple Login error : $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
            child: BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthError || state is GoogleRegisterError) {
                  setState(() => _isGoogleLoading = false);
                  showCustomSnackbar(
                    context,
                    state is AuthError ? state.message : "Error!",
                    isError: true,
                  );
                } else if (state is Authenticated || state is GoogleRegisterSuccess) {
                  setState(() => _isGoogleLoading = false);
                  CustomSmoothNavigator.pushReplacement(context, const MainScreen());
                  showCustomSnackbar(context, 'Login successful');
                }
              },
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/ff1.png',
                              width: 160,
                              height: 160,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text("Welcome back!", style: theme.textTheme.headlineMedium),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in with your Email and Password to continue",
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 32),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CustomTextfield(
                              controller: _emailController,
                              isPassword: false,
                              hintText: "Email",
                              labelText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withAlpha(20),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CustomTextfield(
                              controller: _passwordController,
                              isPassword: true,
                              hintText: "Password",
                              labelText: 'Password',
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                CustomSmoothNavigator.push(context, const ForgotPasswordScreen());
                              },
                              child: Text(
                                "Forgot Password?",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    disabledBackgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: state is AuthLoading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!.validate()) {
                                            context.read<AuthBloc>().add(
                                                  LoginRequested(
                                                    email: _emailController.text,
                                                    password: _passwordController.text,
                                                  ),
                                                );
                                          }
                                        },
                                  child: state is AuthLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(color: Colors.white),
                                        )
                                      : const Text(
                                          "Continue",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          Row(children: [Expanded(child: Divider(color: Colors.grey, thickness: 1))]),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _isGoogleLoading ? null : _handleGoogleRegister,
                            label: const Text(
                              'Register with Google',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kPrimaryColor,
                              ),
                            ),
                            icon: const Icon(FontAwesomeIcons.google, color: AppColors.kBlack),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kWhite,
                              minimumSize: const Size(double.infinity, 55),
                              side: const BorderSide(color: AppColors.kPrimaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _handleAppleRegister,
                            label: const Text(
                              'Register with Apple',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kPrimaryColor,
                              ),
                            ),
                            icon: const Icon(Icons.apple, color: AppColors.kBlack),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.kWhite,
                              minimumSize: const Size(double.infinity, 55),
                              side: const BorderSide(color: AppColors.kPrimaryColor),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account? ",
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                              ),
                              GestureDetector(
                                onTap: () {
                                  CustomSmoothNavigator.push(context, const SignupScreen());
                                },
                                child: Text(
                                  "Sign Up",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isGoogleLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
