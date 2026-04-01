import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:orka_sports/app/widgets/container/container.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/core/enum/app_theme.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/services/fcm_service.dart';
import 'package:orka_sports/presentation/blocs/profile/profile_bloc.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_text_styles.dart';
import 'package:orka_sports/data/models/profile/profile_model.dart';
import 'package:orka_sports/presentation/blocs/theme/theme_bloc.dart';
import 'package:orka_sports/presentation/view/auth/login_screen/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/presentation/blocs/auth/auth_bloc.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/view/body/settings_screen/user_profile/personal_profile/personal_profile.dart';
import 'package:orka_sports/presentation/view/refer_and_earn/presentation/pages/refer_and_earn.dart';
import 'package:orka_sports/presentation/widgets/show_customsnackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orka_sports/data/models/schedule/full_schedule_model.dart';
import 'package:orka_sports/data/repositories/schedule_repository.dart';
import 'package:orka_sports/core/services/weather_service.dart';
import 'package:orka_sports/data/repositories/bmi_repository.dart';
import 'package:orka_sports/presentation/view/body/settings_screen/user_profile/bmi_calculate/bmi_calculate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isLightMode = false;
  bool isNotificationEnabled = false;

  FullScheduleData? fullScheduleData;
  bool isLoadingSchedule = false;
  String? scheduleError;
  String currentDay = _getCurrentDay();

  late final ScheduleRepository _scheduleRepository;
  late final BmiRepository _bmiRepository;

  Map<String, String> mealActions = {};
  Map<String, bool> mealActionLoading = {};

  double? baseWaterIntake;
  double? adjustedWaterIntake;
  bool isLoadingWaterIntake = false;
  String? waterIntakeError;
  final WeatherService _weatherService = WeatherService();
  double? temperature;

  double? currentTemperature;
  int? currentAqi;
  String? currentLocation;
  bool isLoadingWeather = false;
  String? weatherError;

  bool isWaterReminderEnabled = false;
  TimeOfDay? waterReminderStartTime;
  TimeOfDay? waterReminderEndTime;
  int waterReminderFrequency = 8;
  bool isLoadingWaterReminders = false;
  bool isMarkingWorkoutComplete = false;

  static String _getCurrentDay() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[now.weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    loadWeatherAndAQI();

    _scheduleRepository = ScheduleRepository();
    _bmiRepository = BmiRepository();

    if (context.read<ProfileBloc>().state is! ProfileLoaded) {
      context.read<ProfileBloc>().add(LoadProfile());
    }
     _initializeFCM();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFullSchedule();
      _loadBaseWaterIntake();
      _loadWeatherAndAdjustWaterIntake();
       _loadNotificationPreference();
       _loadWaterReminderPreferences(); // ✅ NEW
       _initializeWaterReminderNotifications(); // ✅ NEW
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

Future<void> _initializeFCM() async {
  try {
    await FCMService.init();
    print('✅ FCM initialized successfully');
  } catch (e) {
    print('❌ FCM initialization error: $e');
  }
}

Future<void> _initializeWaterReminderNotifications() async {
  try {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'water_reminders',
          channelName: 'Water Reminders',
          channelDescription: 'Notifications to remind you to drink water',
          defaultColor: const Color(0xFF2196F3),
          ledColor: Colors.blue,
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
    
    print('✅ Water reminder notifications initialized');
  } catch (e) {
    print('❌ Error initializing water reminder notifications: $e');
  }
}

Future<void> _loadWaterReminderPreferences() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isEnabled = prefs.getBool('water_reminder_enabled') ?? false;
    final startHour = prefs.getInt('water_reminder_start_hour') ?? 8;
    final startMinute = prefs.getInt('water_reminder_start_minute') ?? 0;
    final endHour = prefs.getInt('water_reminder_end_hour') ?? 22;
    final endMinute = prefs.getInt('water_reminder_end_minute') ?? 0;
    final frequency = prefs.getInt('water_reminder_frequency') ?? 8;
    
    setState(() {
      isWaterReminderEnabled = isEnabled;
      waterReminderStartTime = TimeOfDay(hour: startHour, minute: startMinute);
      waterReminderEndTime = TimeOfDay(hour: endHour, minute: endMinute);
      waterReminderFrequency = frequency;
    });
    
    print('✅ Water reminder preferences loaded');
  } catch (e) {
    print('❌ Error loading water reminder preferences: $e');
  }
}

void _showWaterReminderSetupDialog() {
  TimeOfDay startTime = waterReminderStartTime ?? const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = waterReminderEndTime ?? const TimeOfDay(hour: 22, minute: 0);
  int frequency = waterReminderFrequency;
  
  const brandBlue = Color(0xFF0A1950);
  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                brandBlue.withValues(alpha: 0.05),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [brandBlue.withValues(alpha: 0.8), brandBlue],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.local_drink,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Water Reminders',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Stay hydrated throughout the day',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Schedule',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: brandBlue,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: brandBlue.withValues(alpha: 0.8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final selectedTime = await showTimePicker(
                                    context: context,
                                    initialTime: startTime,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          timePickerTheme: TimePickerThemeData(
                                            backgroundColor: Colors.white,
                                            hourMinuteShape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            dayPeriodBorderSide: BorderSide(color: brandBlue),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (selectedTime != null) {
                                    setDialogState(() {
                                      startTime = selectedTime;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: brandBlue.withValues(alpha: 0.05), // ✅ Your brandBlue
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: brandBlue.withValues(alpha: 0.3)), // ✅ Your brandBlue
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        color: brandBlue, // ✅ Your brandBlue
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTimeOfDay(startTime),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: brandBlue, // ✅ Your brandBlue
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // End Time
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End Time',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: brandBlue.withValues(alpha: 0.8), // ✅ Your brandBlue
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final selectedTime = await showTimePicker(
                                    context: context,
                                    initialTime: endTime,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          timePickerTheme: TimePickerThemeData(
                                            backgroundColor: Colors.white,
                                            hourMinuteShape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            dayPeriodBorderSide: BorderSide(color: brandBlue), // ✅ Your brandBlue
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (selectedTime != null) {
                                    setDialogState(() {
                                      endTime = selectedTime;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: brandBlue.withValues(alpha: 0.05), // ✅ Your brandBlue
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: brandBlue.withValues(alpha: 0.3)), // ✅ Your brandBlue
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.access_time_filled,
                                        color: brandBlue, // ✅ Your brandBlue
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTimeOfDay(endTime),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: brandBlue, // ✅ Your brandBlue
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // ✅ FREQUENCY SECTION
                    Text(
                      'Reminder Frequency',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: brandBlue, // ✅ Your brandBlue
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // ✅ FREQUENCY BUTTONS with your brand colors
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                frequency = 8;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: frequency == 8 
                                  ? LinearGradient(colors: [brandBlue.withValues(alpha: 0.8), brandBlue]) // ✅ Your brandBlue
                                  : null,
                                color: frequency == 8 ? null : brandBlue.withValues(alpha: 0.05), // ✅ Your brandBlue
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: frequency == 8 ? brandBlue : brandBlue.withValues(alpha: 0.3), // ✅ Your brandBlue
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.water_drop,
                                    color: frequency == 8 ? Colors.white : brandBlue, // ✅ Your brandBlue
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '8 Times',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: frequency == 8 ? Colors.white : brandBlue, // ✅ Your brandBlue
                                    ),
                                  ),
                                  Text(
                                    'Regular',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: frequency == 8 ? Colors.white70 : brandBlue.withValues(alpha: 0.7), // ✅ Your brandBlue
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                frequency = 12;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: frequency == 12 
                                  ? LinearGradient(colors: [brandBlue.withValues(alpha: 0.8), brandBlue]) // ✅ Your brandBlue
                                  : null,
                                color: frequency == 12 ? null : brandBlue.withValues(alpha: 0.05), // ✅ Your brandBlue
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: frequency == 12 ? brandBlue : brandBlue.withValues(alpha: 0.3), // ✅ Your brandBlue
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.water_drop_outlined,
                                    color: frequency == 12 ? Colors.white : brandBlue, // ✅ Your brandBlue
                                    size: 28,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '12 Times',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: frequency == 12 ? Colors.white : brandBlue, // ✅ Your brandBlue
                                    ),
                                  ),
                                  Text(
                                    'Intensive',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: frequency == 12 ? Colors.white70 : brandBlue.withValues(alpha: 0.7), // ✅ Your brandBlue
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // ✅ PREVIEW SECTION with your brand colors
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            brandBlue.withValues(alpha: 0.08), // ✅ Your brandBlue
                            brandBlue.withValues(alpha: 0.03), // ✅ Your brandBlue
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: brandBlue.withValues(alpha: 0.3)), // ✅ Your brandBlue
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: brandBlue, size: 20), // ✅ Your brandBlue
                              const SizedBox(width: 6),
                              Text(
                                'Preview',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: brandBlue, // ✅ Your brandBlue
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$frequency reminders from ${_formatTimeOfDay(startTime)} to ${_formatTimeOfDay(endTime)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: brandBlue.withValues(alpha: 0.9), // ✅ Your brandBlue
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Every ~${_calculateInterval(startTime, endTime, frequency)} minutes',
                            style: TextStyle(
                              fontSize: 12,
                              color: brandBlue.withValues(alpha: 0.7), // ✅ Your brandBlue
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // ✅ ACTION BUTTONS with your brand colors
              Container(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: brandBlue.withValues(alpha: 0.3)), // ✅ Your brandBlue
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: brandBlue.withValues(alpha: 0.8), // ✅ Your brandBlue
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _enableWaterReminders(startTime, endTime, frequency);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue, // ✅ Your brandBlue
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_active, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Enable',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> _enableWaterReminders(TimeOfDay startTime, TimeOfDay endTime, int frequency) async {
  try {
    setState(() {
      isLoadingWaterReminders = true;
    });

    // Save preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('water_reminder_enabled', true);
    await prefs.setInt('water_reminder_start_hour', startTime.hour);
    await prefs.setInt('water_reminder_start_minute', startTime.minute);
    await prefs.setInt('water_reminder_end_hour', endTime.hour);
    await prefs.setInt('water_reminder_end_minute', endTime.minute);
    await prefs.setInt('water_reminder_frequency', frequency);

    // Update state
    setState(() {
      isWaterReminderEnabled = true;
      waterReminderStartTime = startTime;
      waterReminderEndTime = endTime;
      waterReminderFrequency = frequency;
    });

    // Schedule notifications
    await _scheduleWaterReminders(startTime, endTime, frequency);

    setState(() {
      isLoadingWaterReminders = false;
    });

    showCustomSnackbar(
      context,
      'Water reminders enabled! You\'ll get $frequency reminders throughout the day.',
      isError: false,
    );

  } catch (e) {
    setState(() {
      isLoadingWaterReminders = false;
    });
    
    showCustomSnackbar(
      context,
      'Failed to enable water reminders: $e',
      isError: true,
    );
  }
}

Future<void> _scheduleWaterReminders(TimeOfDay startTime, TimeOfDay endTime, int frequency) async {
  try {
    await _cancelAllWaterReminders();

    final now = DateTime.now();
    var startDateTime = DateTime(now.year, now.month, now.day, startTime.hour, startTime.minute);
    final endDateTime = DateTime(now.year, now.month, now.day, endTime.hour, endTime.minute);

    if (startDateTime.isBefore(now)) {
      startDateTime = startDateTime.add(Duration(days: 1));
      print('⏰ Start time was in the past, scheduling for tomorrow');
    }
    
    // ✅ FIX 2: Calculate time properly 
    final totalMinutes = endDateTime.difference(startDateTime).inMinutes.abs();
    
    // ✅ FIX 3: Handle short time ranges
    if (totalMinutes < frequency) {
      print('⚠️ Time range too short ($totalMinutes min) for $frequency reminders');
      // Reduce frequency to match available time
      frequency = totalMinutes.clamp(1, frequency);
      print('📝 Reduced frequency to $frequency reminders');
    }
    
    // ✅ FIX 4: Calculate proper intervals
    final intervalMinutes = frequency > 1 ? totalMinutes ~/ (frequency - 1) : 0;
    
    print('🕐 Scheduling $frequency reminders from ${startDateTime} to ${endDateTime}');
    print('⏱️ Interval: $intervalMinutes minutes apart');

    // Schedule each reminder
    for (int i = 0; i < frequency; i++) {
      final reminderTime = startDateTime.add(Duration(minutes: intervalMinutes * i));
      
      // ✅ FIX 5: Don't schedule if reminder time is in the past
      if (reminderTime.isAfter(now)) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1000 + i,
            channelKey: 'water_reminders',
            title: 'Hydration Time! 💧',
            body: _getWaterReminderMessage(i + 1, frequency),
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.Default,
            payload: {
              'type': 'water_reminder',
              'reminder_number': '${i + 1}',
              'total_reminders': '$frequency',
            },
          ),
          schedule: NotificationCalendar(
            hour: reminderTime.hour,
            minute: reminderTime.minute,
            second: 0,
            repeats: true,
          ),
        );
        
        print('✅ Scheduled reminder ${i + 1} at ${reminderTime.hour}:${reminderTime.minute.toString().padLeft(2, '0')}');
      } else {
        print('⏭️ Skipped reminder ${i + 1} (time already passed)');
      }
    }

    print('✅ Successfully scheduled water reminders');
  } catch (e) {
    print('❌ Error scheduling water reminders: $e');
    rethrow;
  }
}

Future<void> _disableWaterReminders() async {
  try {
    setState(() {
      isLoadingWaterReminders = true;
    });

    await _cancelAllWaterReminders();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('water_reminder_enabled', false);

    // Update state
    setState(() {
      isWaterReminderEnabled = false;
      isLoadingWaterReminders = false;
    });

    showCustomSnackbar(
      context,
      'Water reminders disabled',
      isError: false,
    );

  } catch (e) {
    setState(() {
      isLoadingWaterReminders = false;
    });
    
    showCustomSnackbar(
      context,
      'Failed to disable water reminders: $e',
      isError: true,
    );
  }
}

Future<void> _cancelAllWaterReminders() async {
  try {
    for (int i = 0; i < 12; i++) { // Cancel up to 12 possible reminders
      await AwesomeNotifications().cancel(1000 + i);
    }
    print('✅ Cancelled all water reminders');
  } catch (e) {
    print('❌ Error cancelling water reminders: $e');
  }
}

String _formatTimeOfDay(TimeOfDay time) {
  final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

int _calculateInterval(TimeOfDay startTime, TimeOfDay endTime, int frequency) {
  final startMinutes = startTime.hour * 60 + startTime.minute;
  final endMinutes = endTime.hour * 60 + endTime.minute;
  final totalMinutes = endMinutes - startMinutes;
  return totalMinutes ~/ (frequency - 1);
}

String _getWaterReminderMessage(int current, int total) {
  final messages = [
    'Time to hydrate! 💧 ($current/$total)',
    'Don\'t forget to drink water! 🥤 ($current/$total)',
    'Stay hydrated, stay healthy! 💙 ($current/$total)', 
    'Water break time! 🌊 ($current/$total)',
    'Your body needs water! 💧 ($current/$total)',
  ];
  return messages[current % messages.length];
}

Future<void> _loadNotificationPreference() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    
    if (mounted) {
      setState(() {
        isNotificationEnabled = enabled;
      });
    }
  } catch (e) {
    print('❌ Error loading notification preference: $e');
  }
}

Future<void> _toggleNotifications(bool value) async {
  if (!mounted) return;

  try {
    // Update FCM preference via API
    final success = await FCMService.updateNotificationPreference(value);
    
    if (success) {
      // Save preference locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', value);
      
      setState(() {
        isNotificationEnabled = value;
      });

      showCustomSnackbar(
        context,
        value 
          ? 'Push notifications enabled! You\'ll receive meal & workout reminders.' 
          : 'Notifications disabled.',
        isError: false,
      );
    } else {
      showCustomSnackbar(
        context,
        'Failed to update notification preference. Please try again.',
        isError: true,
      );
    }
  } catch (e) {
    print('❌ Error toggling notifications: $e');
    showCustomSnackbar(
      context,
      'Error updating notification preference.',
      isError: true,
    );
  }
}

  Future<void> _loadBaseWaterIntake() async {
    if (!mounted) return;
    
    setState(() {
      isLoadingWaterIntake = true;
      waterIntakeError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // ✅ Get the ACTUAL water intake from SharedPreferences
      final storedWaterIntake = prefs.getDouble('baseWaterIntake');
      
      if (storedWaterIntake != null) {
        if (!mounted) return; // ✅ Check mounted before setState
        
        setState(() {
          baseWaterIntake = storedWaterIntake; // ✅ Use stored backend value (3.5L)
          isLoadingWaterIntake = false;
        });
        
        print('✅ Water intake loaded from SharedPreferences: ${storedWaterIntake}L');
        
        // Update adjusted water intake if we have temperature data
        if (currentTemperature != null) {
          _updateAdjustedWaterIntake();
        }
      } else {
        // ✅ NO STORED VALUE - Show popup instead of fallback
        if (!mounted) return; // ✅ Check mounted before setState
        
        setState(() {
          isLoadingWaterIntake = false;
        });
        
        print('⚠️ No water intake found in SharedPreferences, showing BMI popup');
        
        // ✅ Check mounted before showing dialog
        if (mounted) {
          _showCalculateBmiDialog();
        }
      }

    } catch (e) {
      print('❌ Error loading base water intake: $e');
      
      if (!mounted) return; // ✅ Check mounted before setState
      
      setState(() {
        isLoadingWaterIntake = false;
      });
      
      // ✅ Check mounted before showing dialog
      if (mounted) {
        _showCalculateBmiDialog();
      }
    }
  }

  Widget _buildAreaQuality() {
    const brandBlue = Color(0xFF0A1950);

    /// AQI COLOR
    Color getAQIColor(String status) {
      switch (status) {
        case "Good":
          return Colors.green;
        case "Fair":
          return Colors.lightGreen;
        case "Moderate":
          return Colors.orange;
        case "Poor":
          return Colors.deepOrange;
        case "Very Poor":
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    /// TEMPERATURE COLOR
    Color getTempColor(String status) {
      switch (status) {
        case "Cold":
          return Colors.blue;
        case "Mild":
          return Colors.teal;
        case "Warm":
          return Colors.orange;
        case "Hot":
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            brandBlue.withValues(alpha: 0.1),
            brandBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: brandBlue.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: brandBlue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 16, color: brandBlue),
              const SizedBox(width: 5),
              Text(
                "Currently:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: brandBlue,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  currentLocation ?? "Detecting location...",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: brandBlue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              /// TEMPERATURE
              Expanded(
                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: brandBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.thermostat,
                        color: brandBlue,
                        size: 42,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Temperature",
                            style: TextStyle(
                              fontSize: 12,
                              color: brandBlue.withValues(alpha: 0.7),
                            ),
                          ),

                          Text(
                            currentTemperature != null
                                ? '${currentTemperature!.toStringAsFixed(1)}°C'
                                : "--",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: brandBlue,
                            ),
                          ),

                          if (currentTemperature != null)
                            Builder(
                              builder: (context) {
                                final status = WeatherService.getTemperatureCategory(currentTemperature!);
                                final color = getTempColor(status);

                                return Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: color.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              /// AQI
              Expanded(
                child: Row(
                  children: [

                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: brandBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.air,
                        color: brandBlue,
                        size: 42,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Air Quality",
                            style: TextStyle(
                              fontSize: 12,
                              color: brandBlue.withValues(alpha: 0.7),
                            ),
                          ),

                          Text(
                            currentAqi != null
                                ? currentAqi.toString()
                                : "--",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: brandBlue,
                            ),
                          ),

                          if (currentAqi != null)
                            Builder(
                              builder: (context) {
                                final status = AirQualityService.getAQIStatus(currentAqi!);
                                final color = getAQIColor(status);

                                return Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: color.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: color,
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> loadWeatherAndAQI() async {

    currentTemperature = await _weatherService.getCurrentTemperature();

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);

    currentLocation = _weatherService.currentLocation;

    final airService = AirQualityService();
    currentAqi = await airService.getCurrentAQI(
        position.latitude,
        position.longitude);

    setState(() {});
  }

  Future<void> _loadWeatherAndAdjustWaterIntake() async {
    if (!mounted) return; // ✅ Check mounted before setState
    
    setState(() {
      isLoadingWeather = true;
      weatherError = null;
    });

    try {
      final temperature = await _weatherService.getCurrentTemperature();
      
      if (temperature != null) {
        if (!mounted) return; // ✅ Check mounted before setState
        
        setState(() {
          currentTemperature = temperature;
          isLoadingWeather = false;
        });
        
        _updateAdjustedWaterIntake();
      } else {
        throw Exception('Unable to fetch temperature');
      }
    } catch (e) {
      if (!mounted) return; // ✅ Check mounted before setState
      
      setState(() {
        weatherError = e.toString();
        isLoadingWeather = false;
      });
    }
  }

  void _updateAdjustedWaterIntake() {
    if (baseWaterIntake != null && currentTemperature != null) {
      if (!mounted) return; // ✅ Check mounted before setState
      
      setState(() {
        adjustedWaterIntake = WeatherService.adjustWaterIntakeForTemperature(
          baseWaterIntake!, 
          currentTemperature!
        );
      });
    }
  }

  Future<void> _loadFullSchedule() async {
    if (!mounted) return; // ✅ Check mounted before setState
    
    setState(() {
      isLoadingSchedule = true;
      scheduleError = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      print('=== LOADING FULL SCHEDULE ===');
      print('User ID: $userId');
      print('Day: $currentDay');

      final response = await _getFullScheduleFromAPI(userId, currentDay);
      
      if (!mounted) return; // ✅ Check mounted before setState
      
      setState(() {
        fullScheduleData = response.data;
        isLoadingSchedule = false;
      });

      print('=== SCHEDULE LOADED SUCCESSFULLY ===');

    } catch (e) {
      print('=== ERROR LOADING SCHEDULE ===');
      print('Error: $e');
      
      if (!mounted) return; // ✅ Check mounted before setState
      
      setState(() {
        scheduleError = e.toString().replaceAll('Exception: ', '');
        isLoadingSchedule = false;
      });
    }
  }

  Future<void> _recordMealAction(String mealName, String action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      // Set loading state for this meal
      if (!mounted) return; // ✅ Check mounted before setState
      
      setState(() {
        mealActionLoading[mealName.toLowerCase()] = true;
      });

      print('=== RECORDING MEAL ACTION ===');

      final response = await _scheduleRepository.recordMealAction(
        userId: userId,
        day: currentDay,
        mealName: mealName.toLowerCase(),
        action: action,
      );

      if (!mounted) return; // ✅ Check mounted before setState and snackbar

      setState(() {
        mealActions[mealName.toLowerCase()] = action;
        mealActionLoading[mealName.toLowerCase()] = false;
      });

      // Show success message
      showCustomSnackbar(
        context, 
        '${response['message'] ?? 'Meal action recorded successfully'}',
        isError: false,
      );

    } catch (e) {
      print('=== ERROR RECORDING MEAL ACTION ===');
      print('Error: $e');
      
      if (!mounted) return; // ✅ Check mounted before setState and snackbar
      
      setState(() {
        mealActionLoading[mealName.toLowerCase()] = false;
      });

      showCustomSnackbar(
        context, 
        'Failed to record meal action: ${e.toString().replaceAll('Exception: ', '')}',
        isError: true,
      );
    }
  }

  void _showCalculateBmiDialog() {
    if (!mounted) return; // ✅ Check mounted before showing dialog
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.calculate_outlined,
            color: AppColors.primary,
            size: 48,
          ),
          title: Text(
            'BMI Required',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'To get your personalized water intake recommendations, please calculate your BMI first.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_drink,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Get weather-adjusted hydration goals',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Later',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToBmiCalculator();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Calculate BMI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToBmiCalculator() {
    if (!mounted) return; // ✅ Check mounted before navigation
    
    CustomSmoothNavigator.push(
      context, 
      const BmiCalculate(),
    );
  }

  Future<FullScheduleResponse> _getFullScheduleFromAPI(String userId, String day) async {
    try {
      return await _scheduleRepository.getFullScheduleByDay(
        userId: userId,
        day: day,
      );
    } catch (e) {
      print('Error in _getFullScheduleFromAPI: $e');
      rethrow;
    }
  }

  int _parseTimeForSorting(String timeStr) {
    if (timeStr.isEmpty) return 0;
    
    try {
      String cleanTime = timeStr.replaceAll(RegExp(r'[APMapm\s]'), '');
      
      if (cleanTime.contains(':')) {
        final parts = cleanTime.split(':');
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        
        if (timeStr.toUpperCase().contains('PM') && hours != 12) {
          hours += 12;
        } else if (timeStr.toUpperCase().contains('AM') && hours == 12) {
          hours = 0;
        }
        
        return hours * 60 + minutes;
      }
    } catch (e) {
      print('Error parsing time for sorting: $timeStr - $e');
    }
    
    return 0;
  }

  bool _areButtonsActiveForMeal(String mealTime) {
    if (mealTime.isEmpty) return false;
    
    try {
      final now = DateTime.now();
      final mealDateTime = _parseMealTime(mealTime);
      
      if (mealDateTime == null) return false;
      
      final difference = now.difference(mealDateTime).inMinutes.abs();
      return difference <= 30;
    } catch (e) {
      print('Error checking button activation for meal time: $mealTime - $e');
      return false;
    }
  }

  DateTime? _parseMealTime(String timeStr) {
    if (timeStr.isEmpty) return null;
    
    try {
      final now = DateTime.now();
      String cleanTime = timeStr.trim();
      
      bool isPM = cleanTime.toUpperCase().contains('PM');
      bool isAM = cleanTime.toUpperCase().contains('AM');
      
      cleanTime = cleanTime.replaceAll(RegExp(r'[APMapm\s]'), '');
      
      if (cleanTime.contains(':')) {
        final parts = cleanTime.split(':');
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);
        
        if (isPM && hours != 12) {
          hours += 12;
        } else if (isAM && hours == 12) {
          hours = 0;
        }
        
        return DateTime(now.year, now.month, now.day, hours, minutes);
      }
    } catch (e) {
      print('Error parsing meal time: $timeStr - $e');
    }
    
    return null;
  }

  List<Map<String, dynamic>> _createSortedScheduleItems() {
    List<Map<String, dynamic>> allItems = [];

    if (fullScheduleData == null) return allItems;

    // Add workout if available and has time
    if (fullScheduleData!.dailySchedule != null) {
      final workout = fullScheduleData!.dailySchedule!;
      final startTime = workout.workoutTimeFrom;
      
      if (startTime.isNotEmpty && !workout.workout.toLowerCase().contains('off')) {
        allItems.add({
          'type': 'workout',
          'data': workout,
          'time': startTime,
          'sortTime': _parseTimeForSorting(startTime),
        });
      }
    }

    // Add meals if available
    if (fullScheduleData!.mealSchedule != null) {
      final mealSchedule = fullScheduleData!.mealSchedule!;
      final meals = [
        {'name': 'Breakfast', 'time': mealSchedule.breakfast, 'icon': Icons.free_breakfast},
        {'name': 'Mid Morning', 'time': mealSchedule.midMorningSnack, 'icon': Icons.coffee},
        {'name': 'Lunch', 'time': mealSchedule.lunch, 'icon': Icons.lunch_dining},
        {'name': 'Pre Workout', 'time': mealSchedule.preWorkout, 'icon': Icons.sports_gymnastics},
        {'name': 'Post Workout', 'time': mealSchedule.postWorkout, 'icon': Icons.sports_bar},
        {'name': 'Dinner', 'time': mealSchedule.dinner, 'icon': Icons.dinner_dining},
        {'name': 'Bedtime', 'time': mealSchedule.bedtimeProtein, 'icon': Icons.bedtime},
      ].where((meal) => (meal['time'] as String).isNotEmpty);

      for (final meal in meals) {
        final time = meal['time'] as String;
        allItems.add({
          'type': 'meal',
          'data': meal,
          'time': time,
          'sortTime': _parseTimeForSorting(time),
        });
      }
    }

    // Add supplements if available
    for (final supplement in fullScheduleData!.supplements) {
      if (supplement.time.isNotEmpty) {
        allItems.add({
          'type': 'supplement',
          'data': supplement,
          'time': supplement.time,
          'sortTime': _parseTimeForSorting(supplement.time),
        });
      }
    }

    // Sort all items by time
    allItems.sort((a, b) => (a['sortTime'] as int).compareTo(b['sortTime'] as int));

    return allItems;
  }

Widget _buildWaterIntakeSection() {
  const brandBlue = Color(0xFF0A1950);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Hydration', style: AppTextStyles.title),
          Row(
            children: [
              if (isLoadingWaterReminders)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.blue[700],
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    isWaterReminderEnabled ? Icons.notifications_active : Icons.notifications_none,
                    size: 20,
                    color: isWaterReminderEnabled ? Colors.blue[700] : Colors.grey[600],
                  ),
                  onPressed: isWaterReminderEnabled 
                    ? _disableWaterReminders 
                    : _showWaterReminderSetupDialog,
                  tooltip: isWaterReminderEnabled 
                    ? 'Disable water reminders' 
                    : 'Enable water reminders',
                ),

              if (isLoadingWaterIntake)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    _loadBaseWaterIntake();
                    _loadWeatherAndAdjustWaterIntake();
                  },
                  tooltip: 'Refresh Data',
                ),
            ],
          ),
        ],
      ),

if (isWaterReminderEnabled && waterReminderStartTime != null && waterReminderEndTime != null) ...[
  const SizedBox(height: 8),
  Container(
    padding: const EdgeInsets.all(12), // ✅ Slightly more padding
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          brandBlue.withValues(alpha: 0.08), // ✅ Your brandBlue
          brandBlue.withValues(alpha: 0.05), // ✅ Your brandBlue
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12), // ✅ Rounded like your other cards
      border: Border.all(color: brandBlue.withValues(alpha: 0.3), width: 1.5), // ✅ Your brandBlue
      boxShadow: [
        BoxShadow(
          color: brandBlue.withValues(alpha: 0.1), // ✅ Your brandBlue shadow
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: brandBlue.withValues(alpha: 0.15), // ✅ Your brandBlue
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.notifications_active, 
            color: brandBlue, // ✅ Your brandBlue
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Water Reminders Active',
                style: TextStyle(
                  fontSize: 13,
                  color: brandBlue, // ✅ Your brandBlue
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$waterReminderFrequency reminders • ${_formatTimeOfDay(waterReminderStartTime!)} - ${_formatTimeOfDay(waterReminderEndTime!)}',
                style: TextStyle(
                  fontSize: 11,
                  color: brandBlue.withValues(alpha: 0.8), // ✅ Your brandBlue
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
],

      _buildAreaQuality(),


      if (baseWaterIntake != null) ...[
        if (currentTemperature != null && adjustedWaterIntake != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  brandBlue.withValues(alpha: 0.1),
                  brandBlue.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: brandBlue.withValues(alpha: 0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: brandBlue.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: Row(
              children: [

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: brandBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_drink,
                    color: brandBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [

                          Text(
                            'Daily Water Intake',
                            style: TextStyle(
                              color: brandBlue,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      //
                      // const SizedBox(height: 6),
                      // Row(
                      //   children: [
                      //
                      //     /// Temperature
                      //     Icon(
                      //       Icons.thermostat,
                      //       size: 16,
                      //       color: brandBlue.withValues(alpha: 0.7),
                      //     ),
                      //
                      //     const SizedBox(width: 4),
                      //
                      //     Text(
                      //       currentTemperature != null
                      //           ? '${currentTemperature!.toStringAsFixed(1)}°C - ${WeatherService.getTemperatureCategory(currentTemperature!)}'
                      //           : "Loading...",
                      //       style: TextStyle(
                      //         color: brandBlue.withValues(alpha: 0.7),
                      //         fontSize: 13,
                      //       ),
                      //     ),
                      //
                      //     const SizedBox(width: 28),
                      //
                      //     /// Air Quality
                      //     Icon(
                      //       Icons.air,
                      //       size: 16,
                      //       color: brandBlue.withValues(alpha: 0.7),
                      //     ),
                      //
                      //     const SizedBox(width: 4),
                      //
                      //     Text(
                      //       currentAqi != null
                      //           ? '${currentAqi} - ${AirQualityService.getAQIStatus(currentAqi!)}'
                      //           : "AQI --",
                      //       style: TextStyle(
                      //         color: brandBlue.withValues(alpha: 0.7),
                      //         fontSize: 13,
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '${adjustedWaterIntake!.toStringAsFixed(1)} L',
                            style: TextStyle(
                              color: brandBlue,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          if (adjustedWaterIntake! > baseWaterIntake!) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.arrow_upward,
                                    size: 14,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+${(adjustedWaterIntake! - baseWaterIntake!).toStringAsFixed(1)}L',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 8),
                      Text(
                        adjustedWaterIntake! > baseWaterIntake! 
                          ? 'Increased for current weather conditions'
                          : 'Recommended daily water intake',
                        style: TextStyle(
                          color: brandBlue.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: brandBlue.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: brandBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_drink,
                    color: brandBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Water Intake',
                        style: TextStyle(
                          color: brandBlue,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${baseWaterIntake!.toStringAsFixed(1)} L',
                        style: TextStyle(
                          color: brandBlue,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (isLoadingWeather) ...[
                        Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: brandBlue.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Checking weather conditions...',
                              style: TextStyle(
                                color: brandBlue.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'Base recommendation',
                          style: TextStyle(
                            color: brandBlue.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ] else ...[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_drink,
                    color: AppColors.primary.withValues(alpha: 0.5),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.calculate_outlined,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Calculate BMI First',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get your personalized daily water intake recommendations',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToBmiCalculator,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calculate, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Calculate BMI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
      if (weatherError != null) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Weather data unavailable',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (baseWaterIntake != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Showing base water intake without weather adjustment',
                  style: TextStyle(
                    color: Colors.orange.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _loadBaseWaterIntake();
                    _loadWeatherAndAdjustWaterIntake();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 32),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh, size: 14),
                      const SizedBox(width: 4),
                      Text("Retry", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ],
  );
}

  @override
  Widget build(BuildContext context) {
    context.select<ThemeBloc, bool>(
      (bloc) => bloc.state.appTheme == AppTheme.dark,
    );
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: AppTextStyles.headline2),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.kWhite,
        centerTitle: true,
      ),
      backgroundColor: AppColors.backgroundsecondary,
      body: SafeArea(
      child: MultiBlocListener(
        listeners: [
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                if (mounted) {
                  showCustomSnackbar(context, state.message, isError: true);
                }
              }
            },
          ),
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                if (mounted) { // ✅ Check mounted before navigation
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  CustomSmoothNavigator.pushReplacement(context, LoginScreen());
                }
              }
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            ProfileData? profile;
            bool isUpdating = false;
            
            if (state is ProfileLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.kWhite),
              );
            } else if (state is ProfileLoaded) {
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

            return Stack(
              alignment: Alignment.topRight,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 60),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 50),
                                const Text('Profile', style: AppTextStyles.title),
                                const SizedBox(height: 10),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.person),
                                  title: Text(
                                    profile.name,
                                    style: AppTextStyles.title,
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  onTap: () {
                                    if (mounted) {
                                      CustomSmoothNavigator.push(
                                        context,
                                        const PersonalProfile(),
                                      );
                                    }
                                  },
                                ),
                                Divider(
                                  color: AppColors.kBlack.withValues(alpha: 0.2),
                                ),

                                const SizedBox(height: 20),
                                _buildWaterIntakeSection(),

                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month),
                                        const SizedBox(width: 15),
                                        Text(
                                          "Today Schedule ($currentDay)",
                                          style: AppTextStyles.body,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.refresh,
                                            size: 20,
                                            color: AppColors.primary,
                                          ),
                                          onPressed: _loadFullSchedule,
                                          tooltip: 'Refresh Schedule',
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                AppSize.kHeight10,
                                
                                // Time-Sorted Schedule Display
                                _buildTimeSortedScheduleSection(),
                                
                                const SizedBox(height: 20),
                                const Text(
                                  'Preferences',
                                  style: AppTextStyles.title,
                                ),
                                const SizedBox(height: 10),
                                
                                // Light Mode Toggle
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text(
                                    'Light Mode',
                                    style: AppTextStyles.body,
                                  ),
                                  value: isLightMode,
                                  activeColor: AppColors.primary,
                                  onChanged: (_) {
                                    _showComingSoonDialog('Light Mode');
                                  },
                                ),
                                
                                // Notification Toggle
                                // REPLACE your current notification SwitchListTile with this:
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: const Text(
                                      'Push Notifications',
                                      style: AppTextStyles.body,
                                    ),
                                    subtitle: Text(
                                      isNotificationEnabled 
                                        ? 'Enabled - You\'ll receive meal & workout reminders'
                                        : 'Disabled - Turn on to get schedule notifications',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.kBlack.withValues(alpha: 0.6),
                                      ),
                                    ),
                                    value: isNotificationEnabled,
                                    activeColor: AppColors.primary,
                                    onChanged: _toggleNotifications, // ✅ Use the real toggle method
                                  ),

                                
                                const SizedBox(height: 20),
                                const Text('Other', style: AppTextStyles.title),
                                const SizedBox(height: 10),
                                
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.card_giftcard),
                                  title: const Text(
                                    'Refer & Earn',
                                    style: AppTextStyles.body,
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  onTap: () {
                                    if (mounted) { // ✅ Check mounted before navigation
                                      CustomSmoothNavigator.push(context, ReferAndEarnScreen());
                                      ProviderScope.containerOf(context)
                                          .read(DiProviders.referralControllerProvider.notifier)
                                          .getReferralDashboard(context);
                                    }
                                  },
                                ),
                                
                                const SizedBox(height: 10),
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.logout),
                                  title: const Text(
                                    'Log Out',
                                    style: AppTextStyles.body,
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  onTap: () => _showLogoutDialog(context),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Profile Avatar (always visible)
                Positioned(
                  top: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            spreadRadius: 2,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: ClipOval(
                          child: (profile.profileImage != null && profile.profileImage!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: profile.profileImage!,
                                  width: 95,
                                  height: 95,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => SizedBox(
                                    width: 95,
                                    height: 95,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.person,
                                    size: 50,
                                    color: AppColors.primary,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.primary,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ),
    );
  }

  // Build time-sorted schedule section
  Widget _buildTimeSortedScheduleSection() {
    const brandBlue = Color(0xFF0A1950);

    if (isLoadingSchedule) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: brandBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: brandBlue,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Loading today's schedule...",
                style: TextStyle(
                  color: brandBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (scheduleError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.kRed.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.kRed, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Failed to load schedule",
                    style: TextStyle(
                      color: AppColors.kRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scheduleError!,
              style: TextStyle(
                color: AppColors.kRed.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadFullSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kRed,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 36),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, size: 16),
                    const SizedBox(width: 4),
                    Text("Retry"),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (fullScheduleData == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: brandBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 32,
                color: brandBlue,
              ),
              const SizedBox(height: 8),
              Text(
                "No schedule data available for $currentDay",
                style: TextStyle(
                  color: brandBlue,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final sortedItems = _createSortedScheduleItems();

    if (sortedItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: brandBlue.withValues(alpha: 0.2)),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.event_available,
                size: 48,
                color: brandBlue,
              ),
              const SizedBox(height: 12),
              Text(
                "No activities scheduled for $currentDay",
                style: TextStyle(
                  color: brandBlue,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                "Enjoy your rest day!",
                style: TextStyle(
                  color: brandBlue,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Display all items sorted by time
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: brandBlue.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: brandBlue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: brandBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schedule,
                  color: brandBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Schedule - Sorted by Time",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: brandBlue,
                      ),
                    ),
                    Text(
                      "${sortedItems.length} activities for $currentDay",
                      style: TextStyle(
                        fontSize: 12,
                        color: brandBlue.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          Divider(color: brandBlue.withValues(alpha: 0.2)),
          const SizedBox(height: 12),

          // Display sorted items
          Column(
            children: sortedItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == sortedItems.length - 1;

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: _buildScheduleItem(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Build individual schedule item based on type
  Widget _buildScheduleItem(Map<String, dynamic> item) {
    final type = item['type'] as String;
    final time = item['time'] as String;

    switch (type) {
      case 'workout':
        return _buildWorkoutScheduleItem(item['data'] as DailySchedule);
      case 'meal':
        final mealData = item['data'] as Map<String, dynamic>;
        return _buildMealScheduleItem(
          mealName: mealData['name'] as String,
          mealTime: time,
          mealIcon: mealData['icon'] as IconData,
        );
      case 'supplement':
        return _buildSupplementScheduleItem(item['data'] as Supplement);
      default:
        return const SizedBox.shrink();
    }
  }

  // ✅ Updated workout item with proper mounted checks
  Widget _buildWorkoutScheduleItem(DailySchedule workout) {
    const brandBlue = Color(0xFF0A1950);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brandBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: brandBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: brandBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: brandBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.workout,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: brandBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: brandBlue.withValues(alpha: 0.7),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "${_formatTime(workout.workoutTimeFrom)} - ${_formatTime(workout.workoutTimeTo)}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: brandBlue.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                constraints: const BoxConstraints(maxWidth: 80),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: brandBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatTime(workout.workoutTimeFrom),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Mark as Complete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isMarkingWorkoutComplete
                  ? null
                  : () async {
                      if (!mounted) return; // ✅ Check mounted
                      
                      setState(() { isMarkingWorkoutComplete = true; });
                      try {
                        // Get current location
                        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                        if (!serviceEnabled) {
                          if (mounted) { // ✅ Check mounted before snackbar
                            showCustomSnackbar(context, 'Location services are disabled.', isError: true);
                            setState(() { isMarkingWorkoutComplete = false; });
                          }
                          return;
                        }
                        LocationPermission permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                          if (permission == LocationPermission.denied) {
                            if (mounted) { // ✅ Check mounted before snackbar
                              showCustomSnackbar(context, 'Location permissions are denied.', isError: true);
                              setState(() { isMarkingWorkoutComplete = false; });
                            }
                            return;
                          }
                        }
                        if (permission == LocationPermission.deniedForever) {
                          if (mounted) { // ✅ Check mounted before snackbar
                            showCustomSnackbar(context, 'Location permission permanently denied.', isError: true);
                            setState(() { isMarkingWorkoutComplete = false; });
                          }
                          return;
                        }
                        final position = await Geolocator.getCurrentPosition();

                        final prefs = await SharedPreferences.getInstance();
                        final String? userIdStr = prefs.getString('userId');
                        if (userIdStr == null) {
                          if (mounted) { // ✅ Check mounted before snackbar
                            showCustomSnackbar(context, 'User ID not found.', isError: true);
                            setState(() { isMarkingWorkoutComplete = false; });
                          }
                          return;
                        }
                        int userId = int.tryParse(userIdStr) ?? 0;

                        String day = workout.day ?? DateFormat('EEEE').format(DateTime.now());

                        final data = {
                          "user_id": userId,
                          "day": day,
                          "latitude": position.latitude,
                          "longitude": position.longitude,
                        };

                        final response = await Dio().post(
                          "https://fitfirst.online/Api/markWorkoutComplete",
                          data: data,
                        );

                        final respData = response.data;
                        
                        if (!mounted) return; // ✅ Check mounted before snackbar and setState
                        
                        if (respData["status"] == "success") {
                          showCustomSnackbar(
                            context,
                            "${respData["message"] ?? "Workout marked as complete."} 🎉 Coins awarded: ${respData["coins_awarded_today"] ?? ""}",
                          );
                        } else {
                          showCustomSnackbar(context, respData["message"] ?? "Failed to mark complete", isError: true);
                        }
                      } catch (e) {
                        if (mounted) { // ✅ Check mounted before snackbar
                          showCustomSnackbar(context, "Error: $e", isError: true);
                        }
                      } finally {
                        if (mounted) { // ✅ Check mounted before setState
                          setState(() { isMarkingWorkoutComplete = false; });
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: brandBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isMarkingWorkoutComplete
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Mark as Complete',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Build meal schedule item with time-based buttons
  Widget _buildMealScheduleItem({
    required String mealName,
    required String mealTime,
    required IconData mealIcon,
  }) {
    const brandBlue = Color(0xFF0A1950);

    final mealKey = mealName.toLowerCase();
    final currentAction = mealActions[mealKey];
    final isLoading = mealActionLoading[mealKey] ?? false;
    final isButtonsActive = _areButtonsActiveForMeal(mealTime);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brandBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: brandBlue.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          // Meal info row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: brandBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  mealIcon,
                  color: brandBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: brandBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: brandBlue.withValues(alpha: 0.7),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Meal time",
                          style: TextStyle(
                            fontSize: 13,
                            color: brandBlue.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isButtonsActive ? brandBlue : brandBlue.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _formatTime(mealTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Action buttons
          if (isLoading) ...[
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: brandBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Recording action...',
                    style: TextStyle(
                      fontSize: 12,
                      color: brandBlue.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Eat',
                    icon: Icons.restaurant,
                    color: brandBlue,
                    isSelected: currentAction == 'Eat',
                    onPressed: () => _recordMealAction(mealName, 'Eat'),
                    isActive: isButtonsActive,
                  ),
                ),
                const SizedBox(width: 6),
                
                Expanded(
                  child: _buildActionButton(
                    label: 'Cheat',
                    icon: Icons.cake,
                    color: brandBlue,
                    isSelected: currentAction == 'Cheat',
                    onPressed: () => _recordMealAction(mealName, 'Cheat'),
                    isActive: isButtonsActive,
                  ),
                ),
                const SizedBox(width: 6),
                
                Expanded(
                  child: _buildActionButton(
                    label: 'Skip',
                    icon: Icons.close,
                    color: brandBlue,
                    isSelected: currentAction == 'Skip',
                    onPressed: () => _recordMealAction(mealName, 'Skip'),
                    isActive: isButtonsActive,
                  ),
                ),
              ],
            ),
          ],
          
          // Show current action if selected
          if (currentAction != null && !isLoading) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: brandBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: brandBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getActionIcon(currentAction),
                    size: 10,
                    color: brandBlue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Action: $currentAction',
                    style: TextStyle(
                      fontSize: 10,
                      color: brandBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Build supplement schedule item
  Widget _buildSupplementScheduleItem(Supplement supplement) {
    const brandBlue = Color(0xFF0A1950);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: brandBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: brandBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: brandBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.medication,
              color: brandBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplement.supplementName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: brandBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  supplement.timeSlot,
                  style: TextStyle(
                    fontSize: 13,
                    color: brandBlue.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: brandBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatTime(supplement.time),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build action button with active/inactive states
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    const brandBlue = Color(0xFF0A1950);

    return GestureDetector(
      onTap: isActive ? onPressed : null,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: 32,
          maxHeight: 36,
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive 
            ? (isSelected ? brandBlue : brandBlue.withValues(alpha: 0.1))
            : brandBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? brandBlue : brandBlue.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isActive 
                ? (isSelected ? Colors.white : brandBlue)
                : brandBlue.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive 
                    ? (isSelected ? Colors.white : brandBlue)
                    : brandBlue.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods for action styling
  IconData _getActionIcon(String action) {
    switch (action) {
      case 'Eat': return Icons.restaurant;
      case 'Cheat': return Icons.cake;
      case 'Skip': return Icons.close;
      default: return Icons.help;
    }
  }

  // Format time helper
  String _formatTime(String time) {
    if (time.isEmpty) return '';
    
    try {
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.length >= 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          
          final period = hour >= 12 ? 'PM' : 'AM';
          if (hour > 12) hour -= 12;
          if (hour == 0) hour = 12;
          
          return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
        }
      }
      
      return time;
    } catch (e) {
      return time;
    }
  }

  void _showComingSoonDialog(String feature) {
    if (!mounted) return; // ✅ Check mounted before dialog
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Coming Soon'),
        content: Text('$feature feature is not available yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    if (!mounted) return; // ✅ Check mounted before dialog
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutRequested());
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
