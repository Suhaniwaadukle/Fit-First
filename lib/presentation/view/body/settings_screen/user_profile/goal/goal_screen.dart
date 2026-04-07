import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_text_styles.dart';
import 'package:orka_sports/core/enum/goal_activity_type.dart';
import 'package:orka_sports/data/models/goal_data/goal_data.dart'; // Your GoalData model
import 'package:orka_sports/data/models/profile/profile_model.dart'; // Your ProfileData model
import 'package:orka_sports/presentation/blocs/goal/goal_bloc.dart';
import 'package:orka_sports/presentation/blocs/goal/goal_event.dart';
import 'package:orka_sports/presentation/blocs/goal/goal_state.dart';
import 'package:orka_sports/presentation/view/body/activity_screen/history_screen/history_screen.dart';
import 'package:orka_sports/presentation/widgets/custom_button.dart';
import 'package:orka_sports/presentation/widgets/custom_textfield.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalScreen extends StatefulWidget {
  final GoalData?
  goalToEdit; // For editing an existing goal (custom or predefined if fetched that way)
  final ProfileData
  profileData; // Now always required to check for matching predefined IDs

  const GoalScreen({super.key, this.goalToEdit, required this.profileData});

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _goalStepController;
  late TextEditingController _goalKmController;

  String? _userId;

  // String? _actualGoalIdForApi; // This will be determined in _submitGoal
  GoalActivityType _selectedActivityType = GoalActivityType.walk;
  @override
  void initState() {
    super.initState();

    _goalStepController = TextEditingController(
      text: widget.goalToEdit?.goalStep ?? '',
    );
    _goalKmController = TextEditingController(
      text: widget.goalToEdit?.goalKm ?? '',
    );
    if (widget.goalToEdit != null && widget.goalToEdit!.goalName.isNotEmpty) {
      String goalNameLower = widget.goalToEdit!.goalName.toLowerCase();

      if (goalNameLower == 'walk') {
        _selectedActivityType = GoalActivityType.walk;
      } else if (goalNameLower == 'running') {
        _selectedActivityType = GoalActivityType.running;
      } else if (goalNameLower == 'cycling') {
        _selectedActivityType = GoalActivityType.cycling;
      }
    }
    _loadUserId();
    _logInitialData();
  }

  void _logInitialData() {
    log(
      "GoalScreen initState: goalToEdit.id = ${widget.goalToEdit?.id}, goalToEdit.name = ${widget.goalToEdit?.goalName}",
    );
    log(
      "GoalScreen initState: profileData.walkId = '${widget.profileData.walkId}'",
    );
    log(
      "GoalScreen initState: profileData.runningId = '${widget.profileData.runningId}'",
    );
    log(
      "GoalScreen initState: profileData.cyclingId = '${widget.profileData.cyclingId}'",
    );
  }

  Future<void> _loadUserId() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    if (storedUserId != null && storedUserId.isNotEmpty) {
      setState(() {
        _userId = storedUserId;
      });
    } else {
      if (mounted) {
        showCustomSnackbar(context, 'User ID not found. Please login again.');
      }
    }
  }

  @override
  void dispose() {
    _goalStepController.dispose();
    _goalKmController.dispose();
    super.dispose();
  }

  void _submitGoal() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_userId == null || _userId!.isEmpty) {
      showCustomSnackbar(context, 'User ID not available. Cannot save goal.');

      return;
    }

    String activityName = _selectedActivityType.toString().split('.').last;
    String? activityIdForApi;

    switch (_selectedActivityType) {
      case GoalActivityType.walk:
        activityIdForApi = widget.profileData.walkId;
        break;
      case GoalActivityType.running:
        activityIdForApi = widget.profileData.runningId;
        break;
      case GoalActivityType.cycling:
        activityIdForApi = widget.profileData.cyclingId;
        break;
    }

    if (activityIdForApi == null || activityIdForApi.isEmpty) {
      showCustomSnackbar(
        context,
        'Cannot set goal for $activityName. Activity ID missing in profile.',
      );
      return;
    }

    log(
      "Submitting goal for '$activityName'. Using activityId as goalID: '$activityIdForApi'",
    );

    final goalData = GoalData(
      id: activityIdForApi, // This will be used by toApiRequestFields for 'goalID'
      userId: _userId!,
      goalName: activityName, // Send the (potentially lowercase) name
      goalStep: _goalStepController.text,
      goalKm: _goalKmController.text,
    );
    context.read<GoalBloc>().add(ManageGoal(goalData));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.goalToEdit != null
              ? 'Edit Goal: ${_selectedActivityType.toString().split('.').last.capitalizeFirst()}'
              : 'Set ${_selectedActivityType.toString().split('.').last.capitalizeFirst()} Goal',
          style: AppTextStyles.headline,
        ),
        centerTitle: true,
      ),
      body: BlocListener<GoalBloc, GoalState>(
        listener: (context, state) {
          if (state is GoalManageSuccess) {
            showCustomSnackbar(context, state.response.message);
            Navigator.pop(context);
          } else if (state is GoalOperationFailure) {
            showCustomSnackbar(context, 'Error: ${state.error}');
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Select Activity Type',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children:
                    GoalActivityType.values.map((type) {
                      final isSelected = _selectedActivityType == type;
                      String typeName =
                          type.toString().split('.').last.capitalizeFirst();
                      IconData icon;
                      switch (type) {
                        case GoalActivityType.walk:
                          icon = Icons.directions_walk;
                          break;
                        case GoalActivityType.running:
                          icon = Icons.directions_run;
                          break;
                        case GoalActivityType.cycling:
                          icon = Icons.directions_bike;
                          break;
                      }
                      return GestureDetector(
                        onTap: () {
                          // Only allow changing selection if not editing an existing goal
                          // to avoid changing the goal type of an already saved record.
                          // If editing allows changing type, remove this check.
                          if (widget.goalToEdit == null) {
                            setState(() {
                              _selectedActivityType = type;
                            });
                          } else {
                            // Optional: Show a message if trying to change type while editing
                            showCustomSnackbar(
                              context,
                              'Activity type cannot be changed when editing a goal.',
                            );
                          }
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor:
                                  isSelected
                                      ? AppColors.primary
                                      : Colors.grey[300],
                              child: Icon(
                                icon,
                                size: 30,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              typeName,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.grey[700],
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const SizedBox(height: 12),
                    CustomTextfield(
                      controller: _goalStepController,
                      hintText: '',
                      isPassword: false,
                      labelText: 'Steps',

                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter goal steps';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    CustomTextfield(
                      controller: _goalKmController,
                      hintText: '',
                      labelText: 'Target K/m',
                      isPassword: false,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter goal kilometers';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<GoalBloc, GoalState>(
                      builder: (context, state) {
                        bool isCurrentlySubmitting = state is GoalLoading;
                        return CustomButton(
                          onPressed: isCurrentlySubmitting ? null : _submitGoal,

                          text: 'Save Goal',
                        );
                      },
                    ),
                  ],
                ),
              ),
              // ... (Listing other goals section, if you keep it) ...
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalizeFirst() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
