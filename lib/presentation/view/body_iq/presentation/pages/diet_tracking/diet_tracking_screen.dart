import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/diet_models/meal_recommendations_model.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/diet_tracking/food_selection_screen.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/diet_models/added_meal_item_model.dart';
import 'package:orka_sports/presentation/view/body_iq/presentation/pages/products/product_screen.dart';

// ✅ NEW IMPORTS for meal reminders
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:orka_sports/data/repositories/schedule_repository.dart';

class DietTrackingScreen extends ConsumerStatefulWidget {
  final String userId;
  final String doshaResult;
  final int foodType;
  
  const DietTrackingScreen({
    super.key,
    required this.userId,
    required this.doshaResult,
    required this.foodType,
  });

  @override
  ConsumerState<DietTrackingScreen> createState() => _DietTrackingScreenState();
}

class _DietTrackingScreenState extends ConsumerState<DietTrackingScreen> {
  bool showProTip = true;
  Map<String, List<AddedMealItem>> userAddedItems = {};
  bool isLoadingUserItems = false;
  Map<String, bool> expandedMeals = {};
  Set<String> selectedItemsForDeletion = {};
  Map<String, bool> deleteMode = {};

  // ✅ NEW: Meal reminder states
  Map<String, bool> mealReminderStates = {};
  bool isLoadingReminders = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMealData();
      _loadMealReminderPreferences(); // ✅ NEW
      _initializeNotifications(); // ✅ NEW
    });
  }

  // ✅ NEW: Initialize AwesomeNotifications
// ✅ FIXED: Initialize AwesomeNotifications with proper icon
Future<void> _initializeNotifications() async {
  try {
    await AwesomeNotifications().initialize(
      null, // ✅ No default icon
      [
        NotificationChannel(
          channelKey: 'meal_reminders',
          channelName: 'Meal Reminders',
          channelDescription: 'Notifications for meal times',
          defaultColor: const Color(0xFF0A1950),
          ledColor: Colors.orange,
          importance: NotificationImportance.High,
          enableVibration: true,
          playSound: true,
          // ✅ No icon properties at all
        ),
      ],
    );
    
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    
    print('✅ Notifications initialized successfully');
  } catch (e) {
    print('❌ Error initializing notifications: $e');
  }
}



  // ✅ NEW: Load meal reminder preferences
  Future<void> _loadMealReminderPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final meals = ["Breakfast", "Lunch", "Snack", "Dinner"];
      
      for (String meal in meals) {
        final reminderKey = 'meal_reminder_${widget.userId}_${meal.toLowerCase()}';
        final isEnabled = prefs.getBool(reminderKey) ?? false;
        setState(() {
          mealReminderStates[meal] = isEnabled;
        });
      }
      
      print('✅ Loaded meal reminder preferences: $mealReminderStates');
    } catch (e) {
      print('❌ Error loading meal reminder preferences: $e');
    }
  }

  // ✅ NEW: Toggle meal reminder
  Future<void> _toggleMealReminder(String mealName) async {
    try {
      final currentState = mealReminderStates[mealName] ?? false;
      final newState = !currentState;
      
      final prefs = await SharedPreferences.getInstance();
      final reminderKey = 'meal_reminder_${widget.userId}_${mealName.toLowerCase()}';
      await prefs.setBool(reminderKey, newState);
      
      setState(() {
        mealReminderStates[mealName] = newState;
      });
      
      if (newState) {
        await _scheduleMealNotification(mealName);
      } else {
        await _cancelMealNotification(mealName);
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
      print('❌ Error toggling meal reminder: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update reminder for $mealName'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ NEW: Schedule notification for meal
// ✅ FIXED: Schedule notification with proper icon
Future<void> _scheduleMealNotification(String mealName) async {
  try {
    final mealTime = await _getMealTimeFromSchedule(mealName);
    
    if (mealTime != null) {
      final notificationId = _getMealNotificationId(mealName);
      
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'meal_reminders',
          title: '$mealName Time! 🍽️',
          body: 'Time for your $mealName. Check your meal plan!',
          category: NotificationCategory.Reminder,
          notificationLayout: NotificationLayout.Default,
          // ✅ COMPLETELY REMOVED: All icon properties
          payload: {
            'type': 'meal_reminder',
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
      
      print('✅ Scheduled notification for $mealName at ${mealTime.hour}:${mealTime.minute}');
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
    print('❌ Error scheduling meal notification: $e');
  }
}


  // ✅ NEW: Cancel meal notification
  Future<void> _cancelMealNotification(String mealName) async {
    try {
      final notificationId = _getMealNotificationId(mealName);
      await AwesomeNotifications().cancel(notificationId);
      print('✅ Cancelled notification for $mealName');
    } catch (e) {
      print('❌ Error cancelling meal notification: $e');
    }
  }

  // ✅ NEW: Get meal time from schedule system
  Future<DateTime?> _getMealTimeFromSchedule(String mealName) async {
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
        final mealSchedule = response.data!.mealSchedule!;
        String? timeString;
        
        switch (mealName) {
          case "Breakfast":
            timeString = mealSchedule.breakfast;
            break;
          case "Lunch":
            timeString = mealSchedule.lunch;
            break;
          case "Snack":
            timeString = mealSchedule.midMorningSnack;
            break;
          case "Dinner":
            timeString = mealSchedule.dinner;
            break;
        }
        
        if (timeString != null && timeString.isNotEmpty) {
          return _parseMealTimeToDateTime(timeString);
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting meal time from schedule: $e');
      return null;
    }
  }

  // ✅ NEW: Parse meal time to DateTime
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
      print('Error parsing meal time: $timeStr - $e');
    }
    
    return null;
  }

  // ✅ NEW: Get notification ID
  int _getMealNotificationId(String mealName) {
    final baseId = widget.userId.hashCode;
    switch (mealName) {
      case "Breakfast": return baseId + 1000;
      case "Lunch": return baseId + 2000;
      case "Snack": return baseId + 3000;
      case "Dinner": return baseId + 4000;
      default: return baseId + 5000;
    }
  }

  void _loadMealData() {
    ref.read(DiProviders.bodyIqControllerProvider.notifier)
        .loadMealRecommendations(
          context,
          userId: widget.userId,
          doshaResult: widget.doshaResult,
          foodType: widget.foodType,
        );
    
    _loadUserAddedItems();
  }

  void _loadUserAddedItems() async {
    setState(() {
      isLoadingUserItems = true;
    });

    final meals = ["Breakfast", "Lunch", "Snack", "Dinner"];
    
    for (String meal in meals) {
      try {
        print('=== LOADING USER ITEMS FOR $meal ===');
        final items = await ref.read(DiProviders.bodyIqControllerProvider.notifier)
            .getUserMealItems(
              userId: widget.userId,
              meal: meal,
            );
        
        print('=== LOADED ${items.length} ITEMS FOR $meal ===');
        setState(() {
          userAddedItems[meal] = items;
        });
      } catch (e) {
        print('Error loading $meal items: $e');
        setState(() {
          userAddedItems[meal] = [];
        });
      }
    }

    setState(() {
      isLoadingUserItems = false;
    });
  }

  String _getCurrentDay() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[now.weekday - 1];
  }

  String _mapMealNameForAPI(String uiMealName) {
    switch (uiMealName) {
      case "Snack":
        return "mid_morning_snack";
      case "Breakfast":
        return "Breakfast";
      case "Lunch":
        return "Lunch";
      case "Dinner":
        return "Dinner";
      default:
        return uiMealName;
    }
  }

  void _toggleDeleteMode(String mealName) {
    setState(() {
      deleteMode[mealName] = !(deleteMode[mealName] ?? false);
      if (!deleteMode[mealName]!) {
        selectedItemsForDeletion.removeWhere((key) => key.startsWith('${mealName}_'));
      }
    });
  }

  void _toggleItemSelection(String mealName, AddedMealItem item) {
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
      final apiMealName = _mapMealNameForAPI(mealName);

      print('=== DELETING FOOD ITEMS ===');
      print('User ID: ${widget.userId}');
      print('Day: $currentDay');
      print('UI Meal Name: $mealName');
      print('API Meal Name: $apiMealName');
      print('Item IDs: $selectedItems');

      await ref.read(DiProviders.bodyIqControllerProvider.notifier)
          .deleteFoodItemsFromMeal(
            userId: widget.userId,
            day: currentDay,
            meal: apiMealName,
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
        
        print('=== ERROR DELETING FOOD ITEMS ===');
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

  void _showMealTimePicker(String mealName) async {
    final TextEditingController timeController = TextEditingController();
    String selectedPeriod = 'AM';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Set $mealName Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule, color: Colors.indigo[900]),
                  const SizedBox(width: 8),
                  Text('Enter time for $mealName'),
                ],
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: timeController,
                      decoration: InputDecoration(
                        hintText: '12:00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedPeriod,
                          isExpanded: true,
                          items: ['AM', 'PM'].map((String period) {
                            return DropdownMenuItem<String>(
                              value: period,
                              child: Text(
                                period,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setDialogState(() {
                                selectedPeriod = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              Text(
                'Format: 12:00, 1:30, 11:45',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900]!,
              ),
              child: const Text('Save Time', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final timeText = timeController.text.trim();
                if (timeText.isNotEmpty) {
                  Navigator.pop(context);
                  await _saveManualTimeToAPI(mealName, timeText, selectedPeriod);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a time'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ✅ UPDATED: Save time and reschedule notifications
  Future<void> _saveManualTimeToAPI(String mealName, String timeText, String period) async {
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
      final formattedTime = '$timeText $period';
      final apiMealName = _mapMealNameForAPI(mealName);

      print('=== SAVING MANUAL MEAL TIME ===');
      print('User ID: ${widget.userId}');
      print('Day: $currentDay');
      print('UI Meal Name: $mealName');
      print('API Meal Name: $apiMealName');
      print('Time: $formattedTime');

      await ref.read(DiProviders.bodyIqControllerProvider.notifier)
          .saveSingleMealTime(
            userId: widget.userId,
            day: currentDay,
            meal: apiMealName,
            time: formattedTime,
          );

      // ✅ NEW: Reschedule notification if reminder is enabled
      if (mealReminderStates[mealName] == true) {
        await _scheduleMealNotification(mealName);
      }

      if (mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$mealName time ($formattedTime) saved successfully for $currentDay'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        
        print('=== ERROR SAVING MANUAL MEAL TIME ===');
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

  @override
  Widget build(BuildContext context) {
    final bodyIqState = ref.watch(DiProviders.bodyIqControllerProvider);
    final bodyIqController = ref.read(DiProviders.bodyIqControllerProvider.notifier);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: bodyIqState.isDietLoading || isLoadingUserItems
          ? _buildLoadingWidget()
          : bodyIqState.dietError != null
              ? _buildErrorWidget(bodyIqState.dietError!)
              : bodyIqState.dailyMealData != null
                  ? _buildContent(bodyIqState.dailyMealData!, bodyIqController)
                  : _buildEmptyState(),
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
        "Personalized Diet Plan",
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
          onPressed: () => _loadMealData(),
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
            isLoadingUserItems 
                ? "Loading your meal data..."
                : "Loading personalized meal plan...",
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 20),
            const Text('Error loading meal plan'),
            const SizedBox(height: 10),
            Text(error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _loadMealData(),
              child: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No meal data available'));
  }

  Widget _buildContent(DailyMealData mealData, bodyIqController) {
    return RefreshIndicator(
      onRefresh: () async => _loadMealData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildCalorieTrackingCard(mealData),
              const SizedBox(height: 16),
              _buildInstructionText(),
              const SizedBox(height: 20),
              _buildMealSection(
                mealName: "Breakfast",
                recommendations: mealData.mealRecommendations['Breakfast'],
                selectedItems: userAddedItems['Breakfast'] ?? [],
                bodyIqController: bodyIqController,
              ),
              const SizedBox(height: 16),
              _buildMealSection(
                mealName: "Lunch",
                recommendations: mealData.mealRecommendations['Lunch'],
                selectedItems: userAddedItems['Lunch'] ?? [],
                bodyIqController: bodyIqController,
              ),
              const SizedBox(height: 16),
              _buildMealSection(
                mealName: "Snack",
                recommendations: mealData.mealRecommendations['Snack'],
                selectedItems: userAddedItems['Snack'] ?? [],
                bodyIqController: bodyIqController,
              ),
              const SizedBox(height: 16),
              _buildMealSection(
                mealName: "Dinner",
                recommendations: mealData.mealRecommendations['Dinner'],
                selectedItems: userAddedItems['Dinner'] ?? [],
                bodyIqController: bodyIqController,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalorieTrackingCard(DailyMealData data) {
    final targetCalories = data.totalTargetCalories;
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
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Target",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Consumed",
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
              color: Colors.grey[200],
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
        ],
      ),
    );
  }

  double _calculateTotalConsumedCalories() {
    double total = 0;
    userAddedItems.forEach((meal, items) {
      for (var item in items) {
        total += double.tryParse(item.calories) ?? 0;
      }
    });
    return total;
  }

  Widget _buildInstructionText() {
    return Container(
      width: double.infinity,
      child: Text(
        "Please tap on the meal card to view the added items",
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildMealSection({
    required String mealName,
    required MealRecommendationsResponse? recommendations,
    required List<AddedMealItem> selectedItems,
    required bodyIqController,
  }) {
    final targetCalories = recommendations?.targetCalories ?? 0;
    final selectedCalories = selectedItems.fold(0.0, (sum, item) => sum + (double.tryParse(item.calories) ?? 0));
    final isExpanded = expandedMeals[mealName] ?? false;
    final isDeleteMode = deleteMode[mealName] ?? false;
    final selectedCount = selectedItemsForDeletion.where((key) => key.startsWith('${mealName}_')).length;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: selectedItems.isNotEmpty ? () {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mealName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Target: ${targetCalories}Kcal • Added: ${selectedCalories.toInt()}Kcal",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.schedule, color: Colors.grey, size: 20),
                              onPressed: () => _showMealTimePicker(mealName),
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // ✅ NEW: Reminder toggle button
                          Container(
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
                              icon: Icon(
                                (mealReminderStates[mealName] ?? false) 
                                  ? Icons.notifications_active 
                                  : Icons.notifications_none,
                                color: (mealReminderStates[mealName] ?? false) 
                                  ? Colors.orange 
                                  : Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => _toggleMealReminder(mealName),
                              tooltip: (mealReminderStates[mealName] ?? false) 
                                ? 'Disable $mealName reminder' 
                                : 'Enable $mealName reminder',
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[400]!),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.add, color: Colors.black, size: 20),
                              onPressed: () => _showFoodRecommendations(mealName, recommendations, bodyIqController),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  if (selectedItems.isNotEmpty) ...[
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
                              "${selectedItems.length} item${selectedItems.length > 1 ? 's' : ''} added • Tap to ${isExpanded ? 'collapse' : 'expand'}",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.green[700],
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          if (selectedItems.isNotEmpty && isExpanded) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDeleteMode ? Colors.red[25] : Colors.green[25],
                      border: Border(
                        bottom: BorderSide(color: isDeleteMode ? Colors.red[100]! : Colors.green[100]!),
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
    );
  }

  Widget _buildExpandedFoodItem(AddedMealItem item, String mealName, bool isDeleteMode) {
    final itemKey = '${mealName}_${item.itemId}';
    final isSelectedForDeletion = selectedItemsForDeletion.contains(itemKey);

    return GestureDetector(
      onTap: isDeleteMode ? () => _toggleItemSelection(mealName, item) : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDeleteMode 
              ? (isSelectedForDeletion ? Colors.red[50] : Colors.grey[50])
              : Colors.green[25],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDeleteMode 
                ? (isSelectedForDeletion ? Colors.red[200]! : Colors.grey[200]!)
                : Colors.green[100]!,
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
                    : Colors.green[700],
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
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${item.quantity} | ${item.calories}Kcal",
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
                "${item.calories}",
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

  void _showFoodRecommendations(
      String mealName,
      MealRecommendationsResponse? recommendations,
      bodyIqController,
    ) async {
    if (recommendations == null || recommendations.items.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('No Recommendations'),
          content: Text(
            'No recommendations available for $mealName as you already have items in the gym section.',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );

      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSelectionScreen(
          mealName: mealName,
          userId: widget.userId,
          initialFoodType: widget.foodType,
          onItemAdded: (item) {},
          doshaResult: widget.doshaResult,
        ),
      ),
    );

    _loadMealData();
  }
}
