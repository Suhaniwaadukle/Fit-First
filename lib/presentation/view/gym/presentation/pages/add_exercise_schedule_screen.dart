import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/app/widgets/common_dropdowns/common_dropdowns.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/data/repositories/schedule_repository.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart'; // ✅ NEW
import 'package:shared_preferences/shared_preferences.dart'; // ✅ NEW

class AddExerciseScheduleScreen extends ConsumerStatefulWidget {
  final String userId;
  final String doshaResult;
  const AddExerciseScheduleScreen({
    super.key,
    required this.userId,
    required this.doshaResult,
  });

  @override
  ConsumerState<AddExerciseScheduleScreen> createState() => _AddExerciseScheduleScreenState();
}

class _AddExerciseScheduleScreenState extends ConsumerState<AddExerciseScheduleScreen> {
  final _formKey = GlobalKey<FormState>();
  final ScheduleRepository _scheduleRepo = ScheduleRepository();
  
  String selectedDay = '';
  List<String> selectedWorkouts = [];
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  
  bool _isLoading = false;
  bool _isLoadingSchedule = false;
  bool _isEditMode = false;
  String? _existingScheduleId;

  // ✅ NEW: Workout reminder state
  bool isWorkoutReminderEnabled = false;
  bool isLoadingReminder = false;

  // ✅ Simple workout list
  final List<String> workoutOptions = [
    'Chest Exercises',
    'Back Exercises',
    'Shoulder Exercises',
    'Biceps Exercises',
    'Triceps Exercises',
    'Leg Exercises',
    'Calf Exercises',
    'Ab & Core Exercises',
    'Cardio Machines',
    'Full-Body / Functional Movements',
    'Bodyweight Exercises',
    'CrossFit/HIIT Style Movements',
  ];

  // ✅ NEW: Initialize reminders
  @override
  void initState() {
    super.initState();
    _initializeWorkoutReminders();
  }

  // ✅ NEW: Initialize workout reminder notifications
  Future<void> _initializeWorkoutReminders() async {
    try {
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'workout_reminders',
            channelName: 'Workout Reminders',
            channelDescription: 'Notifications for workout time',
            defaultColor: AppColors.kPrimaryColor,
            ledColor: AppColors.kPrimaryColor,
            importance: NotificationImportance.High,
            enableVibration: true,
            playSound: true,
          ),
        ],
      );
      
      await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          AwesomeNotifications().requestPermissionToSendNotifications();
        }
      });
      
      print('✅ Workout reminder notifications initialized');
    } catch (e) {
      print('❌ Error initializing workout notifications: $e');
    }
  }

  // ✅ NEW: Load reminder preference
  Future<void> _loadWorkoutReminderPreference() async {
    if (selectedDay.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'workout_reminder_${widget.userId}_${selectedDay}';
      final isEnabled = prefs.getBool(key) ?? false;
      
      setState(() {
        isWorkoutReminderEnabled = isEnabled;
      });
      
      print('✅ Loaded workout reminder preference for $selectedDay: $isEnabled');
    } catch (e) {
      print('❌ Error loading workout reminder preference: $e');
    }
  }

  // ✅ NEW: Toggle workout reminder
  Future<void> _toggleWorkoutReminder(bool enabled) async {
    if (selectedDay.isEmpty || fromTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select day and workout time first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() { isLoadingReminder = true; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'workout_reminder_${widget.userId}_${selectedDay}';
      
      if (enabled) {
        // Enable reminder
        await prefs.setBool(key, true);
        await _scheduleWorkoutReminder();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Workout reminder enabled for $selectedDay!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Disable reminder
        await prefs.setBool(key, false);
        await _cancelWorkoutReminder();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Workout reminder disabled"),
            backgroundColor: Colors.grey,
          ),
        );
      }
      
      setState(() {
        isWorkoutReminderEnabled = enabled;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to toggle reminder: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() { isLoadingReminder = false; });
    }
  }

  // ✅ NEW: Schedule workout reminder
  Future<void> _scheduleWorkoutReminder() async {
    try {
      final notificationId = _getNotificationId(selectedDay);
      
      // Cancel existing notification first
      await AwesomeNotifications().cancel(notificationId);
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'workout_reminders',
          title: 'Workout Time! 💪',
          body: selectedWorkouts.isNotEmpty 
            ? 'Time for your ${selectedWorkouts.join(", ")} workout!'
            : 'Time for your workout!',
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          payload: {
            'type': 'workout_reminder',
            'day': selectedDay,
            'workouts': selectedWorkouts.join(','),
          },
        ),
        schedule: NotificationCalendar(
          weekday: _getDayOfWeek(selectedDay),
          hour: fromTime!.hour,
          minute: fromTime!.minute,
          second: 0,
          repeats: true, // Weekly repeat
        ),
      );
      
      print('✅ Scheduled workout reminder for $selectedDay at ${fromTime!.format(context)}');
    } catch (e) {
      print('❌ Error scheduling workout reminder: $e');
      rethrow;
    }
  }

  // ✅ NEW: Cancel workout reminder
  Future<void> _cancelWorkoutReminder() async {
    try {
      final notificationId = _getNotificationId(selectedDay);
      await AwesomeNotifications().cancel(notificationId);
      print('✅ Cancelled workout reminder for $selectedDay');
    } catch (e) {
      print('❌ Error cancelling workout reminder: $e');
    }
  }

  // ✅ NEW: Helper methods
  int _getNotificationId(String day) {
    // Generate unique ID based on day (2000-2006 range)
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return 2000 + days.indexOf(day);
  }

  int _getDayOfWeek(String day) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days.indexOf(day) + 1; // AwesomeNotifications uses 1-7 for Mon-Sun
  }

  // ✅ Parse time string to TimeOfDay - handles multiple formats
  TimeOfDay? _parseTimeString(String timeString) {
    try {
      print('Parsing time string: $timeString');
      
      // Handle different time formats
      TimeOfDay? parsedTime;
      
      // Try 12-hour format first (08:30 PM)
      try {
        final format = DateFormat('h:mm a'); // 8:30 PM format
        final dateTime = format.parse(timeString);
        parsedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } catch (e) {
        // Try alternative 12-hour format (8:30 PM)
        try {
          final format = DateFormat('hh:mm a'); // 08:30 PM format  
          final dateTime = format.parse(timeString);
          parsedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
        } catch (e) {
          // Try 24-hour format as fallback
          final format = DateFormat('HH:mm'); // 20:30 format
          final dateTime = format.parse(timeString);
          parsedTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
        }
      }
      
      print('Parsed time result: ${parsedTime?.format(context)}');
      return parsedTime;
    } catch (e) {
      print('Error parsing time: $e');
      return null;
    }
  }

  // ✅ Check for existing schedule when day is selected
  Future<void> _checkExistingSchedule(String day) async {
    if (day.isEmpty) return;
    
    setState(() { _isLoadingSchedule = true; });
    
    try {
      final response = await _scheduleRepo.getExerciseScheduleByDay(
        userId: widget.userId,
        day: day,
      );
      
      if (response['success'] == true && response['data'] != null) {
        // Schedule exists - enter edit mode
        final scheduleData = response['data'];
        
        setState(() {
          _isEditMode = true;
          _existingScheduleId = scheduleData['id']?.toString();
          
          // ✅ Pre-populate existing data
          if (scheduleData['workout'] != null && scheduleData['workout'].toString().isNotEmpty) {
            selectedWorkouts = scheduleData['workout']
                .toString()
                .split(', ')
                .where((w) => w.trim().isNotEmpty)
                .toList();
          }
          
          // ✅ Parse and set existing times
          if (scheduleData['workout_time_from'] != null) {
            fromTime = _parseTimeString(scheduleData['workout_time_from'].toString());
          }
          if (scheduleData['workout_time_to'] != null) {
            toTime = _parseTimeString(scheduleData['workout_time_to'].toString());
          }
        });
        
        print('=== EDIT MODE ACTIVATED ===');
        print('Schedule ID: $_existingScheduleId');
        print('Existing workouts: $selectedWorkouts');
        print('From time: ${fromTime?.format(context)}');
        print('To time: ${toTime?.format(context)}');
        
        // ✅ Load reminder preference for this day
        await _loadWorkoutReminderPreference();
        
        // ✅ Show success message for loaded schedule
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Existing schedule loaded for editing"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        
      } else {
        // No existing schedule - add mode
        _resetToAddMode();
        print('=== ADD MODE - NO EXISTING SCHEDULE ===');
      }
    } catch (e) {
      print('Error checking existing schedule: $e');
      _resetToAddMode();
      
      // Optional: Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Could not load existing schedule"),
          backgroundColor: Colors.grey,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      setState(() { _isLoadingSchedule = false; });
    }
  }

  // ✅ Reset to add mode
  void _resetToAddMode() {
    setState(() {
      _isEditMode = false;
      _existingScheduleId = null;
      selectedWorkouts.clear();
      fromTime = null;
      toTime = null;
      isWorkoutReminderEnabled = false; // ✅ Reset reminder state
    });
  }

  Future<void> _pickTime(BuildContext context, ValueChanged<TimeOfDay> onSelected, {TimeOfDay? initial}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay(hour: 6, minute: 0),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: AppColors.kPrimaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      onSelected(picked);
      // ✅ Load reminder preference when time is selected
      if (selectedDay.isNotEmpty) {
        _loadWorkoutReminderPreference();
      }
    }
  }

  // ✅ Show multi-select dialog with pre-selected workouts
  void _showMultiSelectDialog() {
    List<String> tempSelected = List.from(selectedWorkouts);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(_isEditMode ? 'Edit Workouts' : 'Select Workouts'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: workoutOptions.map((workout) {
                    final isSelected = tempSelected.contains(workout);
                    return CheckboxListTile(
                      title: Text(workout),
                      value: isSelected,
                      activeColor: AppColors.kPrimaryColor,
                      onChanged: (bool? selected) {
                        setDialogState(() {
                          if (selected == true) {
                            tempSelected.add(workout);
                          } else {
                            tempSelected.remove(workout);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectedWorkouts = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('OK', style: TextStyle(color: AppColors.kPrimaryColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ Save schedule (handles both add and update)
  Future<void> _saveSchedule() async {
    if (!_formKey.currentState!.validate() || selectedDay.isEmpty || 
        selectedWorkouts.isEmpty || fromTime == null || toTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields and select at least one workout."), 
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() { _isLoading = true; });
    
    try {
      final response = await _scheduleRepo.saveExerciseSchedule(
        userId: widget.userId,
        day: selectedDay,
        workouts: selectedWorkouts,
        fromTime: fromTime!.format(context),
        toTime: toTime!.format(context),
        scheduleId: _isEditMode ? _existingScheduleId : null,
      );
      
      // ✅ NEW: Update reminder if enabled
      if (isWorkoutReminderEnabled) {
        await _scheduleWorkoutReminder();
      }
      
      final action = _isEditMode ? "updated" : "saved";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"] ?? "Schedule $action successfully!"), 
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
      
    } catch (e) {
      final action = _isEditMode ? "update" : "save";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to $action schedule: $e"), 
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: _isEditMode ? "Edit Exercise Schedule" : "Add Exercise Schedule"
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.backgroundPAll,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Day", style: TextStyle(fontWeight: FontWeight.bold)),
              CommonDropDownWidget(
                items: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"],
                hintText: "Select day",
                primaryValue: selectedDay,
                widgetIcon: Icon(Icons.calendar_month_outlined),
                onDropDwChanged: (val) {
                  setState(() { 
                    selectedDay = val ?? ''; 
                  });
                  
                  // Check for existing schedule when day is selected
                  if (val != null && val.isNotEmpty) {
                    _checkExistingSchedule(val);
                  }
                },
              ),
              
              // ✅ Loading indicator for schedule check
              if (_isLoadingSchedule)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Checking existing schedule...", 
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: 20),
              
              // ✅ Edit mode indicator
              if (_isEditMode)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.kPrimaryColor, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Editing existing schedule for $selectedDay",
                        style: TextStyle(
                          color: AppColors.kPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // ✅ Multi-Select Workout Field
              Text("Workouts", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              InkWell(
                onTap: _showMultiSelectDialog,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.fitness_center, color: AppColors.kPrimaryColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          selectedWorkouts.isEmpty 
                            ? 'Select workout types' 
                            : selectedWorkouts.join(', '),
                          style: TextStyle(
                            fontSize: 16,
                            color: selectedWorkouts.isEmpty ? Colors.grey : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              
              // ✅ Show selected count
              if (selectedWorkouts.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  "${selectedWorkouts.length} workout(s) selected", 
                  style: TextStyle(
                    color: AppColors.kPrimaryColor, 
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
              
              SizedBox(height: 20),
              
              // Time selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('From', style: TextStyle(fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => _pickTime(context, (t) => setState(() => fromTime = t), initial: fromTime),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              fromTime?.format(context) ?? 'Select time',
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () => _pickTime(context, (t) => setState(() => toTime = t), initial: toTime),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              toTime?.format(context) ?? 'Select time',
                              style: TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // ✅ NEW: Workout Reminder Toggle
              if (selectedDay.isNotEmpty && fromTime != null) ...[
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.kPrimaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.kPrimaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.notifications_active,
                          color: AppColors.kPrimaryColor,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Workout Reminders',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.kPrimaryColor,
                              ),
                            ),
                            Text(
                              'Get notified at ${fromTime!.format(context)} on $selectedDay',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isLoadingReminder)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.kPrimaryColor,
                          ),
                        )
                      else
                        Switch(
                          value: isWorkoutReminderEnabled,
                          onChanged: _toggleWorkoutReminder,
                          activeColor: AppColors.kPrimaryColor,
                        ),
                    ],
                  ),
                ),
              ],
              
              SizedBox(height: 30),
              
              // ✅ Dynamic button text
              SizedBox(
                width: double.infinity,
                child: ButtonWidget(
                  text: _isEditMode ? "Update Daily Schedule" : "Add Daily Schedule",
                  isLoading: _isLoading,
                  borderRadius: BorderRadius.circular(15),
                  backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.kWhite, fontWeight: FontWeight.bold),
                  onPressed: _saveSchedule,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
