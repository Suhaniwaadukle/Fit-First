// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:orka_sports/core/utils/validator.dart';
import 'package:orka_sports/data/models/auth/register_request.dart';
import 'package:orka_sports/presentation/blocs/auth/auth_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_text_styles.dart';
import 'package:orka_sports/presentation/view/auth/login_screen/login_screen.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/widgets/custom_textfield.dart';
import 'package:orka_sports/presentation/widgets/phone_number_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  String phoneCode = '+91';
  bool isValidEmail = false;
  final TextEditingController otpController = TextEditingController();
  bool isValidOTP = false;
  bool _isGoogleLoading = false;
  bool isOtpVerified = false;
  bool isOtpSent = false;
  bool _isAppleLoading = false;

  Future<void> _handleGoogleRegister() async {
    try {
      setState(() {
        _isGoogleLoading = true;
      });

      // ✅ ADD YOUR WEB CLIENT ID HERE
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: "14316224963-nv5ci7hhkjjkhspve9aa92buldhod05k.apps.googleusercontent.com", // ✅ Replace with your actual Web Client ID
      );

      // ✅ Clear any previous sign-in state
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() => _isGoogleLoading = false);
        print('Google Sign-In cancelled by user');
        return;
      }

      final String name = googleUser.displayName ?? '';
      final String email = googleUser.email;
      final String googleId = googleUser.id;
      final String picture = googleUser.photoUrl ?? '';
      const String verifiedEmail = "1";

      print('=== Google Sign-In Success ===');
      print('Name: $name');
      print('Email: $email');
      print('Google ID: $googleId');

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

      // ✅ Enhanced error handling
      String errorMessage = 'Google Sign-In failed. Please try again.';
      if (error.toString().contains('ApiException')) {
        if (error.toString().contains('DEVELOPER_ERROR')) {
          errorMessage = 'Configuration error. Please contact support.';
        } else if (error.toString().contains('NETWORK_ERROR')) {
          errorMessage = 'Network error. Please check your connection.';
        } else if (error.toString().contains('SIGN_IN_REQUIRED')) {
          errorMessage = 'Please sign in to continue.';
        }
      }

      showCustomSnackbar(
        context,
        errorMessage,
        isError: true,
      );
    }
  }

  Future<void> sendOTP(String email) async {
    try {
      var url = Uri.parse("https://fitfirst.online/user/sendOTP");

      var response = await http.post(
        url,
        body: {
          "email": email,
        },
      );

      if (response.statusCode == 200) {
        print(response.body); // debug

        if (response.body.contains("OTP Sent Successfully")) {
          print("OTP Sent ✅");
        } else {
          print("Error: ${response.body}");
        }
      } else {
        print("Server Error");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> verifyOTP(String email, String otp) async {
    var url = Uri.parse("https://fitfirst.online/user/verifyOTP");

    var response = await http.post(
      url,
      body: {
        "email": email,
        "otp": otp,
      },
    );

    print(response.body);
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
    log("referral : ${referralController.text}");
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthRegistrationSuccess) {
              setState(() => _isGoogleLoading = false); // ✅ Reset Google loading
              showCustomSnackbar(context, 'Registration successful!', isError: false);
              CustomSmoothNavigator.pushReplacement(context, LoginScreen());
            } else if (state is AuthRegistrationError) {
              setState(() => _isGoogleLoading = false); // ✅ Reset Google loading
              showCustomSnackbar(context, state.error, isError: true);
              log('checking auth listener ${state.error}');
            } else if (state is GoogleRegisterSuccess) { // ✅ Handle Google success
              setState(() => _isGoogleLoading = false);
              showCustomSnackbar(context, 'Google registration successful!', isError: false);
              CustomSmoothNavigator.pushReplacement(context, LoginScreen());
            } else if (state is GoogleRegisterError) { // ✅ Handle Google errors
              setState(() => _isGoogleLoading = false);
              showCustomSnackbar(context, state.error, isError: true);
            } else if (state is GoogleRegisterLoading) { // ✅ Handle Google loading
              setState(() => _isGoogleLoading = true);
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 24,
                ),
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
                      Text("Create an account", style: AppTextStyles.headline),
                      SizedBox(height: 8),
                      Text(
                        "Sign up with your Email and Password to continue",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 32),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomTextfield(
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          obscureText: false,
                          hintText: 'Username',
                          labelText: 'Username',
                          isPassword: false,
                          prefixIcon: const Icon(
                            Icons.person,
                            color: Colors.grey,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: CustomTextfield(
                                controller: emailController,
                                isPassword: false,
                                hintText: "Email",
                                labelText: 'Email',
                                prefixIcon: const Icon(
                                  Icons.email,
                                  color: Colors.grey,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: Validator.validateEmail,

                                onChanged: (value) {
                                  final emailRegex =
                                  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

                                  setState(() {
                                    isValidEmail = emailRegex.hasMatch(value);
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 10),

                            ElevatedButton(
                              onPressed: (isValidEmail && !isOtpSent)
                                  ? () {
                                sendOTP(emailController.text);

                                setState(() {
                                  isOtpSent = true;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("OTP Sent Successfully"),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                                  : null,

                              style: ElevatedButton.styleFrom(
                                 backgroundColor: isOtpSent
                                    ? Colors.green
                                    : (isValidEmail
                                    ? const Color(0xFF384F95)
                                    : Colors.grey),

                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),

                              child: Text(
                                isOtpSent ? "Sent" : "Send OTP",
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [

                          Expanded(
                            child: CustomTextfield(
                              controller: otpController,
                              isPassword: false,
                              hintText: "Enter OTP",
                              labelText: 'OTP',
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.grey,
                              ),
                              keyboardType: TextInputType.number,

                              onChanged: (value) {
                                setState(() {
                                  isValidOTP = value.length == 6;
                                });
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                              onPressed: isValidOTP
                                  ? () async {
                                await verifyOTP(
                                  emailController.text,
                                  otpController.text,
                                );

                                setState(() {
                                  isOtpVerified = true;
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("OTP Verified Successfully"),
                                  ),
                                );
                              }
                                : null,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: isOtpVerified
                                  ? Color(0xFF384F95)
                                  : (isValidOTP
                                  ? const Color(0xFF384F95)
                                  : Colors.grey),

                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),

                            child: Text(
                              isOtpVerified ? "Verified" : "Verify",
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      PhoneNumberWidget(
                        controller: phoneController,
                        onPhoneCodeChanged: (code) {
                          setState(() {
                            phoneCode = code;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CustomTextfield(
                          controller: passwordController,
                          isPassword: true,
                          hintText: "Password",
                          labelText: 'Password',
                          obscureText: true,
                          validator: Validator.validatePassword,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: CustomTextfield(
                          controller: confirmPasswordController,
                          isPassword: true,
                          hintText: "Confirm Password",
                          labelText: 'Confirm Password',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16),

                      // Referral Code TextField
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomTextfield(
                          controller: referralController,
                          keyboardType: TextInputType.text,
                          obscureText: false,
                          hintText: 'Referral Code (Optional)',
                          labelText: 'Referral Code',
                          isPassword: false,
                          prefixIcon: const Icon(
                            Icons.code,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),

                      // Continue Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isRegisterLoading = state is AuthRegistrationLoading;
                          
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              onPressed: (isRegisterLoading || _isGoogleLoading)
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        if (passwordController.text != confirmPasswordController.text) {
                                          showCustomSnackbar(
                                            context,
                                            'Passwords do not match',
                                            isError: true,
                                          );
                                          return;
                                        }
                                        
                                        log("referral : ${referralController.text}");
                                        context.read<AuthBloc>().add(
                                              RegisterRequested(
                                                RegisterRequest(
                                                  name: nameController.text.trim(),
                                                  email: emailController.text.trim(),
                                                  phonecode: phoneCode.trim(),
                                                  mobile: phoneController.text.trim(),
                                                  password: passwordController.text.trim(),
                                                  referralCode: referralController.text.trim(),
                                                ),
                                              ),
                                            );
                                      }
                                    },
                              child: isRegisterLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
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
                      const SizedBox(height: 20),

                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isGoogleLoading = _isGoogleLoading || state is GoogleRegisterLoading;
                          final isRegisterLoading = state is AuthRegistrationLoading;

                          return Column(
                            children: [
                              // if (Platform.isAndroid)
                              //   SizedBox(
                              //     width: double.infinity,
                              //     child: ElevatedButton.icon(
                              //       onPressed: (isGoogleLoading || isRegisterLoading)
                              //           ? null
                              //           : _handleGoogleRegister,
                              //       style: ElevatedButton.styleFrom(
                              //         backgroundColor: AppColors.kWhite,
                              //         minimumSize: const Size(double.infinity, 55),
                              //         side: BorderSide(
                              //           color: isGoogleLoading
                              //               ? Colors.grey[400]!
                              //               : AppColors.kPrimaryColor,
                              //         ),
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(16),
                              //         ),
                              //         elevation: 0,
                              //       ),
                              //       icon: isGoogleLoading
                              //           ? SizedBox(
                              //         width: 20,
                              //         height: 20,
                              //         child: CircularProgressIndicator(
                              //           color: AppColors.kPrimaryColor,
                              //           strokeWidth: 2,
                              //         ),
                              //       )
                              //           : const Icon(
                              //         FontAwesomeIcons.google,
                              //         color: AppColors.kBlack,
                              //       ),
                              //       label: Text(
                              //         isGoogleLoading
                              //             ? 'Signing up with Google...'
                              //             : 'Register with Google',
                              //         style: TextStyle(
                              //           fontSize: 16,
                              //           fontWeight: FontWeight.w600,
                              //           color: isGoogleLoading
                              //               ? Colors.grey[600]
                              //               : AppColors.kPrimaryColor,
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // if (Platform.isIOS)
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: (isRegisterLoading) ? null : _handleAppleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.kWhite,
                                      minimumSize: const Size(double.infinity, 55),
                                      side: BorderSide(
                                        color: isRegisterLoading
                                            ? Colors.grey[400]!
                                            : AppColors.kPrimaryColor,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    icon: isRegisterLoading
                                        ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.kPrimaryColor,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : const Icon(
                                      FontAwesomeIcons.apple,
                                      color: AppColors.kBlack,
                                    ),
                                    label: Text(
                                      isRegisterLoading
                                          ? 'Signing up with Apple...'
                                          : 'Register with Apple',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isRegisterLoading
                                            ? Colors.grey[600]
                                            : AppColors.kPrimaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Already have an account? ",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Sign In",
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
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    referralController.dispose();
    super.dispose();
  }
}
