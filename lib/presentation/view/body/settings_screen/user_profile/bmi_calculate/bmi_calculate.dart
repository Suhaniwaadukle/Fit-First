// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/data/models/profile/profile_model.dart';
import 'package:orka_sports/data/repositories/bmi_repository.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_text_styles.dart';
import 'package:orka_sports/presentation/view/body/settings_screen/user_profile/bmi_calculate/bmi_details/bmi_details_screen.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BmiCalculate extends StatefulWidget {
  const BmiCalculate({super.key});

  @override
  State<BmiCalculate> createState() => _BmiCalculateState();
}

class _BmiCalculateState extends State<BmiCalculate> {
  String? selectedGender;
  String? selectedLifestyle;
  double height = 170;
  int weight = 65;
  int age = 25;
  bool _initialized = false;
  bool _isCalculating = false;
  bool _showRestoredDataIndicator = false;
  final BmiRepository _bmiRepository = BmiRepository();

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (!_initialized) {
    _initialized = true;
    
    // Schedule the data loading for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _debugFullFlow(); // This will show us what's happening
      await _loadLastInputsAndProfile();
      await _debugFullFlow(); // This will show us what changed
    });
  }
}

  Future<void> _debugFullFlow() async {
  print('🔍 === BMI CALCULATE DEBUG START ===');
  
  // Check SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  print('📱 SharedPreferences Debug:');
  print('   All keys: ${prefs.getKeys()}');
  print('   lastGender: "${prefs.getString('lastGender')}"');
  print('   lastHeight: ${prefs.getDouble('lastHeight')}');
  print('   lastWeight: ${prefs.getInt('lastWeight')}');
  print('   lastAge: ${prefs.getInt('lastAge')}');
  print('   lastLifestyle: "${prefs.getString('lastLifestyle')}"');
  
  // Check if keys exist
  print('📱 Key existence check:');
  print('   lastGender exists: ${prefs.containsKey('lastGender')}');
  print('   lastHeight exists: ${prefs.containsKey('lastHeight')}');
  print('   lastWeight exists: ${prefs.containsKey('lastWeight')}');
  
  // Check current UI state
  print('🎯 Current UI State:');
  print('   selectedGender: $selectedGender');
  print('   selectedLifestyle: $selectedLifestyle');
  print('   height: $height');
  print('   weight: $weight');
  print('   age: $age');
  print('   _showRestoredDataIndicator: $_showRestoredDataIndicator');
  
  print('🔍 === BMI CALCULATE DEBUG END ===');
}


  // ✅ FIXED: Load last inputs from SharedPreferences with profile fallback
Future<void> _loadLastInputsAndProfile() async {
  print('🚀 _loadLastInputsAndProfile() called');
  
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // Debug what's in SharedPreferences
    print('📱 SharedPreferences contents:');
    prefs.getKeys().forEach((key) {
      if (key.startsWith('last')) {
        print('   $key: ${prefs.get(key)}');
      }
    });
    
    // Check if we have the required BMI data
    final hasGender = prefs.containsKey('lastGender') && (prefs.getString('lastGender')?.isNotEmpty ?? false);
    final hasHeight = prefs.containsKey('lastHeight');
    final hasWeight = prefs.containsKey('lastWeight');
    
    print('📊 Data availability check:');
    print('   hasGender: $hasGender');
    print('   hasHeight: $hasHeight'); 
    print('   hasWeight: $hasWeight');
    
    final hasCompleteSharedPrefsData = hasGender && hasHeight && hasWeight;
    print('   hasCompleteSharedPrefsData: $hasCompleteSharedPrefsData');
    
    if (hasCompleteSharedPrefsData) {
      print('✅ Loading from SharedPreferences...');
      
      final loadedGender = prefs.getString('lastGender');
      final loadedHeight = prefs.getDouble('lastHeight') ?? 170.0;
      final loadedWeight = prefs.getInt('lastWeight') ?? 65;
      final loadedAge = prefs.getInt('lastAge') ?? 25;
      final loadedLifestyle = prefs.getString('lastLifestyle') ?? 'Normal';
      
      print('📥 Loaded values:');
      print('   Gender: "$loadedGender"');
      print('   Height: $loadedHeight');
      print('   Weight: $loadedWeight');
      print('   Age: $loadedAge');
      print('   Lifestyle: "$loadedLifestyle"');
      
      setState(() {
        selectedGender = loadedGender;
        selectedLifestyle = loadedLifestyle;
        height = loadedHeight;
        weight = loadedWeight;
        age = loadedAge;
        _showRestoredDataIndicator = true;
      });
      
      print('✅ SharedPreferences data loaded successfully');
      
    } else {
      print('❌ Incomplete SharedPreferences data, loading from profile...');
      
      final state = context.read<ProfileBloc>().state;
      if (state is ProfileLoaded) {
        final profile = state.profile;
        
        setState(() {
          selectedGender = (profile.gender?.isNotEmpty == true)
              ? profile.gender![0].toUpperCase() + profile.gender!.substring(1).toLowerCase()
              : null;
          selectedLifestyle = 'Normal';
          height = double.tryParse(profile.height ?? '') ?? 170.0;
          weight = int.tryParse(profile.weight ?? '') ?? 65;
          age = _calculateAgeFromDob(profile.dob);
          _showRestoredDataIndicator = false;
        });
        
        print('✅ Profile data loaded as fallback');
      }
    }
    
  } catch (e) {
    print('❌ Error in _loadLastInputsAndProfile: $e');
    print('❌ Stack trace: ${StackTrace.current}');
  }
}


  // ✅ Save last inputs to SharedPreferences
  Future<void> _saveLastInputs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastGender', selectedGender ?? '');
      await prefs.setString('lastLifestyle', selectedLifestyle ?? '');
      await prefs.setDouble('lastHeight', height);
      await prefs.setInt('lastWeight', weight);
      await prefs.setInt('lastAge', age);
      
      print('✅ Last BMI inputs saved to SharedPreferences');
    } catch (e) {
      print('❌ Error saving last inputs: $e');
    }
  }

  // ✅ Clear saved inputs
  Future<void> _clearLastInputs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastGender');
      await prefs.remove('lastLifestyle');
      await prefs.remove('lastHeight');
      await prefs.remove('lastWeight');
      await prefs.remove('lastAge');
      
      setState(() {
        _showRestoredDataIndicator = false;
      });
      
      showCustomSnackbar(context, "Saved inputs cleared");
      print('✅ Last BMI inputs cleared');
    } catch (e) {
      print('❌ Error clearing last inputs: $e');
    }
  }

  // ✅ SAFE PROFILE UPDATE: Update profile with proper error handling
  Future<void> _updateProfileSafely() async {
    try {
      if (!mounted) return;
      
      final state = context.read<ProfileBloc>().state;
      if (state is ProfileLoaded) {
        final profile = state.profile;
        
        // Only update if values actually changed
        final needsUpdate = 
            profile.gender?.toLowerCase() != selectedGender?.toLowerCase() ||
            profile.height != height.toStringAsFixed(0) ||
            profile.weight != weight.toString();
        
        if (needsUpdate) {
          final updatedProfile = profile.copyWith(
            gender: selectedGender?.toLowerCase(),
            height: height.toStringAsFixed(0),
            weight: weight.toString(),
            dob: age > 0 ? "01/01/${DateTime.now().year - age}" : profile.dob,
          );
          
          // Add the profile update event
          context.read<ProfileBloc>().add(UpdateProfile(updatedProfile));
          
          // Wait for the profile update to complete
          await _waitForProfileUpdate();
          
          print('✅ Profile updated successfully');
        } else {
          print('✅ Profile already up to date, skipping update');
        }
      }
    } catch (e) {
      print('❌ Error updating profile: $e');
      // Don't throw - allow BMI calculation to continue even if profile update fails
    }
  }

  // ✅ Wait for profile update to complete
  Future<void> _waitForProfileUpdate() async {
    if (!mounted) return;
    
    final completer = Completer<void>();
    StreamSubscription? subscription;
    
    subscription = context.read<ProfileBloc>().stream.listen((state) {
      if (state is ProfileUpdated || state is ProfileError) {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    
    // Timeout after 3 seconds to prevent hanging
    try {
      await completer.future.timeout(const Duration(seconds: 3));
    } catch (e) {
      subscription?.cancel();
      print('⚠️ Profile update timeout: $e');
    }
  }

  int _calculateAgeFromDob(String? dob) {
    if (dob == null || dob.isEmpty) return 25;
    try {
      final parts = dob.split('/');
      if (parts.length == 3) {
        final birthDate = DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
        final now = DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        return age;
      }
    } catch (_) {}
    return 25;
  }

  Future<void> _calculateAndSaveBmi() async {
    if (selectedGender == null) {
      showCustomSnackbar(context, "Please select your gender");
      return;
    }

    if (selectedLifestyle == null) {
      showCustomSnackbar(context, "Please select your lifestyle");
      return;
    }

    setState(() {
      _isCalculating = true;
    });

    try {
      // Calculate BMI using API
      final bmiResult = await _bmiRepository.calculateBmiFromApi(
        height: height,
        weight: weight,
        age: age,
        gender: selectedGender!,
        lifestyle: selectedLifestyle!,
      );

      // Save BMI results to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("bmiCategory", bmiResult.bmiCategory);
      await prefs.setString("lifestyle", selectedLifestyle!);
      
      // Save current inputs for next time
      await _saveLastInputs();
      
      // ✅ SAFE PROFILE UPDATE: Update profile BEFORE navigation
      await _updateProfileSafely();
      
      // Navigate to BMI Details screen AFTER profile update completes
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BmiDetailsScreen(bmiApiResponse: bmiResult),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error calculating BMI: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCalculating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ✅ Listen for profile update completion
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              print('✅ Profile updated successfully in UI');
            } else if (state is ProfileError) {
              print('❌ Profile update error in UI: ${state.toString()}');
            }
          },
        ),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          ProfileData? profile;
          bool isUpdating = false;

          if (state is ProfileLoaded) {
            profile = state.profile;
          } else if (state is ProfileUpdating) {
            profile = state.profile;
            isUpdating = true;
          } else if (state is ProfileUpdated) {
            profile = state.profile;
          }

          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: const Text('BMI Calculate', style: AppTextStyles.headline2),
              centerTitle: true,
              backgroundColor: AppColors.primary,
              elevation: 0,
              actions: [
                // Clear inputs button
                if (_showRestoredDataIndicator)
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    onPressed: _clearLastInputs,
                    tooltip: 'Clear saved inputs',
                  ),
              ],
            ),
            body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  // Restoration indicator
                  if (_showRestoredDataIndicator) _buildRestoredDataIndicator(),
                  const SizedBox(height: 8),
                  _buildGenderSelector(),
                  const SizedBox(height: 24),
                  _buildLifestyleSelector(),
                  const SizedBox(height: 24),
                  _buildSlider(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCounter(
                          'Weight',
                          weight,
                          () => setState(() => weight = (weight - 1).clamp(1, 200)),
                          () => setState(() => weight = (weight + 1).clamp(1, 200)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCounter(
                          'Age',
                          age,
                          () => setState(() => age = (age - 1).clamp(1, 100)),
                          () => setState(() => age = (age + 1).clamp(1, 100)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildBmiPreview(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: (_isCalculating || isUpdating) ? null : _calculateAndSaveBmi,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: (_isCalculating || isUpdating)
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Calculate & Save BMI',
                            style: AppTextStyles.button,
                          ),
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  Widget _buildRestoredDataIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.blue.shade600, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Using your previous BMI calculation inputs',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _clearLastInputs,
            child: Icon(
              Icons.close,
              color: Colors.blue.shade400,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLifestyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lifestyle',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLifestyleCard(
                'Normal',
                Icons.home_outlined,
                'Sedentary',
                selectedLifestyle == 'Normal',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLifestyleCard(
                'Active',
                Icons.directions_walk,
                'Regular Exercise',
                selectedLifestyle == 'Active',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildLifestyleCard(
                'Athlete',
                Icons.fitness_center,
                'High Performance',
                selectedLifestyle == 'Athlete',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLifestyleCard(String lifestyle, IconData icon, String description, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedLifestyle = lifestyle),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
            const SizedBox(height: 6),
            Text(
              lifestyle,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'BMI (Body Mass Index) helps assess if you have a healthy weight for your height. Adjust the values below to calculate your BMI.',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Apple HealthKit information (Required for Apple review)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.favorite, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "This app integrates with Apple Health (HealthKit) to read and sync fitness data such as steps, distance, and calories.",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiPreview() {
    if (selectedGender == null) return const SizedBox.shrink();

    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);

    String category;
    Color categoryColor;
    if (bmi < 18.5) {
      category = 'Underweight';
      categoryColor = const Color(0xFF2196F3);
    } else if (bmi < 25) {
      category = 'Normal';
      categoryColor = const Color(0xFF4CAF50);
    } else if (bmi < 30) {
      category = 'Overweight';
      categoryColor = const Color(0xFFF57C00);
    } else {
      category = 'Obese';
      categoryColor = const Color(0xFFF44336);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your BMI Preview',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    bmi.toStringAsFixed(1),
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'BMI',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: categoryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          if (selectedLifestyle != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Lifestyle: $selectedLifestyle',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          const Text(
            "Source: World Health Organization (WHO)",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          const Text(
            "https://www.who.int/news-room/fact-sheets/detail/obesity-and-overweight",
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: _buildGenderCard(
            'Male',
            Icons.male_rounded,
            selectedGender == 'Male',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildGenderCard(
            'Female',
            Icons.female_rounded,
            selectedGender == 'Female',
          ),
        ),
      ],
    );
  }

  Widget _buildGenderCard(String gender, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Height',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                height.toStringAsFixed(0),
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                ' cm',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: height,
              min: 120,
              max: 220,
              onChanged: (value) => setState(() => height = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCounter(String label, int value, Function() onMinus, Function() onPlus) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(Icons.remove, onMinus),
              const SizedBox(width: 16),
              _buildActionButton(Icons.add, onPlus),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Function() onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: AppColors.primary,
      ),
    );
  }
}
