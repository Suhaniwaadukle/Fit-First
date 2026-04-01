import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/core/utils/custom_smooth_navigation.dart';
import 'package:orka_sports/presentation/blocs/activity_subcategory/activity_subcategory_bloc.dart';
import 'package:orka_sports/presentation/view/body/nutrition_screen/nutrition_screen.dart';
import 'package:orka_sports/presentation/view/gym/presentation/pages/gym_food_selection_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ NEW IMPORTS for meal reminders
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:orka_sports/data/repositories/schedule_repository.dart';

class GymDietTrackingScreen extends ConsumerStatefulWidget {
  final String userId;
  final String doshaResult;
  final int foodType;
  
  const GymDietTrackingScreen({
    super.key,
    required this.userId,
    required this.doshaResult,
    required this.foodType,
  });

  @override
  ConsumerState<GymDietTrackingScreen> createState() => _GymDietTrackingScreenState();
}

class _GymDietTrackingScreenState extends ConsumerState<GymDietTrackingScreen> {
  bool showProTip = true;
  Map<String, List<GymAddedMealItem>> userAddedItems = {};
  bool isLoadingUserItems = false;
  Map<String, bool> expandedMeals = {};
  Map<String, bool> mealEnabled = {};
  Set<String> selectedItemsForDeletion = {};
  Map<String, bool> deleteMode = {};

  // Existing state variables
  int? _userFoodTypePreference;
  int? _dynamicCalorieTarget;
  bool _isLoadingCalorieTarget = false;
  String? _calorieTargetError;

  // ✅ NEW: Meal reminder states
  Map<String, bool> mealReminderStates = {};
  bool isLoadingReminders = false;

  // Gym meal types with percentage distribution
  final Map<String, double> gymMealsWithPercentage = {
    'Wake Up Energy': 0.06,     // 6%
    'Breakfast': 0.20,          // 20%
    'Mid Morning Snack': 0.18,  // 18%
    'Lunch': 0.20,              // 20%
    'Pre Workout': 0.08,        // 8%
    'Post Workout': 0.06,       // 6%
    'Dinner': 0.18,             // 18%
    'Bedtime Protein': 0.04,    // 4%
  };

  List<String> get gymMeals => gymMealsWithPercentage.keys.toList();

  @override
  void initState() {
    super.initState();
    
    // Initialize all meals as enabled
    for (var meal in gymMeals) {
      mealEnabled[meal] = true;
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserFoodPreference();
        _loadCalorieTarget();
        _loadMealReminderPreferences(); // ✅ NEW
        _initializeNotifications(); // ✅ NEW
      }
    });
  }

  // ✅ NEW: Initialize AwesomeNotifications
  Future<void> _initializeNotifications() async {
    try {
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'gym_meal_reminders',
            channelName: 'Gym Meal Reminders',
            channelDescription: 'Notifications for gym meal times',
            defaultColor: const Color(0xFF0A1950),
            ledColor: Colors.orange,
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
      
      print('✅ Gym notifications initialized successfully');
    } catch (e) {
      print('❌ Error initializing gym notifications: $e');
    }
  }

  // ✅ NEW: Load meal reminder preferences
  Future<void> _loadMealReminderPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      for (String meal in gymMeals) {
        final reminderKey = 'gym_meal_reminder_${widget.userId}_${meal.replaceAll(' ', '_').toLowerCase()}';
        final isEnabled = prefs.getBool(reminderKey) ?? false;
        setState(() {
          mealReminderStates[meal] = isEnabled;
        });
      }
      
      print('✅ Loaded gym meal reminder preferences: $mealReminderStates');
    } catch (e) {
      print('❌ Error loading gym meal reminder preferences: $e');
    }
  }

  // ✅ NEW: Toggle meal reminder
  Future<void> _toggleMealReminder(String mealName) async {
    try {
      final currentState = mealReminderStates[mealName] ?? false;
      final newState = !currentState;
      
      final prefs = await SharedPreferences.getInstance();
      final reminderKey = 'gym_meal_reminder_${widget.userId}_${mealName.replaceAll(' ', '_').toLowerCase()}';
      await prefs.setBool(reminderKey, newState);
      
      setState(() {
        mealReminderStates[mealName] = newState;
      });
      
      if (newState) {
        await _scheduleGymMealNotification(mealName);
      } else {
        await _cancelGymMealNotification(mealName);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newState 
              ? 'Reminder enabled for $mealName' 
              : 'Reminder disabled for $mealName'
          ),
          backgroundColor: newState ? Colors.green : Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
      
    } catch (e) {
      print('❌ Error toggling gym meal reminder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update reminder for $mealName'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ NEW: Schedule notification for gym meal
  Future<void> _scheduleGymMealNotification(String mealName) async {
    try {
      final mealTime = await _getGymMealTimeFromSchedule(mealName);
      
      if (mealTime != null) {
        final notificationId = _getGymMealNotificationId(mealName);
        
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: notificationId,
            channelKey: 'gym_meal_reminders',
            title: '$mealName Time! 💪',
            body: 'Time for your $mealName. Check your gym meal plan!',
            category: NotificationCategory.Reminder,
            notificationLayout: NotificationLayout.Default,
            payload: {
              'type': 'gym_meal_reminder',
              'meal_name': mealName,
              'user_id': widget.userId,
              'scheduled_time': mealTime.toIso8601String(),
            },
          ),
          schedule: NotificationCalendar(
            hour: mealTime.hour,
            minute: mealTime.minute,
            second: 0,
            repeats: true,
          ),
        );
        
        print('✅ Scheduled gym notification for $mealName at ${mealTime.hour}:${mealTime.minute}');
      } else {
        print('⚠️ No time found for $mealName, cannot schedule notification');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please set a time for $mealName first'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      
    } catch (e) {
      print('❌ Error scheduling gym meal notification: $e');
    }
  }

  // ✅ NEW: Cancel gym meal notification
  Future<void> _cancelGymMealNotification(String mealName) async {
    try {
      final notificationId = _getGymMealNotificationId(mealName);
      await AwesomeNotifications().cancel(notificationId);
      print('✅ Cancelled gym notification for $mealName');
    } catch (e) {
      print('❌ Error cancelling gym meal notification: $e');
    }
  }

  // ✅ NEW: Get gym meal time from schedule system
  Future<DateTime?> _getGymMealTimeFromSchedule(String mealName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId == null) return null;
      
      final scheduleRepository = ScheduleRepository();
      final currentDay = _getCurrentDay();
      
      final response = await scheduleRepository.getFullScheduleByDay(
        userId: userId,
        day: currentDay,
      );
      
      if (response.data?.mealSchedule != null) {
        final gymMealSchedule = response.data!.mealSchedule!;
        String? timeString;
        
        // Map meal names to schedule fields
        switch (mealName) {
          case "Wake Up Energy":
            timeString = null;// as this does not have any field in fullschedule
            break;
          case "Breakfast":
            timeString = gymMealSchedule.breakfast;
            break;
          case "Mid Morning Snack":
            timeString = gymMealSchedule.midMorningSnack;
            break;
          case "Lunch":
            timeString = gymMealSchedule.lunch;
            break;
          case "Pre Workout":
            timeString = gymMealSchedule.preWorkout;
            break;
          case "Post Workout":
            timeString = gymMealSchedule.postWorkout;
            break;
          case "Dinner":
            timeString = gymMealSchedule.dinner;
            break;
          case "Bedtime Protein":
            timeString = gymMealSchedule.bedtimeProtein;
            break;
        }
        
        if (timeString != null && timeString.isNotEmpty) {
          return _parseMealTimeToDateTime(timeString);
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting gym meal time from schedule: $e');
      return null;
    }
  }

  // ✅ NEW: Parse meal time to DateTime (same logic)
  DateTime? _parseMealTimeToDateTime(String timeStr) {
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
      print('Error parsing gym meal time: $timeStr - $e');
    }
    
    return null;
  }

  // ✅ NEW: Get notification ID for gym meal
  int _getGymMealNotificationId(String mealName) {
    final baseId = widget.userId.hashCode + 10000; // Different range from regular meals
    switch (mealName) {
      case "Wake Up Energy": return baseId + 1000;
      case "Breakfast": return baseId + 2000;
      case "Mid Morning Snack": return baseId + 3000;
      case "Lunch": return baseId + 4000;
      case "Pre Workout": return baseId + 5000;
      case "Post Workout": return baseId + 6000;
      case "Dinner": return baseId + 7000;
      case "Bedtime Protein": return baseId + 8000;
      default: return baseId + 9000;
    }
  }

  // ✅ NEW: Map gym meal names for API
String _mapGymMealNameForAPI(String uiMealName) {
  switch (uiMealName) {
    case "Wake Up Energy":
      return "wake_up_energy";
    case "Breakfast":
      return "breakfast";
    case "Mid Morning Snack":
      return "mid_morning_snack";
    case "Lunch":
      return "lunch";
    case "Pre Workout":
      return "pre_workout";        // ✅ Maps to snake_case
    case "Post Workout":
      return "post_workout";       // ✅ Maps to snake_case
    case "Dinner":
      return "dinner";
    case "Bedtime Protein":
      return "bedtime_protein";    // ✅ Maps to snake_case
    default:
      return uiMealName.toLowerCase().replaceAll(' ', '_');
  }
}


  // ✅ UPDATED: Load dynamic calorie target (clean naming)
  Future<void> _loadCalorieTarget() async {
    setState(() {
      _isLoadingCalorieTarget = true;
      _calorieTargetError = null;
    });

    try {
      print('=== LOADING CALORIE TARGET ===');
      print('User ID: ${widget.userId}');

      final response = await ref.read(DiProviders.gymControllerProvider.notifier)
          .getTargetCalories(userId: widget.userId);

      if (mounted) {
        setState(() {
          _dynamicCalorieTarget = response.calorieTarget;
          _isLoadingCalorieTarget = false;
        });

        print('=== CALORIE TARGET LOADED ===');
        print('Target Calories: $_dynamicCalorieTarget');
        
        _loadMealData();
      }
    } catch (e) {
      print('=== ERROR LOADING CALORIE TARGET ===');
      print('Error: $e');
      
      if (mounted) {
        setState(() {
          _calorieTargetError = e.toString().replaceAll('Exception: ', '');
          _isLoadingCalorieTarget = false;
          _dynamicCalorieTarget = null;
        });
      }
    }
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[now.weekday - 1];
  }

  void _toggleDeleteMode(String mealName) {
    setState(() {
      deleteMode[mealName] = !(deleteMode[mealName] ?? false);
      if (!deleteMode[mealName]!) {
        selectedItemsForDeletion.removeWhere((key) => key.startsWith('${mealName}_'));
      }
    });
  }

  void _toggleItemSelection(String mealName, GymAddedMealItem item) {
    final itemKey = '${mealName}_${item.itemId}';
    setState(() {
      if (selectedItemsForDeletion.contains(itemKey)) {
        selectedItemsForDeletion.remove(itemKey);
      } else {
        selectedItemsForDeletion.add(itemKey);
      }
    });
  }

  Future<void> _deleteSelectedItems(String mealName) async {
    final selectedItems = selectedItemsForDeletion
        .where((key) => key.startsWith('${mealName}_'))
        .map((key) => int.parse(key.split('_')[1]))
        .toList();

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select items to delete'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Items'),
        content: Text('Are you sure you want to delete ${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''} from $mealName?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(
            color: Colors.indigo[900]!,
          ),
        ),
      );

      final currentDay = _getCurrentDay();

      print('=== DELETING GYM FOOD ITEMS ===');
      print('User ID: ${widget.userId}');
      print('Day: $currentDay');
      print('Meal Name: $mealName');
      print('Item IDs: $selectedItems');

      await ref.read(DiProviders.gymControllerProvider.notifier)
          .deleteFoodItemsFromMeal(
            userId: widget.userId,
            day: currentDay,
            meal: mealName,
            itemIds: selectedItems,
          );

      if (mounted) {
        Navigator.pop(context);
        
        setState(() {
          selectedItemsForDeletion.removeWhere((key) => key.startsWith('${mealName}_'));
          deleteMode[mealName] = false;
        });

        _loadUserAddedItems();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''} deleted from $mealName successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        
        print('=== ERROR DELETING GYM FOOD ITEMS ===');
        print('Error: $e');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete items: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _loadUserFoodPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFoodType = prefs.getInt('user_food_preference');
      
      if (savedFoodType != null && mounted) {
        setState(() {
          _userFoodTypePreference = savedFoodType;
        });
        print('Loaded saved food preference: $savedFoodType');
      }
    } catch (e) {
      print('Error loading food preference: $e');
    }
  }

  int get currentFoodType {
    if (_userFoodTypePreference != null) {
      return _userFoodTypePreference!;
    }
    
    if (widget.foodType > 0) {
      return widget.foodType;
    }
    
    return _getFoodTypeFromDosha();
  }

  int _getFoodTypeFromDosha() {
    switch (widget.doshaResult.toLowerCase()) {
      case 'vata':
        return 1;
      case 'pitta': 
        return 1;
      case 'kapha':
        return 3;
      default:
        return 1;
    }
  }

  Future<void> _updateFoodPreference(int newFoodType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('user_food_preference', newFoodType);
      
      if (mounted) {
        setState(() {
          _userFoodTypePreference = newFoodType;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Food preference updated to ${_getFoodTypeLabel(newFoodType)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error saving food preference: $e');
    }
  }

  void _loadMealData() {
    _loadUserAddedItems();
  }

  void _loadUserAddedItems() async {
    if (_dynamicCalorieTarget == null || !mounted) return;
    
    setState(() {
      isLoadingUserItems = true;
    });

    for (String meal in gymMeals) {
      try {
        print('=== LOADING USER ITEMS FOR $meal ===');
        
        final items = await _getUserGymMealItems(
          userId: widget.userId,
          meal: meal,
        );
        
        print('=== LOADED ${items.length} ITEMS FOR $meal ===');
        for (var item in items) {
          print('Item: ${item.itemName} - ${item.calories} kcal');
        }
        
        if (mounted) {
          setState(() {
            userAddedItems[meal] = items;
          });
        }
      } catch (e) {
        print('Error loading $meal items: $e');
        if (mounted) {
          setState(() {
            userAddedItems[meal] = [];
          });
        }
      }
    }

    if (mounted) {
      setState(() {
        isLoadingUserItems = false;
      });
    }
  }

  Future<List<GymAddedMealItem>> _getUserGymMealItems({
    required String userId,
    required String meal,
  }) async {
    try {
      print('=== FETCHING ITEMS FOR $meal ===');
      final response = await ref.read(DiProviders.gymControllerProvider.notifier)
          .getUserGymMealItems(
            userId: userId,
            meal: meal,
          );
      print('=== RECEIVED ${response.length} ITEMS FOR $meal ===');
      return response;
    } catch (e) {
      print('Error fetching user gym meal items: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: _isLoadingCalorieTarget
          ? _buildLoadingWidget()
          : _buildContent(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Gym Meal Plan",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.black),
          onPressed: () {
            _loadCalorieTarget();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.kPrimaryColor),
          const SizedBox(height: 20),
          Text(
            "Loading your personalized calorie target...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Please wait while we fetch your data",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_calorieTargetError != null || _dynamicCalorieTarget == null) {
      return RefreshIndicator(
        onRefresh: () async {
          _loadCalorieTarget();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_off_outlined,
                    size: 80,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Connection Required',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Unable to load your personalized calorie target. Please check your internet connection and try again.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_calorieTargetError != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'Error: $_calorieTargetError',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    child: ElevatedButton.icon(
                      onPressed: _loadCalorieTarget,
                      icon: Icon(Icons.refresh, size: 20),
                      label: Text('Retry Connection'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Go Back',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadCalorieTarget();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCalorieTrackingCard(),
              const SizedBox(height: 16),
              _buildMealStatusSummary(),
              const SizedBox(height: 16),
              _buildInstructionText(),
              const SizedBox(height: 20),
              ...gymMeals.map((meal) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildMealSection(
                  mealName: meal,
                  selectedItems: userAddedItems[meal] ?? [],
                ),
              )).toList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealStatusSummary() {
    if (_dynamicCalorieTarget == null) {
      return const SizedBox.shrink();
    }

    final enabledMeals = mealEnabled.values.where((enabled) => enabled).length;
    final totalMeals = gymMeals.length;
    final totalCalories = _dynamicCalorieTarget!;
    
    if (enabledMeals == totalMeals) {
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Calorie Redistribution Active',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$enabledMeals of $totalMeals meals enabled. Your $totalCalories daily calories are redistributed based on meal percentages among enabled meals.',
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieTrackingCard() {
    final targetCalories = _calculateDynamicTargetCalories();
    final consumedCalories = _calculateTotalConsumedCalories();
    final remainingCalories = targetCalories - consumedCalories;
    final isExceeding = consumedCalories > targetCalories;
    final progressColor = isExceeding ? Colors.red : Colors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.track_changes, color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    "",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              GestureDetector(
                onTap: _showFoodPreferenceDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.indigo[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_getFoodTypeIcon(currentFoodType), size: 12, color: Colors.indigo[700]),
                      const SizedBox(width: 4),
                      Text(
                        _getFoodTypeLabel(currentFoodType),
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.indigo[700]
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.edit, size: 10, color: Colors.indigo[500]),
                    ],
                  ),
                ),
              ),
              
              Text(
                "",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          Text(
            "${consumedCalories.toInt()} of ${targetCalories.toInt()} Kcal",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          
          Text(
            isExceeding 
              ? "Exceeds By: ${(-remainingCalories).toInt()} Kcal"
              : "Remaining: ${remainingCalories.toInt()} Kcal",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: progressColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: targetCalories > 0 
                  ? (consumedCalories / targetCalories).clamp(0.0, 1.0) 
                  : 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          _buildNutritionalBreakdown(),
        ],
      ),
    );
  }

  Widget _buildNutritionalBreakdown() {
    final totalProtein = _calculateTotalProtein();
    final totalCarbs = _calculateTotalCarbs();
    final totalFats = _calculateTotalFats();
    
    return Column(
      children: [
        Divider(color: Colors.grey[300]),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildNutrientSummary(
                label: "Protein",
                value: "${totalProtein.toStringAsFixed(1)}g",
                color: Colors.green,
                icon: Icons.fitness_center,
              ),
            ),
            Expanded(
              child: _buildNutrientSummary(
                label: "Carbs",
                value: "${totalCarbs.toStringAsFixed(1)}g",
                color: Colors.orange,
                icon: Icons.grass,
              ),
            ),
            Expanded(
              child: _buildNutrientSummary(
                label: "Fats",
                value: "${totalFats.toStringAsFixed(1)}g",
                color: Colors.red,
                icon: Icons.opacity,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNutrientSummary({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showFoodPreferenceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restaurant_menu, color: Colors.indigo[700]),
            const SizedBox(width: 8),
            const Text('Select Food Preference'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose your preferred food type for meal recommendations:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            _buildFoodPreferenceOption(1, 'Vegetarian', Icons.eco, Colors.green),
            _buildFoodPreferenceOption(2, 'Non-Vegetarian', Icons.restaurant, Colors.red),
            _buildFoodPreferenceOption(3, 'Vegan', Icons.local_florist, Colors.orange),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodPreferenceOption(int value, String label, IconData icon, Color color) {
    final isSelected = currentFoodType == value;
    
    return ListTile(
      leading: Icon(icon, color: isSelected ? color : Colors.grey[400]),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? color : Colors.black,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
      onTap: () {
        Navigator.pop(context);
        _updateFoodPreference(value);
      },
    );
  }

  String _getFoodTypeLabel(int foodType) {
    switch (foodType) {
      case 1: return 'Vegetarian';
      case 2: return 'Non-Vegetarian';
      case 3: return 'Vegan';
      default: return 'All';
    }
  }

  IconData _getFoodTypeIcon(int foodType) {
    switch (foodType) {
      case 1: return Icons.eco;
      case 2: return Icons.restaurant;
      case 3: return Icons.local_florist;
      default: return Icons.restaurant_menu;
    }
  }

  int _calculateDynamicTargetCalories() {
    if (_dynamicCalorieTarget == null) {
      return 0;
    }

    final totalCalories = _dynamicCalorieTarget!;
    final enabledMealsCount = mealEnabled.values.where((enabled) => enabled).length;
    final totalMealsCount = gymMeals.length;
    
    print('=== DYNAMIC CALORIE CALCULATION ===');
    print('Total Calorie Target: $_dynamicCalorieTarget');
    print('Enabled meals: $enabledMealsCount / $totalMealsCount');
    
    return totalCalories;
  }

  int _getMealPercentageTarget(String mealName) {
    if (_dynamicCalorieTarget == null) {
      return 0;
    }

    final totalCalories = _dynamicCalorieTarget!;
    final enabledMeals = gymMeals.where((meal) => mealEnabled[meal] == true).toList();
    
    if (enabledMeals.isEmpty) return 0;

    if (enabledMeals.length == gymMeals.length) {
      final percentage = gymMealsWithPercentage[mealName] ?? 0.0;
      final mealTarget = (totalCalories * percentage).round();
      
      print('=== MEAL PERCENTAGE CALCULATION ===');
      print('Meal: $mealName');
      print('Percentage: ${(percentage * 100).toStringAsFixed(0)}%');
      print('Target: $mealTarget calories');
      
      return mealTarget;
    } else {
      double totalEnabledPercentage = 0.0;
      for (String enabledMeal in enabledMeals) {
        totalEnabledPercentage += gymMealsWithPercentage[enabledMeal] ?? 0.0;
      }
      
      if (totalEnabledPercentage > 0) {
        final mealOriginalPercentage = gymMealsWithPercentage[mealName] ?? 0.0;
        final redistributedPercentage = mealOriginalPercentage / totalEnabledPercentage;
        final mealTarget = (totalCalories * redistributedPercentage).round();
        
        print('=== MEAL REDISTRIBUTION CALCULATION ===');
        print('Meal: $mealName');
        print('Original Percentage: ${(mealOriginalPercentage * 100).toStringAsFixed(0)}%');
        print('Redistributed Percentage: ${(redistributedPercentage * 100).toStringAsFixed(1)}%');
        print('Target: $mealTarget calories');
        
        return mealTarget;
      }
    }
    
    return 0;
  }

  double _calculateTotalConsumedCalories() {
    double total = 0;
    userAddedItems.forEach((meal, items) {
      if (mealEnabled[meal] == true) {
        for (var item in items) {
          total += item.calories;
        }
      }
    });
    print('=== CONSUMED CALORIES CALCULATION ===');
    print('Total consumed calories: $total');
    return total;
  }

  double _calculateTotalProtein() {
    double total = 0;
    userAddedItems.forEach((meal, items) {
      if (mealEnabled[meal] == true) {
        for (var item in items) {
          total += double.tryParse(item.protein) ?? 0;
        }
      }
    });
    return total;
  }

  double _calculateTotalCarbs() {
    double total = 0;
    userAddedItems.forEach((meal, items) {
      if (mealEnabled[meal] == true) {
        for (var item in items) {
          total += double.tryParse(item.carbs) ?? 0;
        }
      }
    });
    return total;
  }

  double _calculateTotalFats() {
    double total = 0;
    userAddedItems.forEach((meal, items) {
      if (mealEnabled[meal] == true) {
        for (var item in items) {
          total += double.tryParse(item.fats) ?? 0;
        }
      }
    });
    return total;
  }

  Widget _buildInstructionText() {
    return Container(
      width: double.infinity,
      child: Text(
        "Tap on meal cards to view added items. Use toggle to enable/disable meals. Calorie targets are distributed based on meal percentages.",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildMealSection({
    required String mealName,
    required List<GymAddedMealItem> selectedItems,
  }) {
    if (_dynamicCalorieTarget == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_off, color: Colors.grey[400], size: 24),
            const SizedBox(height: 8),
            Text(
              mealName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Calorie target unavailable',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    final targetCalories = _getMealPercentageTarget(mealName);
    final selectedCalories = selectedItems.fold(0.0, (sum, item) => sum + item.calories);
    final isExpanded = expandedMeals[mealName] ?? false;
    final isEnabled = mealEnabled[mealName] ?? true;
    final mealPercentage = gymMealsWithPercentage[mealName] ?? 0.0;
    final isDeleteMode = deleteMode[mealName] ?? false;
    final selectedCount = selectedItemsForDeletion.where((key) => key.startsWith('${mealName}_')).length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isEnabled ? Colors.grey[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? Colors.grey[300]! : Colors.grey[400]!,
          width: 1,
        ),
      ),
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: selectedItems.isNotEmpty && isEnabled ? () {
                setState(() {
                  expandedMeals[mealName] = !isExpanded;
                });
              } : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mealName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: isEnabled ? Colors.black : Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (!isEnabled) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'DISABLED - Calories redistributed to other meals',
                                    style: TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[700],
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                isEnabled 
                                    ? "Target: ${targetCalories}Kcal (${(mealPercentage * 100).toStringAsFixed(0)}%) • Added: ${selectedCalories.toInt()}Kcal"
                                    : "Target: ${targetCalories}Kcal (${(mealPercentage * 100).toStringAsFixed(0)}%) - Redistributed",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isEnabled ? Colors.green[600] : Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        // ✅ UPDATED: Added reminder button to action row
                        SizedBox(
                          width: 140, // ✅ INCREASED width to fit reminder button
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildActionIcon(
                                icon: Icons.schedule,
                                color: isEnabled ? Colors.grey[600]! : Colors.grey[400]!,
                                onPressed: isEnabled ? () => _showMealTiming(mealName) : null,
                              ),
                              const SizedBox(width: 4),
                              
                              // ✅ NEW: Reminder toggle button
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: (mealReminderStates[mealName] ?? false) 
                                      ? Colors.orange[300]! 
                                      : Colors.grey[400]!,
                                    width: (mealReminderStates[mealName] ?? false) ? 2 : 1,
                                  ),
                                ),
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: Icon(
                                    (mealReminderStates[mealName] ?? false) 
                                      ? Icons.notifications_active 
                                      : Icons.notifications_none,
                                    color: (mealReminderStates[mealName] ?? false) 
                                      ? Colors.orange 
                                      : (isEnabled ? Colors.grey[600] : Colors.grey[400]),
                                    size: 14,
                                  ),
                                  onPressed: isEnabled ? () => _toggleMealReminder(mealName) : null,
                                  tooltip: (mealReminderStates[mealName] ?? false) 
                                    ? 'Disable $mealName reminder' 
                                    : 'Enable $mealName reminder',
                                ),
                              ),
                              const SizedBox(width: 4),
                              
                              _buildActionIcon(
                                icon: Icons.add,
                                color: isEnabled ? Colors.black : Colors.grey[400]!,
                                onPressed: isEnabled ? () => _showGymFoodSelection(mealName) : null,
                              ),
                              const SizedBox(width: 4),
                              
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    mealEnabled[mealName] = !isEnabled;
                                  });
                                  
                                  final enabledCount = mealEnabled.values.where((e) => e).length;
                                  final totalCalories = _dynamicCalorieTarget!;
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isEnabled 
                                            ? '$mealName disabled. ${targetCalories} calories (${(mealPercentage * 100).toStringAsFixed(0)}%) redistributed to ${enabledCount} remaining meals.'
                                            : '$mealName enabled. Total ${totalCalories} calories redistributed across ${enabledCount} meals based on percentages.',
                                      ),
                                      backgroundColor: isEnabled ? Colors.orange : Colors.green,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isEnabled ? Colors.green : Colors.grey[400]!,
                                      width: 2,
                                    ),
                                    color: isEnabled ? Colors.green[50] : Colors.grey[100],
                                  ),
                                  child: Icon(
                                    isEnabled ? Icons.check : Icons.close,
                                    color: isEnabled ? Colors.green : Colors.grey[400],
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    if (selectedItems.isNotEmpty && isEnabled) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.green[200]!),
                              ),
                              child: Text(
                                "${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''} added • ${selectedCalories.toInt()}/${targetCalories} kcal • Tap to ${isExpanded ? 'collapse' : 'expand'}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: Colors.green[600],
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            if (selectedItems.isNotEmpty && isExpanded && isEnabled) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDeleteMode ? Colors.red[25] : Colors.green[50],
                        border: Border(
                          bottom: BorderSide(color: isDeleteMode ? Colors.red[100]! : Colors.green[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDeleteMode ? Icons.delete : Icons.restaurant_menu,
                            color: isDeleteMode ? Colors.red[700] : Colors.green[700],
                            size: 16
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isDeleteMode 
                                  ? "Select items to delete (${selectedCount} selected)"
                                  : "Added Items (${selectedItems.length})",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDeleteMode ? Colors.red[700] : Colors.green[700],
                              ),
                            ),
                          ),
                          if (isDeleteMode && selectedCount > 0) ...[
                            TextButton(
                              onPressed: () => _deleteSelectedItems(mealName),
                              child: Text(
                                'Delete ($selectedCount)', 
                                style: TextStyle(color: Colors.red[700], fontSize: 12)
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          TextButton(
                            onPressed: () => _toggleDeleteMode(mealName),
                            child: Text(
                              isDeleteMode ? 'Cancel' : 'Delete',
                              style: TextStyle(
                                color: isDeleteMode ? Colors.grey[600] : Colors.red[700],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          if (!isDeleteMode) ...[
                            const SizedBox(width: 8),
                            Text(
                              "${selectedCalories.toInt()} kcal",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: selectedItems.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final item = selectedItems[index];
                        return _buildExpandedFoodItem(item, mealName, isDeleteMode);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: color, size: 14),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildExpandedFoodItem(GymAddedMealItem item, String mealName, bool isDeleteMode) {
    final itemKey = '${mealName}_${item.itemId}';
    final isSelectedForDeletion = selectedItemsForDeletion.contains(itemKey);

    return GestureDetector(
      onTap: isDeleteMode ? () => _toggleItemSelection(mealName, item) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDeleteMode 
              ? (isSelectedForDeletion ? Colors.red[50] : Colors.grey[50])
              : Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDeleteMode 
                ? (isSelectedForDeletion ? Colors.red[200]! : Colors.grey[200]!)
                : Colors.green[200]!,
            width: isSelectedForDeletion ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDeleteMode 
                    ? (isSelectedForDeletion ? Colors.red[100] : Colors.grey[100])
                    : Colors.green[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isDeleteMode 
                    ? (isSelectedForDeletion ? Icons.check_circle : Icons.radio_button_unchecked)
                    : Icons.check_circle,
                color: isDeleteMode 
                    ? (isSelectedForDeletion ? Colors.red[700] : Colors.grey[600])
                    : Colors.green[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDeleteMode && isSelectedForDeletion ? Colors.red[700] : Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${item.quantity} | ${item.calories.toInt()}Kcal",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMiniNutritionalTag("P: ${item.protein}g", Colors.green),
                      const SizedBox(width: 4),
                      _buildMiniNutritionalTag("C: ${item.carbs}g", Colors.orange),
                      const SizedBox(width: 4),
                      _buildMiniNutritionalTag("F: ${item.fats}g", Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isDeleteMode 
                    ? (isSelectedForDeletion ? Colors.red[100] : Colors.grey[100])
                    : Colors.green[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${item.calories.toInt()}",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDeleteMode 
                      ? (isSelectedForDeletion ? Colors.red[700] : Colors.grey[600])
                      : Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniNutritionalTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  void _showMealTiming(String mealName) async {
    TimeOfDay defaultTime = _getGymMealDefaultTime(mealName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set $mealName Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.indigo[900]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Choose your time for $mealName'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, color: Colors.indigo[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    _formatTimeForAPI(defaultTime),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Change Time'),
            onPressed: () async {
              Navigator.pop(context);
              await _selectAndSaveGymMealTime(mealName, defaultTime);
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[900]!,
            ),
            child: const Text('Save Current Time', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              Navigator.pop(context);
              await _saveGymMealTimeToAPI(mealName, defaultTime);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _selectAndSaveGymMealTime(String mealName, TimeOfDay currentTime) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.indigo[900]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      await _saveGymMealTimeToAPI(mealName, selectedTime);
    }
  }

  // ✅ UPDATED: Save gym meal time and reschedule notifications
// ✅ UPDATED: Save gym meal time with API mapping
Future<void> _saveGymMealTimeToAPI(String mealName, TimeOfDay selectedTime) async {
  try {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Colors.indigo[900]!,
        ),
      ),
    );

    final currentDay = _getCurrentDay();
    final formattedTime = _formatTimeForAPI(selectedTime);
    final apiMealName = _mapGymMealNameForAPI(mealName); // ✅ NEW: Map meal name

    print('=== SAVING GYM MEAL TIME ===');
    print('User ID: ${widget.userId}');
    print('Day: $currentDay');
    print('UI Meal Name: $mealName');           // e.g., "Pre Workout"
    print('API Meal Name: $apiMealName');       // e.g., "pre_workout"
    print('Time: $formattedTime');

    await ref.read(DiProviders.gymControllerProvider.notifier)
        .saveSingleMealTime(
          userId: widget.userId,
          day: currentDay,
          meal: apiMealName,           // ✅ CHANGED: Use mapped name instead of mealName
          time: formattedTime,
        );

    // Reschedule notification if reminder is enabled
    if (mealReminderStates[mealName] == true) {
      await _scheduleGymMealNotification(mealName);
    }

    if (mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$mealName time saved successfully for $currentDay'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }

  } catch (e) {
    if (mounted) {
      Navigator.pop(context);
      
      print('=== ERROR SAVING GYM MEAL TIME ===');
      print('Error: $e');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save meal time: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}


  String _formatTimeForAPI(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  TimeOfDay _getGymMealDefaultTime(String mealName) {
    switch (mealName.toLowerCase()) {
      case 'wake up energy':
        return const TimeOfDay(hour: 6, minute: 30);
      case 'breakfast':
        return const TimeOfDay(hour: 8, minute: 0);
      case 'mid morning snack':
        return const TimeOfDay(hour: 10, minute: 30);
      case 'lunch':
        return const TimeOfDay(hour: 13, minute: 0);
      case 'pre workout':
        return const TimeOfDay(hour: 16, minute: 30);
      case 'post workout':
        return const TimeOfDay(hour: 18, minute: 0);
      case 'dinner':
        return const TimeOfDay(hour: 20, minute: 0);
      case 'bedtime protein':
        return const TimeOfDay(hour: 22, minute: 0);
      default:
        return const TimeOfDay(hour: 12, minute: 0);
    }
  }

  void _showGymFoodSelection(String mealName) async {
    final foodTypeToUse = currentFoodType;
    
    print('=== DYNAMIC FOOD SELECTION ===');
    print('Meal: $mealName');
    print('Current Food Type: $foodTypeToUse (${_getFoodTypeLabel(foodTypeToUse)})');
    print('Source: ${_userFoodTypePreference != null ? "User Preference" : "Default/Dosha"}');
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GymFoodSelectionScreen(
          mealName: mealName,
          userId: widget.userId,
          initialFoodType: foodTypeToUse,
          onItemAdded: (item) {},
        ),
      ),
    );

    _loadMealData();
  }
}

class GymAddedMealItem {
  final String id;
  final String userId;
  final String meal;
  final String day;
  final String itemId;
  final String itemName;
  final String quantity;
  final String protein;
  final String carbs;
  final String fats;
  final double calories;
  final String createdAt;
  final String updatedAt;

  GymAddedMealItem({
    required this.id,
    required this.userId,
    required this.meal,
    required this.day,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.calories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GymAddedMealItem.fromJson(Map<String, dynamic> json) {
    return GymAddedMealItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      meal: json['meal']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      itemId: json['item_id']?.toString() ?? '',
      itemName: json['item_name']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      protein: json['protein']?.toString() ?? '',
      carbs: json['carbs']?.toString() ?? '',
      fats: json['fats']?.toString() ?? '',
      calories: double.tryParse(json['calories']?.toString() ?? '0') ?? 0.0,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}
