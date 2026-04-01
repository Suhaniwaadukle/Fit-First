import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/view/body/activity_screen/centres_list_screen.dart';
import 'package:orka_sports/presentation/view/body/gear_screen/gear_screen.dart';
import 'package:orka_sports/presentation/view/body/nutrition_screen/nutrition_screen.dart';
import 'package:orka_sports/presentation/view/home/presentation/pages/all_coaches_screen.dart';

class ZumbaScreen extends StatefulWidget {
  final String activityId;
  const ZumbaScreen({
    super.key,
    required this.activityId,
 });

  @override
  State<ZumbaScreen> createState() => _ZumbaScreenState();
}

class _ZumbaScreenState extends State<ZumbaScreen> with TickerProviderStateMixin {
  late AnimationController _danceController;
  late Animation<double> _danceAnimation;
  String? _loadingButton; // Add loading state like your ActivityScreen

  @override
  void initState() {
    super.initState();
    
    // Dance animation for energetic effect
    _danceController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _danceAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _danceController,
      curve: Curves.bounceInOut,
    ));
  }

  @override
  void dispose() {
    _danceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zumba'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white, // Same as your yoga screen
              Colors.white, 
              Colors.white, 
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Zumba Header Section
                _buildZumbaHeader(),
                const SizedBox(height: 40),
                
                // Main Action Buttons - EXACT same as ActivityScreen
                _buildActionButtons(),
                const SizedBox(height: 30),
                
                // Inspirational Quote
                _buildInspirationCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildZumbaHeader() {
    return Column(
      children: [
        // Animated Zumba Icon with dance effect
        AnimatedBuilder(
          animation: _danceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _danceAnimation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_gymnastics,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        
        // Zumba Title
        Text(
          'Zumba & Dance',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        
        // Subtitle
        Text(
          'Dance your way to fitness with energetic workouts',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // EXACT same structure as your ActivityScreen
  Widget _buildActionButtons() {
    final zumbaOptions = [
      {
        'icon': Icons.location_city,
        'title': 'Zumba Studio',
        'desc': 'Find nearby dance studios and fitness centers',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.person_4,
        'title': 'Zumba Instructor',
        'desc': 'Connect with certified dance instructors',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.restaurant_menu,
        'title': 'Nutrition',
        'desc': 'Energy-boosting diet for dancers',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.sports_martial_arts,
        'title': 'Gear',
        'desc': 'Dance shoes, workout clothes & accessories',
        'color': AppColors.primary,
      },
    ];

    return Column(
      children: zumbaOptions.map((option) {
        final title = option['title'] as String;
        final icon = option['icon'] as IconData;
        final desc = option['desc'] as String;
        final color = option['color'] as Color;

        final isLoading = _loadingButton == title;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0), // Same as ActivityScreen
          child: Card(
            color: color, // Same primary color background
            elevation: 4, // Same elevation
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18), // Same border radius
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 28, // Same radius as ActivityScreen
                child: isLoading
                    ? const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      )
                    : Icon(
                        icon,
                        color: AppColors.primary,
                        size: 30, // Same icon size
                      ),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // Same font size as ActivityScreen
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                desc,
                style: const TextStyle(
                  fontSize: 15, // Same subtitle size as ActivityScreen
                  color: Colors.white,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded, // Same arrow icon as ActivityScreen
                size: 20,
                color: Colors.white,
              ),
              onTap: isLoading
                  ? null
                  : () => _handleZumbaOptionTap(title),
            ),
          ),
        );
      }).toList(),
    );
  }

Future<void> _handleZumbaOptionTap(String title) async {
  setState(() {
    _loadingButton = title;
  });

  // Simulate loading like your ActivityScreen
  await Future.delayed(const Duration(milliseconds: 800));

  if (mounted) {
    setState(() {
      _loadingButton = null;
    });

        if (title == 'Nutrition') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NutritionScreen(
            activityId: widget.activityId, // Pass the Zumba activity ID
            activityType: 'Nutrition',     // Or use 'Zumba' if needed
          ),
        ),
      );
          context.read<ActivitySubCategoryBloc>().add(
      LoadSubCategories(
        activityId: widget.activityId,
        activityType: 'Nutrition',
      ),
    );
   }

         else if (title == 'Gear') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GearScreen(
            activityId: widget.activityId, // Pass the Yoga activity ID
            activityType: 'Gear',     // Or use 'Yoga' if needed
          ),
        ),
      );
          context.read<ActivitySubCategoryBloc>().add(
      LoadSubCategories(
        activityId: widget.activityId,
        activityType: 'Gear',
      ),
    );

    }
    else if (title == 'Zumba Studio') {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const YogaZumbaCentersScreen(
        subIndustry: 'zumba',
        title: 'Zumba Studios',
      ),
    ),
  );
}


    // ✅ Handle navigation based on title
    else if (title == 'Zumba Instructor') {
      // Navigate to AllCoachesScreen with Yoga filter
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AllCoachesScreen(
            coaches: const [], // Empty list or pass existing data
            initialFilter: 'Zumba', // ✅ Set filter to Yoga
          ),
        ),
      );
    } else {
      // Show snackbar for other options
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$title tapped!'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}


  Widget _buildInspirationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            color: Colors.white,
            size: 30,
          ),
          const SizedBox(height: 15),
          Text(
            '"Dance is the hidden language of the soul.\nLet your body speak through movement."',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '- Martha Graham',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
