import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/app/routes/routes_constants.dart';
import 'package:orka_sports/app/widgets/navigation_widget/navigation_widget.dart';
import 'package:orka_sports/core/services/fcm_service.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/data/models/profile/profile_model.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_text_styles.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/view/body/settings_screen/user_profile/bmi_calculate/bmi_calculate.dart';
import 'package:orka_sports/presentation/view/body/settings_screen/user_profile/my_body/my_body_screen.dart';
import 'package:orka_sports/presentation/view/body/settings_screen/user_profile/personal_profile/personal_profile.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/connections/connections_screen.dart';
import 'package:orka_sports/presentation/view/orders/presentation/pages/orders_screen.dart';
import 'package:orka_sports/presentation/view/terms_privacy/terms_privacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SideProfileView extends StatefulWidget {
  const SideProfileView({super.key});

  @override
  State<SideProfileView> createState() => _SideProfileViewState();
}

class _SideProfileViewState extends State<SideProfileView> {
  bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  double drawerWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return isTablet(context) ? width * 0.42 : width * 0.85;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final width = drawerWidth(context);
    final tablet = isTablet(context);

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        Widget content;

        if (state is ProfileLoading) {
          content = const Center(child: CircularProgressIndicator());
        } else if (state is ProfileError) {
          content = Center(child: Text(state.message));
        } else if (state is ProfileLoaded ||
            state is ProfileUpdating ||
            state is ProfileUpdated) {
          final profile = (state as dynamic).profile;

          content = SafeArea(
            child: Column(
              children: [
                /// HEADER
                Container(
                  padding: EdgeInsets.only(
                    top: tablet ? 60 : 40,
                    left: tablet ? 28 : 20,
                    right: tablet ? 28 : 20,
                    bottom: tablet ? 28 : 20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: tablet ? 48 : 35,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: profile.profileImage != null &&
                              profile.profileImage!.isNotEmpty
                              ? CachedNetworkImage(
                            imageUrl: profile.profileImage!,
                            width: tablet ? 96 : 70,
                            height: tablet ? 96 : 70,
                            fit: BoxFit.cover,
                          )
                              : Icon(
                            Icons.person,
                            size: tablet ? 40 : 30,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.name,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.headline.copyWith(
                                color: Colors.white,
                                fontSize: tablet ? 22 : 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.email,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white70,
                                fontSize: tablet ? 16 : 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// MENU
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      vertical: tablet ? 20 : 10,
                      horizontal: tablet ? 12 : 5,
                    ),
                    children: [
                      _menuItem(
                        icon: Icons.person_outline,
                        title: "Personal profile",
                        tablet: tablet,
                        onTap: () {
                          CustomSmoothNavigator.push(
                              context, const PersonalProfile());
                        },
                      ),
                      _menuItem(
                        icon: Icons.accessibility_new_rounded,
                        title: "My body",
                        tablet: tablet,
                        onTap: () {
                          CustomSmoothNavigator.push(
                              context, const MyBodyScreen());
                        },
                      ),
                      _menuItem(
                        icon: Icons.calculate_outlined,
                        title: "BMI calculate",
                        tablet: tablet,
                        onTap: () {
                          CustomSmoothNavigator.push(
                              context, const BmiCalculate());
                        },
                      ),
                      _menuItem(
                        icon: Icons.shopping_bag,
                        title: "Orders",
                        tablet: tablet,
                        onTap: () {
                          CustomSmoothNavigator.push(
                              context, OrdersScreen());
                        },
                      ),
                      _menuItem(
                        icon: Icons.people_outline,
                        title: "Connection",
                        tablet: tablet,
                        onTap: () {
                          CustomSmoothNavigator.push(
                              context, ConnectionsScreen());
                        },
                      ),
                      _menuItem(
                        icon: Icons.article,
                        title: "Terms and Privacy",
                        tablet: tablet,
                        onTap: () {
                          CustomSmoothNavigator.push(
                              context, const TermsPrivacyScreen());
                        },
                      ),
                      _menuItem(
                        icon: Icons.delete_forever_outlined,
                        title: 'Delete Account',
                        tablet: tablet,
                        onTap: () {
                          _showDeleteAccountDialog(context);
                        },
                        iconColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          content = const SizedBox();
        }

        return TweenAnimationBuilder<Offset>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: const Offset(-1, 0), end: Offset.zero),
          curve: Curves.easeInOutCubic,
          builder: (context, offset, child) {
            return Transform.translate(
              offset: Offset(offset.dx * width, 0),
              child: IgnorePointer(
                ignoring: offset.dx != 0,
                child: child,
              ),
            );
          },
          child: Align(
            alignment: Alignment.centerLeft,
            child: Material(
              color: Colors.white,
              elevation: 8,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              child: Container(
                width: width,
                height: screenHeight,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool tablet,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tablet ? 24 : 16,
          vertical: tablet ? 12 : 6,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: tablet ? 32 : 26,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.body.copyWith(
                  fontSize: tablet ? 18 : 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _launchAccountDeletion(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchAccountDeletion(BuildContext context) async {
    try {
      String? userId;

      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded) {
        userId = profileState.profile.id?.toString();
      }

      if (userId == null) {
        final prefs = await SharedPreferences.getInstance();
        final keys = prefs.getKeys();
        for (String key in keys) {
          if (key.toLowerCase().contains('user') &&
              key.toLowerCase().contains('id')) {
            final value = prefs.get(key);
            if (value != null) {
              userId = value.toString();
              break;
            }
          }
        }
      }

      if (userId != null && userId.isNotEmpty) {
        final String deletionUrl =
            'https://fitfirst.online/account-deletion?user_id=$userId';
        final Uri url = Uri.parse(deletionUrl);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open account deletion page')),
          );
        }
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User ID not found. Please login again.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
}