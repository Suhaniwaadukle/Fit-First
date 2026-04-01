import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_text_styles.dart';
import 'package:intl/intl.dart';
import 'package:orka_sports/data/models/profile/profile_model.dart';
import 'package:orka_sports/presentation/view/body/settings_screen/user_profile/bmi_calculate/bmi_calculate.dart';

import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';

class MyBodyScreen extends StatefulWidget {
  const MyBodyScreen({super.key});

  @override
  State<MyBodyScreen> createState() => _MyBodyScreenStateState();
}

class _MyBodyScreenStateState extends State<MyBodyScreen> {
  int _currentStep = 0;
  DateTime _selectedDate = DateTime.now().subtract(
    const Duration(days: 365 * 25),
  ); // Default to 25 years ago
  int _currentHeight = 170;
  int _currentWeight = 65;
  String? _selectedGender;

  @override
  void initState() {
    
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.watch<ProfileBloc>().state;
    if (state is ProfileLoaded) {
      _loadProfileData(state.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if(state is ProfileUpdated){
          showCustomSnackbar(context, 'Profile updated successfully',isError: false);
         // Navigator.pop(context);
               // Navigate to BMI Calculate screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const BmiCalculate(),
        ),
      );
      
          context.read<ProfileBloc>().add(LoadProfile());
        }else if(state is ProfileError){
          showCustomSnackbar(context, 'Error updating profile',isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
          'My Body',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.primary,
            surface: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          iconTheme: IconThemeData(color: AppColors.primary, size: 28),
        ),
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
              return Center(child: CircularProgressIndicator());
            }

            return Stepper(
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              controlsBuilder: (context, controls) {
                return Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: controls.onStepCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.grey.shade700,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 42,
                                vertical: 16,
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: Colors.grey.shade200,
                                  width: 1.5,
                                ),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: isUpdating ? null : controls.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isUpdating
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _currentStep == 3 ? 'Finish' : 'Continue',
                                style: AppTextStyles.button,
                              ),
                      ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Gender'),
                  content: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _buildGenderCard('Male', Icons.male),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: _buildGenderCard('Female', Icons.female),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  isActive: _currentStep >= 0,
                ),
                Step(
                  title: const Text('Date of Birth'),
                  content: _buildDateOfBirthPicker(),
                  isActive: _currentStep >= 1,
                ),
                Step(
                  title: const Text('Height'),
                  content: _buildNumberPicker(
                    value: _currentHeight,
                    onChanged: (value) => setState(() => _currentHeight = value),
                    minValue: 100,
                    maxValue: 250,
                    suffix: 'cm',
                  ),
                  isActive: _currentStep >= 2,
                ),
                Step(
                  title: const Text('Weight'),
                  content: _buildNumberPicker(
                    value: _currentWeight,
                    onChanged: (value) => setState(() => _currentWeight = value),
                    minValue: 30,
                    maxValue: 200,
                    suffix: 'kg',
                  ),
                  isActive: _currentStep >= 3,
                ),
              ],
              onStepContinue: () {
                if (_currentStep < 3) {
                  setState(() => _currentStep++);
                } else {
                  _updateProfile(context);
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) {
                  setState(() => _currentStep--);
                }
              },
            );
          },
        ),
      ),
    ));
  }

void _updateProfile(BuildContext context) async {
  final state = context.read<ProfileBloc>().state;
  if (state is! ProfileLoaded) {
    showCustomSnackbar(context, 'Profile not loaded', isError: true);
    return;
  }
  
  final currentProfile = state.profile;
  final updatedProfile = currentProfile.copyWith(
    gender: _selectedGender?.toLowerCase(),
    height: _currentHeight.toString(),
    weight: _currentWeight.toString(),
    dob: DateFormat('dd/MM/yyyy').format(_selectedDate),
  );

  // Dispatch the update
  context.read<ProfileBloc>().add(UpdateProfile(updatedProfile));
  
  // Show success message
  showCustomSnackbar(context, 'Profile updated successfully', isError: false);
  
  // Navigate immediately (don't wait for BlocListener)
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const BmiCalculate(),
    ),
  );
}



  void _loadProfileData(ProfileData profile) {
    setState(() {
      if (profile.gender != null && profile.gender!.isNotEmpty) {
        _selectedGender = profile.gender![0].toUpperCase() + profile.gender!.substring(1).toLowerCase();
      } else {
        _selectedGender = null;
      }
      if (profile.dob != null && profile.dob!.isNotEmpty) {
        try {
          _selectedDate = DateFormat('dd/MM/yyyy').parse(profile.dob!);
        } catch (_) {
          _selectedDate = DateTime.now().subtract(const Duration(days: 365 * 25));
        }
      }
      // Ensure height and weight are within allowed ranges
      int parsedHeight = int.tryParse(profile.height ?? '') ?? 170;
      int parsedWeight = int.tryParse(profile.weight ?? '') ?? 65;
      _currentHeight = (parsedHeight >= 100 && parsedHeight <= 250) ? parsedHeight : 170;
      _currentWeight = (parsedWeight >= 30 && parsedWeight <= 200) ? parsedWeight : 65;
    });
  }

    Widget _buildNumberPicker({
    required int value,
    required ValueChanged<int> onChanged,
    required int minValue,
    required int maxValue,
    required String suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          NumberPicker(
            value: value,
            minValue: minValue,
            maxValue: maxValue,
            onChanged: onChanged,
            selectedTextStyle: TextStyle(
              color: AppColors.primary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            textStyle: TextStyle(color: Colors.grey.shade400, fontSize: 18),
            itemHeight: 60,
            itemWidth: 80,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200, width: 2),
                bottom: BorderSide(color: Colors.grey.shade200, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              suffix,
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 44,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
            const SizedBox(height: 8),
            Text(
              gender,
              style: TextStyle(
                color: isSelected ? AppColors.primary : Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateOfBirthPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != _selectedDate) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date of Birth',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Age: ${DateTime.now().difference(_selectedDate).inDays ~/ 365} years',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
