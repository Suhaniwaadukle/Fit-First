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

class AddbodyiqExerciseScheduleScreen extends ConsumerStatefulWidget {
  final String userId;
  final String doshaResult;
  const AddbodyiqExerciseScheduleScreen({
    super.key,
    required this.userId,
    required this.doshaResult,
  });

  @override
  ConsumerState<AddbodyiqExerciseScheduleScreen> createState() => _AddExerciseScheduleScreenState();
}

class _AddExerciseScheduleScreenState extends ConsumerState<AddbodyiqExerciseScheduleScreen> {
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

  // ✅ NEW: BodyIQ Workout reminder state
  bool isBodyiqWorkoutReminderEnabled = false;
  bool isLoadingBodyiqReminder = false;

  // ✅ Simple BodyIQ workout list
  final List<String> workoutOptions = [
    'Walk',
    'Light Yoga',
    'Swimming',
    'Breathwork',
    'HIIT (High-Intensity Interval Training)',
    'Running',
  ];

  // ✅ NEW: Initialize BodyIQ reminders
  @override
  void initState() {
    super.initState();
    _initializeBodyiqWorkoutReminders();
  }

  // ✅ NEW: Initialize BodyIQ workout reminder notifications
  Future<void> _initializeBodyiqWorkoutReminders() async {
    try {
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'bodyiq_workout_reminders',
            channelName: 'BodyIQ Workout Reminders',
            channelDescription: 'Notifications for BodyIQ workout time',
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
      
      print('✅ BodyIQ workout reminder notifications initialized');
    } catch (e) {
      print('❌ Error initializing BodyIQ workout notifications: $e');
    }
  }

  // ✅ NEW: Load BodyIQ reminder preference
  Future<void> _loadBodyiqWorkoutReminderPreference() async {
    if (selectedDay.isEmpty) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'bodyiq_workout_reminder_${widget.userId}_${selectedDay}';
      final isEnabled = prefs.getBool(key) ?? false;
      
      setState(() {
        isBodyiqWorkoutReminderEnabled = isEnabled;
      });
      
      print('✅ Loaded BodyIQ workout reminder preference for $selectedDay: $isEnabled');
    } catch (e) {
      print('❌ Error loading BodyIQ workout reminder preference: $e');
    }
  }

  // ✅ NEW: Toggle BodyIQ workout reminder
  Future<void> _toggleBodyiqWorkoutReminder(bool enabled) async {
    if (selectedDay.isEmpty || fromTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select day and workout time first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() { isLoadingBodyiqReminder = true; });

    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'bodyiq_workout_reminder_${widget.userId}_${selectedDay}';
      
      if (enabled) {
        // Enable reminder
        await prefs.setBool(key, true);
        await _scheduleBodyiqWorkoutReminder();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("BodyIQ workout reminder enabled for $selectedDay!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Disable reminder
        await prefs.setBool(key, false);
        await _cancelBodyiqWorkoutReminder();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("BodyIQ workout reminder disabled"),
            backgroundColor: Colors.grey,
          ),
        );
      }
      
      setState(() {
        isBodyiqWorkoutReminderEnabled = enabled;
      });
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to toggle reminder: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() { isLoadingBodyiqReminder = false; });
    }
  }

  // ✅ NEW: Schedule BodyIQ workout reminder
  Future<void> _scheduleBodyiqWorkoutReminder() async {
    try {
      final notificationId = _getBodyiqNotificationId(selectedDay);
      
      // Cancel existing notification first
      await AwesomeNotifications().cancel(notificationId);
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'bodyiq_workout_reminders',
          title: 'BodyIQ Workout Time! 🧘‍♀️',
          body: selectedWorkouts.isNotEmpty 
            ? 'Time for your ${selectedWorkouts.join(", ")} session!'
            : 'Time for your BodyIQ workout!',
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          payload: {
            'type': 'bodyiq_workout_reminder',
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
      
      print('✅ Scheduled BodyIQ workout reminder for $selectedDay at ${fromTime!.format(context)}');
    } catch (e) {
      print('❌ Error scheduling BodyIQ workout reminder: $e');
      rethrow;
    }
  }

  // ✅ NEW: Cancel BodyIQ workout reminder
  Future<void> _cancelBodyiqWorkoutReminder() async {
    try {
      final notificationId = _getBodyiqNotificationId(selectedDay);
      await AwesomeNotifications().cancel(notificationId);
      print('✅ Cancelled BodyIQ workout reminder for $selectedDay');
    } catch (e) {
      print('❌ Error cancelling BodyIQ workout reminder: $e');
    }
  }

  // ✅ NEW: Helper methods for BodyIQ
  int _getBodyiqNotificationId(String day) {
    // Generate unique ID based on day (3000-3006 range for BodyIQ)
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return 3000 + days.indexOf(day);
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
        await _loadBodyiqWorkoutReminderPreference();
        
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
      isBodyiqWorkoutReminderEnabled = false; // ✅ Reset reminder state
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
        _loadBodyiqWorkoutReminderPreference();
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
      
      // ✅ NEW: Update BodyIQ reminder if enabled
      if (isBodyiqWorkoutReminderEnabled) {
        await _scheduleBodyiqWorkoutReminder();
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
                      Icon(Icons.self_improvement, color: AppColors.kPrimaryColor), // ✅ Changed icon for BodyIQ
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
              
              // ✅ NEW: BodyIQ Workout Reminder Toggle
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
                              'BodyIQ Workout Reminders',
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
                      if (isLoadingBodyiqReminder)
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
                          value: isBodyiqWorkoutReminderEnabled,
                          onChanged: _toggleBodyiqWorkoutReminder,
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
