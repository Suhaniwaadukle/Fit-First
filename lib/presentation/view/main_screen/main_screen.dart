import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_event.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_state.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/presentation/blocs/activity_list/activity_list_bloc.dart'; // ✅ ADDED
import 'package:orka_sports/presentation/view/body/activity_screen/activity_screen.dart';
import 'package:orka_sports/presentation/view/body/settings_screen/settings_screen.dart';
import 'package:orka_sports/presentation/view/body/settings_screen/user_profile/slide_profile_view.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/bodyiq_dashboard/bodyiq_dashboard.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/dashborad/gym_dashboad.dart';
import 'package:orka_sports/presentation/view/home/presentation/pages/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const _screens = [
    HomeScreen(),
    ActivityScreen(),
    GymDashboardScreen(),
    BodyiqDashboardScreen(),
  ];

  static const _titles = ['Home', 'Activity', 'Gym', 'Body IQ'];

  static const _icons = [
    Icons.home_sharp,
    Icons.directions_walk,
    Icons.fitness_center_rounded,
    Icons.self_improvement,
  ];

  late double _displayWidth;
  late double _navBarHeight;
  late double _verticalMargin;
  bool _isInitialLoading = false;
  bool _hasLoadedData = false;

  @override
  void initState() {
    super.initState();
    _loadAllDataInParallel();
  }

Future<void> _loadAllDataInParallel() async {
  if (_hasLoadedData) return;
  _hasLoadedData = true;

  setState(() => _isInitialLoading = true);
  
  try {
    print("🚀 Starting parallel data loading...");
    final startTime = DateTime.now();

    await Future.wait([
      _loadProfileIfNeeded(),
      _loadActivitiesIfNeeded(),
      _loadBodyIQDataIfNeeded(),
    ]);
    
    final duration = DateTime.now().difference(startTime);
    print("⚡ All parallel loading completed in ${duration.inMilliseconds}ms");
    
  } catch (e) {
    print("❌ Error in parallel loading: $e");
  } finally {
    if (mounted) {
      setState(() => _isInitialLoading = false);
    }
  }
}

Future<void> _loadBodyIQDataIfNeeded() async {
  try {
    print("🧠 BodyIQ loading would start here");
    
    // TODO: Add your BodyIQ controller loading when you integrate it
    // Example: await bodyIqController.loadAllBodyIQDataInParallel(context);
    
  } catch (e) {
    print("❌ Error loading BodyIQ data: $e");
  }
}

  Future<void> _loadProfileIfNeeded() async {
    try {
      if (context.read<ProfileBloc>().state is! ProfileLoaded) {
        context.read<ProfileBloc>().add(LoadProfile());
        print("📊 Profile loading started");
      } else {
        print("✅ Profile already loaded");
      }
    } catch (e) {
      print("❌ Error loading profile: $e");
    }
  }

  Future<void> _loadActivitiesIfNeeded() async {
    try {
      if (context.read<ActivityListBloc>().state is! ActivityListLoaded) {
        context.read<ActivityListBloc>().add(LoadActivityList());
        print("🏃 Activities loading started");
      } else {
        print("✅ Activities already loaded");
      }
    } catch (e) {
      print("❌ Error loading activities: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // These never change after the first frame, so cache them.
    _displayWidth   = MediaQuery.of(context).size.width;
    _navBarHeight   = _displayWidth * 0.15;
    _verticalMargin = _displayWidth * 0.08;
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Loading app data...',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      );
    }

    return BlocSelector<ProfileBloc, ProfileState, int>(
      selector: (state) =>
          (state is ProfileLoaded) ? state.currentIndex : 0,
      builder: (context, currentIndex) {
        return Scaffold(
          appBar: _buildAppBar(currentIndex),
          body: SafeArea(
          child: IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          ),
          bottomNavigationBar: _BottomNavBar(
            currentIndex: currentIndex,
            width: _displayWidth,
            navBarHeight: _navBarHeight,
            verticalMargin: _verticalMargin,
            onTap: (i) {
              context.read<ProfileBloc>().add(ChangeTabIndex(i));
              HapticFeedback.lightImpact();
            },
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(int currentIndex) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () => showDialog(
          context: context,
          barrierColor: Colors.black.withAlpha(120),
          builder: (_) => const SideProfileView(),
        ),
      ),
      title: Text(
        _titles[currentIndex],
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      centerTitle: true,
      actions: [
        _ProfileAvatar(displayWidth: _displayWidth),
        const SizedBox(width: 15),
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.currentIndex,
    required this.width,
    required this.navBarHeight,
    required this.verticalMargin,
    required this.onTap,
  });

  final int currentIndex;
  final double width, navBarHeight, verticalMargin;
  final ValueChanged<int> onTap;

  static const _titles = _MainScreenState._titles;
  static const _icons  = _MainScreenState._icons;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: navBarHeight * 1.2,
        margin: EdgeInsets.symmetric(
            horizontal: width * 0.04, vertical: verticalMargin),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x29000000),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_titles.length, (i) {
            final selected = i == currentIndex;
            return Expanded(
              child: _NavItem(
                icon: _icons[i],
                label: _titles[i],
                selected: selected,
                width: width,
                onTap: () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  final IconData icon;
  final String   label;
  final bool     selected;
  final double   width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final item = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.symmetric(horizontal: width * 0.02, vertical: 6),
      margin : EdgeInsets.symmetric(horizontal: width * 0.012),
      decoration: BoxDecoration(
        color: selected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisSize : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? AppColors.primary : Colors.white,
            size: width * 0.058,
          ),
          if (selected) ...[
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: width * 0.035,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );

    return GestureDetector(onTap: onTap, child: item);
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.displayWidth});

  final double displayWidth;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => CustomSmoothNavigator.push(context, SettingsScreen()),
      child: Padding(
        padding: EdgeInsets.only(
            left: displayWidth * 0.04, top: displayWidth * 0.02),
        child: BlocBuilder<ProfileBloc, ProfileState>(
          buildWhen: (prev, curr) => prev != curr,

          builder: (context, state) {
            final imageUrl = (state is ProfileLoaded &&
                    state.profile.profileImage != null &&
                    state.profile.profileImage!.isNotEmpty)
                ? state.profile.profileImage
                : null;

            return CircleAvatar(
              backgroundColor: Colors.white,
              radius: 20,
              child: ClipOval(
                child: imageUrl == null
                    ? Icon(Icons.person,
                        size: displayWidth * 0.08,
                        color: AppColors.primary)
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: displayWidth * 0.08,
                        height: displayWidth * 0.08,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => Icon(Icons.person,
                            size: displayWidth * 0.08,
                            color: AppColors.primary),
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}
