import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/data/models/bmi_data/bmi_calculation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

class BmiDetailsScreen extends StatefulWidget {
  final BmiApiResponseModel bmiApiResponse;

  const BmiDetailsScreen({super.key, required this.bmiApiResponse});

  @override
  State<BmiDetailsScreen> createState() => _BmiDetailsScreenState();
}

class _BmiDetailsScreenState extends State<BmiDetailsScreen> with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));
    _progressController.forward();
    
    // ✅ Save water intake to SharedPreferences when screen loads
    _saveWaterIntakeToPreferences();
  }

  // ✅ NEW METHOD: Save water intake to SharedPreferences
  Future<void> _saveWaterIntakeToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('baseWaterIntake', widget.bmiApiResponse.waterIntakeLiters);
      
      print('✅ Water intake saved to SharedPreferences: ${widget.bmiApiResponse.waterIntakeLiters}L');
    } catch (e) {
      print('❌ Error saving water intake to SharedPreferences: $e');
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'underweight':
        return Colors.orange;
      case 'normal':
        return Colors.green;
      case 'overweight':
        return Colors.red;
      case 'obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bmi = widget.bmiApiResponse.bmi;
    final bmiCategory = widget.bmiApiResponse.bmiCategory;
    final color = _getCategoryColor(bmiCategory);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "BMI Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.kWhite,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBmiCard(bmi, bmiCategory, color),
            const SizedBox(height: 24),
            _buildHealthMetrics(),
            const SizedBox(height: 24),
            _buildNutritionTargets(),
            const SizedBox(height: 24),
            _buildHydrationTarget(), // Added hydration section
            const SizedBox(height: 24),
            _buildStepsTarget(),
          ],
        ),
      ),
    );
  }

  Widget _buildBmiCard(double bmi, String category, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return CircularProgressIndicator(
                      value: _progressAnimation.value * (bmi / 40.0).clamp(0.0, 1.0),
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(color),
                    );
                  },
                ),
              ),
              Column(
                children: [
                  const Text("BMI", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 18)),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      final displayBmi = _progressAnimation.value * bmi;
                      return Text(
                        displayBmi.toStringAsFixed(1),
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 42),
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetrics() {
    final data = widget.bmiApiResponse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Health Metrics",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.kPrimaryColor,
            )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard("BMR", "${data.bmr} kcal", "Basal Metabolic Rate", Icons.local_fire_department),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard("TDEE", "${data.tdee} kcal", "Total Daily Energy Expenditure", Icons.flash_on),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statCard("W/H Ratio", data.wHRatio.toString(), "Waist to Hip Ratio", Icons.straighten, isWide: true),
      ],
    );
  }

  Widget _buildNutritionTargets() {
    final data = widget.bmiApiResponse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Nutrition Targets",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.kPrimaryColor,
            )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard("Protein", "${data.protein} g", "Muscle building", Icons.fitness_center),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard("Carbs", "${data.carbohydrate} g", "Energy source", Icons.grain),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _statCard("Fat", "${data.fat} g", "Healthy fats", Icons.water_drop, isWide: true),
      ],
    );
  }

  // New hydration section
  Widget _buildHydrationTarget() {
    final data = widget.bmiApiResponse;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hydration Goal",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.kPrimaryColor,
            )),
        const SizedBox(height: 12),
        _statCard(
          "Water Intake", 
          "${data.waterIntakeLiters} L", // Using the water_intake_liters from API
          "Daily hydration target", 
          Icons.local_drink, 
          isWide: true
        ),
      ],
    );
  }

  Widget _buildStepsTarget() {
    final data = widget.bmiApiResponse;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Exercise Recommendation",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.kPrimaryColor,
            )),
        const SizedBox(height: 12),
        _statCard("Walking", data.recommendedSteps, "Light cardio routine", Icons.directions_walk, isWide: true),
        const SizedBox(height: 12),
        _statCard("Running", "20 - 30 mins", "Moderate intensity", Icons.directions_run, isWide: true),
        const SizedBox(height: 12),
        _statCard("Cycling", "30 - 45 mins", "Low impact cardio", Icons.directions_bike, isWide: true),
      ],
    );
  }

  Widget _statCard(String title, String value, String subtitle, IconData icon, {bool isWide = false}) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
        ],
      ),
    );
  }
}
