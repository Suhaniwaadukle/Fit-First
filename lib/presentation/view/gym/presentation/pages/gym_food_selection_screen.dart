import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/gym/data/models/gym_food_models.dart';
import 'package:orka_sports/presentation/view/gym/data/models/meal_plan_model.dart';

class GymFoodSelectionScreen extends ConsumerStatefulWidget {
  final String mealName;
  final String userId;
  final int initialFoodType;
  final Function(GymFoodRecommendation) onItemAdded;

  const GymFoodSelectionScreen({
    super.key,
    required this.mealName,
    required this.userId,
    required this.initialFoodType,
    required this.onItemAdded,
  });

  @override
  ConsumerState<GymFoodSelectionScreen> createState() => _GymFoodSelectionScreenState();
}

class _GymFoodSelectionScreenState extends ConsumerState<GymFoodSelectionScreen> {
  List<GymFoodRecommendation> selectedItems = [];
  String selectedFilter = "All"; // ✅ ALWAYS START WITH "ALL"
  String selectedDay = _getCurrentDay();
  bool isLoading = false;
  GymMealRecommendationsResponse? recommendations;
  
  // ✅ NEW: Meal plan data from API
  MealPlanResponse? mealPlanData;
  bool isLoadingMealPlan = false;
  String? mealPlanError;

  // ✅ FIXED: Always default to 0 (All)
  int selectedFoodType = 0; // Always start with "All"
  Map<String, int> foodTypeMapping = {
    'All': 0,
    'Veg': 1,
    'Non-Veg': 2,
    'Vegan': 3,
  };

  // ✅ NEW: NUTRITIONAL FILTERING TOGGLE
  bool enableNutritionalFiltering = true;
  
  // ✅ NEW: Collapsible state for targets
  bool showTargets = false;

  static String _getCurrentDay() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[now.weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    // ✅ FIXED: Always force default to "All" regardless of initialFoodType
    selectedFoodType = 0; // Force to "All"
    selectedFilter = "All"; // Force to "All"
    _setInitialFilterFromFoodType();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadMealPlanData();
        _loadGymFoodRecommendations();
      }
    });
  }

  // ✅ NEW: Load meal plan data from API
  Future<void> _loadMealPlanData() async {
    setState(() {
      isLoadingMealPlan = true;
      mealPlanError = null;
    });

    try {
      print('=== LOADING MEAL PLAN DATA ===');
      print('User ID: ${widget.userId}');

      final response = await ref.read(DiProviders.gymControllerProvider.notifier)
          .generateMealPlanByCalories(userId: widget.userId);

      if (mounted) {
        setState(() {
          mealPlanData = response;
          isLoadingMealPlan = false;
        });

        print('=== MEAL PLAN LOADED ===');
        print('Total Calorie Target: ${response.calorieTarget}');
        print('Meals: ${response.data.length}');
      }
    } catch (e) {
      print('=== ERROR LOADING MEAL PLAN ===');
      print('Error: $e');
      
      if (mounted) {
        setState(() {
          mealPlanError = e.toString().replaceAll('Exception: ', '');
          isLoadingMealPlan = false;
        });
      }
    }
  }

  void _setInitialFilterFromFoodType() {
    // ✅ FIXED: Always default to "All" regardless of initial food type
    selectedFilter = "All";
    selectedFoodType = 0;
    
    print('=== FORCING GYM DEFAULT TO ALL ===');
    print('Initial Food Type Passed: ${widget.initialFoodType}');
    print('Forced Selected Filter: $selectedFilter');
    print('Forced Selected Food Type: $selectedFoodType');
    
    // Optional: Keep the original logic commented out if you want to revert later
    /*
    switch (widget.initialFoodType) {
      case 1:
        selectedFilter = "Veg";
        break;
      case 2:
        selectedFilter = "Non-Veg";
        break;
      case 3:
        selectedFilter = "Vegan";
        break;
      default:
        selectedFilter = "All";
    }
    */
  }

  Future<void> _loadGymFoodRecommendations() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      print('=== LOADING GYM FOOD RECOMMENDATIONS ===');
      print('User ID: ${widget.userId}');
      print('Meal Name: ${widget.mealName}');
      print('Selected Food Type: $selectedFoodType (${_getFoodTypeLabel(selectedFoodType)})');
      print('Selected Filter: $selectedFilter');
      
      final response = await ref.read(DiProviders.gymControllerProvider.notifier)
          .getGymFoodItemsByMeal(
            userId: widget.userId,
            meal: widget.mealName,
            foodType: selectedFoodType,
          );

      print('=== RECEIVED RESPONSE ===');
      print('Status: ${response.status}');
      print('Meal: ${response.meal}');
      print('Target Calories: ${response.targetCalories}');
      print('Items Count: ${response.items.length}');

      if (mounted) {
        setState(() {
          recommendations = response;
          isLoading = false;
        });
      }
    } catch (e) {
      print('=== ERROR LOADING RECOMMENDATIONS ===');
      print('Error: $e');
      
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading food items: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  // ✅ NEW: Get meal-specific targets from API data
  MealPlan? _getCurrentMealPlan() {
    if (mealPlanData == null) return null;
    
    final currentMealLower = widget.mealName.toLowerCase();
    
    return mealPlanData!.data.firstWhere(
      (meal) => meal.meal.toLowerCase() == currentMealLower,
      orElse: () => mealPlanData!.data.first,
    );
  }

  String _getFoodTypeLabel(int foodType) {
    switch (foodType) {
      case 0: return 'All Types';
      case 1: return 'Vegetarian';
      case 2: return 'Non-Vegetarian';
      case 3: return 'Vegan';
      default: return 'All Types';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
      child: (isLoading || isLoadingMealPlan)
          ? _buildLoadingWidget()
          : (recommendations == null || mealPlanData == null)
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildCompactControlsBar(), // ✅ Food type + Smart filter only
                    _buildNutritionalInfoBanner(), // ✅ Nutritional targets
                    _buildDayPickerSection(), // ✅ NEW: Day picker below nutritional info
                    Expanded(child: _buildFoodList()), // ✅ Maximized list space
                    if (selectedItems.isNotEmpty) _buildCompactBottomActionBar(), // ✅ Compact bottom bar
                  ],
                ),
    ),
    );
  }

  // ✅ UPDATED: COMPACT CONTROLS BAR - Fixed dropdown logic
  Widget _buildCompactControlsBar() {
    final foodTypes = ['All', 'Veg', 'Non-Veg', 'Vegan'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Food type dropdown (compact)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.indigo[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.indigo[200]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                isDense: true,
                items: foodTypes.map((f) {
                  return DropdownMenuItem<String>(
                    value: f,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildFoodTypeIcon(f, false),
                        const SizedBox(width: 6),
                        Text(
                          f,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.indigo[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  setState(() {
                    selectedFilter = val;
                    selectedFoodType = foodTypeMapping[val] ?? 0; // ✅ FIXED: Default to 0 (All)
                  });
                  _loadGymFoodRecommendations(); // ✅ FIXED: Always reload when filter changes
                },
              ),
            ),
          ),
          
          const Spacer(), // ✅ Use spacer to push filter toggle to the right

          // ✅ FIXED: Smart filter toggle with shorter text to prevent overflow
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Smart Nutrition Filter",  // ✅ Shortened text to prevent overflow
                style: TextStyle(
                  fontSize: 11,  // ✅ Slightly smaller font size
                  color: Colors.indigo[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6), // ✅ Reduced spacing
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: enableNutritionalFiltering,
                  onChanged: (v) => setState(() => enableNutritionalFiltering = v),
                  activeColor: Colors.indigo[700],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 2), // ✅ Small spacing between switch and icon
              Icon(Icons.filter_alt, color: Colors.indigo[700], size: 14), // ✅ Slightly smaller icon
            ],
          ),
        ],
      ),
    );
  }

  // ✅ NEW: COMPACT NUTRITIONAL INFO BANNER - Collapsible, takes minimal space
  Widget _buildNutritionalInfoBanner() {
    final currentMeal = _getCurrentMealPlan();
    final pct = currentMeal?.percentage ?? 0;
    final kcal = currentMeal?.calories ?? 0;
    final p = currentMeal?.protein ?? 0;
    final c = currentMeal?.carbs ?? 0;
    final f = currentMeal?.fats ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => showTargets = !showTargets),
            child: Row(
              children: [
                Icon(Icons.track_changes, color: Colors.green[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Targets: $pct% • $kcal kcal • Selected: ${selectedItems.length}",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.green[700],
                    ),
                  ),
                ),
                Text(
                  showTargets ? "Hide" : "Details",
                  style: TextStyle(fontSize: 11, color: Colors.green[600]),
                ),
                Icon(
                  showTargets ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.green[700],
                  size: 16,
                ),
              ],
            ),
          ),
          if (showTargets) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _miniTarget(Icons.fitness_center, Colors.indigo[900]!, "$p g Protein")),
                Expanded(child: _miniTarget(Icons.grass, Colors.green, "$c g Carbs")),
                Expanded(child: _miniTarget(Icons.opacity, Colors.red, "$f g Fat")),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Remaining: ${_getRemainingCalories()} kcal",
                    style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Text(
                    "P ${_getRemainingProtein()} | C ${_getRemainingCarbs()} | F ${_getRemainingFat()}",
                    textAlign: TextAlign.end,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ✅ NEW: DAY PICKER BELOW NUTRITIONAL INFO
  Widget _buildDayPickerSection() {
    final days = [
      {'key': 'Monday', 'label': 'Mon'},
      {'key': 'Tuesday', 'label': 'Tue'},
      {'key': 'Wednesday', 'label': 'Wed'},
      {'key': 'Thursday', 'label': 'Thu'},
      {'key': 'Friday', 'label': 'Fri'},
      {'key': 'Saturday', 'label': 'Sat'},
      {'key': 'Sunday', 'label': 'Sun'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.indigo[700], size: 16),
              const SizedBox(width: 8),
              Text(
                "Select Day:",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.indigo[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getDayAbbreviation(selectedDay),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[700],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: days.map((day) {
                final isSelected = selectedDay == day['key'];
                final isToday = day['key'] == _getCurrentDay();
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day['key']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.indigo[900]! : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected 
                              ? Colors.indigo[900]! 
                              : isToday 
                                  ? Colors.indigo[300]! 
                                  : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            day['label']!,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isToday && !isSelected) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.indigo[600],
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniTarget(IconData icon, Color color, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
        ),
      ],
    );
  }

  Widget _buildFoodTypeIcon(String foodType, bool isSelected) {
    IconData icon;
    Color color = isSelected ? Colors.white : Colors.grey[600]!;

    switch (foodType) {
      case 'Veg':
        icon = Icons.eco;
        color = isSelected ? Colors.white : Colors.green;
        break;
      case 'Non-Veg':
        icon = Icons.restaurant;
        color = isSelected ? Colors.white : Colors.red;
        break;
      case 'Vegan':
        icon = Icons.local_florist;
        color = isSelected ? Colors.white : Colors.orange;
        break;
      default:
        icon = Icons.restaurant_menu;
    }

    return Icon(icon, size: 14, color: color);
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.kPrimaryColor),
          const SizedBox(height: 20),
          Text(
            isLoadingMealPlan 
                ? "Loading your personalized meal plan..."
                : "Loading gym food recommendations...",
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 20),
          Text(
            mealPlanError != null 
                ? 'Failed to load meal plan'
                : 'Failed to load food recommendations',
          ),
          if (mealPlanError != null) ...[
            const SizedBox(height: 8),
            Text(
              mealPlanError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _loadMealPlanData();
              _loadGymFoodRecommendations();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
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
      title: Text(
        "Select ${widget.mealName} Food",
        style: const TextStyle(
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
            _loadMealPlanData();
            _loadGymFoodRecommendations();
          },
        ),
      ],
    );
  }

  bool _isVegetarian(String itemName) {
    final vegKeywords = ['paneer', 'tofu', 'dal', 'milk', 'curd', 'yogurt', 'rice', 'roti', 'oats', 'quinoa'];
    final nonVegKeywords = ['chicken', 'fish', 'mutton', 'beef', 'lamb', 'meat', 'egg'];
    
    String lowerName = itemName.toLowerCase();
    
    if (nonVegKeywords.any((keyword) => lowerName.contains(keyword))) {
      return false;
    }
    
    return vegKeywords.any((keyword) => lowerName.contains(keyword)) ||
           !nonVegKeywords.any((keyword) => lowerName.contains(keyword));
  }

  bool _isVegan(String itemName) {
    final nonVeganKeywords = ['chicken', 'fish', 'mutton', 'beef', 'lamb', 'meat', 'egg', 'ghee', 'butter', 'cheese', 'milk', 'curd', 'yogurt'];
    String lowerName = itemName.toLowerCase();
    return !nonVeganKeywords.any((keyword) => lowerName.contains(keyword));
  }

Widget _buildFoodList() {
  if (recommendations == null) return const SizedBox();
  
  List<GymFoodRecommendation> filteredItems = _getFilteredItems();

  return Column(
    children: [
      // Compact info text
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          enableNutritionalFiltering 
              ? "Items exceeding targets are hidden. Tap checkbox to select items."
              : "Tap checkbox to select items from ${filteredItems.length} available options.",
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ),
      // ✅ OPTIMIZED: ListView with performance improvements
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredItems.length,
          cacheExtent: 1000,              // ✅ Cache 1000px of items off-screen
          addAutomaticKeepAlives: false,  // ✅ Don't keep items alive when scrolled away
          addRepaintBoundaries: false,    // ✅ Reduce unnecessary repaints
          physics: const BouncingScrollPhysics(), // ✅ Smoother scrolling
          itemBuilder: (context, index) {
            final item = filteredItems[index];
            final isSelected = selectedItems.contains(item);
            
            // ✅ Wrap each item in RepaintBoundary for better performance
            return RepaintBoundary(
              child: _buildFoodItem(item, isSelected),
            );
          },
        ),
      ),
    ],
  );
}


  // ✅ FIXED: Updated filtering logic
  List<GymFoodRecommendation> _getFilteredItems() {
    if (recommendations == null) return [];
    
    List<GymFoodRecommendation> items = recommendations!.items; // ✅ Start with all items
    
    // ✅ Only apply client-side filtering if not "All"
    if (selectedFilter != "All") {
      items = items.where((item) {
        switch (selectedFilter) {
          case "Veg":
            return _isVegetarian(item.itemName);
          case "Non-Veg":
            return !_isVegetarian(item.itemName);
          case "Vegan":
            return _isVegan(item.itemName);
          default:
            return true; // Show all items for unknown filter
        }
      }).toList();
    }
    
    // Apply nutritional filtering if enabled
    if (enableNutritionalFiltering) {
      items = _applyNutritionalFiltering(items);
    }
    
    print('=== GYM FILTERING RESULTS ===');
    print('Selected Filter: $selectedFilter');
    print('Selected Food Type: $selectedFoodType');
    print('Total Items from API: ${recommendations!.items.length}');
    print('After Filter Applied: ${items.length}');
    
    return items;
  }

List<GymFoodRecommendation> _applyNutritionalFiltering(List<GymFoodRecommendation> items) {
  final currentMeal = _getCurrentMealPlan();
  if (currentMeal == null) return items;

  // Get remaining macros (what's left to consume)
  final remainingProtein = double.tryParse(_getRemainingProtein()) ?? 0.0;
  final remainingCarbs = double.tryParse(_getRemainingCarbs()) ?? 0.0;
  final remainingFat = double.tryParse(_getRemainingFat()) ?? 0.0;
  final remainingCalories = double.tryParse(_getRemainingCalories()) ?? 0.0;

  print('=== NUTRITIONAL FILTERING DEBUG ===');
  print('Smart Filter Enabled: $enableNutritionalFiltering');
  print('Remaining - P:$remainingProtein C:$remainingCarbs F:$remainingFat Cal:$remainingCalories');

  final filteredItems = items.where((item) {
    // ✅ ALWAYS show selected items, regardless of filtering
    if (selectedItems.contains(item)) {
      print('✅ KEEPING (selected): ${item.itemName}');
      return true;
    }
    
    try {
      final itemProtein = double.parse(item.protein);
      final itemCarbs = double.parse(item.carbs);
      final itemFat = double.parse(item.fats);
      final itemCalories = item.calories.toDouble();

      // ✅ FIXED: Direct comparison - if ANY macro exceeds remaining, exclude
      final proteinExceeds = itemProtein > remainingProtein;
      final carbsExceeds = itemCarbs > remainingCarbs;
      final fatExceeds = itemFat > remainingFat;
      final caloriesExceeds = itemCalories > remainingCalories;

      final shouldExclude = proteinExceeds || carbsExceeds || fatExceeds || caloriesExceeds;

      if (shouldExclude) {
        print('❌ EXCLUDING: ${item.itemName}');
        print('   Item - P:$itemProtein C:$itemCarbs F:$itemFat Cal:$itemCalories');
        print('   Remaining - P:$remainingProtein C:$remainingCarbs F:$remainingFat Cal:$remainingCalories');
        if (proteinExceeds) print('   → Protein exceeds: $itemProtein > $remainingProtein');
        if (carbsExceeds) print('   → Carbs exceeds: $itemCarbs > $remainingCarbs');
        if (fatExceeds) print('   → Fat exceeds: $itemFat > $remainingFat');
        if (caloriesExceeds) print('   → Calories exceeds: $itemCalories > $remainingCalories');
        return false; // Exclude this item
      } else {
        print('✅ INCLUDING: ${item.itemName} (within limits)');
        return true; // Include this item
      }

    } catch (e) {
      print('⚠️  Error parsing nutrition for ${item.itemName}: $e');
      return true; // Show item if parsing fails
    }
  }).toList();

  print('✅ FILTERING COMPLETE: ${items.length} → ${filteredItems.length} items (${items.length - filteredItems.length} hidden)');
  return filteredItems;
}


Widget _buildFoodItem(GymFoodRecommendation item, bool isSelected) {
  bool exceedsTargets = false;
  if (enableNutritionalFiltering) {
    try {
      final remainingProtein = double.tryParse(_getRemainingProtein()) ?? 0.0;
      final itemProtein = double.parse(item.protein);
      exceedsTargets = remainingProtein > 0 && itemProtein > remainingProtein;
    } catch (e) {
      // Ignore parsing errors
    }
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isSelected 
            ? Colors.indigo[900]! 
            : exceedsTargets 
                ? Colors.orange! 
                : Colors.grey!,
        width: isSelected ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        // ✅ OPTIMIZED: Image with caching
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.image.isNotEmpty 
                ? CachedNetworkImage(
                    imageUrl: item.image,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    memCacheWidth: 80,  // ✅ Resize in memory to save RAM
                    memCacheHeight: 80, // ✅ Resize in memory to save RAM
                    placeholder: (_, __) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[100],
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.indigo[900]!,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: Colors.grey[100],
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.indigo!,
                        size: 20,
                      ),
                    ),
                  )
                : Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey[100],
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.indigo!,
                      size: 20,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.itemName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (exceedsTargets) ...[
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange[600],
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                "${item.quantity} | ${item.calories}kcal",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildNutritionalTag("P: ${item.protein}", Colors.green),
                  const SizedBox(width: 3),
                  _buildNutritionalTag("C: ${item.carbs}", Colors.orange),
                  const SizedBox(width: 3),
                  _buildNutritionalTag("F: ${item.fats}", Colors.red),
                ],
              ),
            ],
          ),
        ),
        
        GestureDetector(
          onTap: () => _toggleSelection(item),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: isSelected ? Colors.indigo[900]! : Colors.transparent,
              border: Border.all(
                color: isSelected ? Colors.indigo! : Colors.grey!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  )
                : null,
          ),
        ),
      ],
    ),
  );
}



  Widget _buildNutritionalTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), // ✅ Smaller padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9, // ✅ Smaller text
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  // ✅ NEW: COMPACT BOTTOM ACTION BAR - Smaller height
  Widget _buildCompactBottomActionBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12), // ✅ Reduced padding
        child: SizedBox(
          width: double.infinity,
          height: 42, // ✅ Reduced height
          child: ElevatedButton(
            onPressed: selectedItems.isEmpty ? null : _addSelectedItems,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[900]!,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              "Add ${selectedItems.length} Item${selectedItems.length > 1 ? 's' : ''} to ${widget.mealName} (${_getDayAbbreviation(selectedDay)})",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14, // ✅ Slightly smaller text
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

void _toggleSelection(GymFoodRecommendation item) {
  // Check if trying to add item (not removing)
  if (!selectedItems.contains(item)) {
    // Check if adding this item would exceed any nutritional targets
    if (_wouldExceedTargets(item)) {
      // Show a snackbar explaining why the item can't be selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add "${item.itemName}" - it would exceed your nutritional targets for this meal'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return; // Don't allow selection
    }
  }

  setState(() {
    if (selectedItems.contains(item)) {
      selectedItems.remove(item);
    } else {
      selectedItems.add(item);
    }
  });
}
bool _wouldExceedTargets(GymFoodRecommendation item) {
  final currentMeal = _getCurrentMealPlan();
  if (currentMeal == null) return false;

  try {
    // Calculate what the totals would be if we add this item
    final currentCalories = selectedItems.fold<int>(0, (sum, item) => sum + item.calories);
    final currentProtein = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.protein));
    final currentCarbs = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.carbs));
    final currentFat = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.fats));

    // Add the new item's values
    final newCalories = currentCalories + item.calories;
    final newProtein = currentProtein + double.parse(item.protein);
    final newCarbs = currentCarbs + double.parse(item.carbs);
    final newFat = currentFat + double.parse(item.fats);

    // Check if any target would be exceeded
    final targetCalories = currentMeal.calories;
    final targetProtein = currentMeal.protein.toDouble();
    final targetCarbs = currentMeal.carbs.toDouble();
    final targetFat = currentMeal.fats.toDouble();

    return newCalories > targetCalories ||
           newProtein > targetProtein ||
           newCarbs > targetCarbs ||
           newFat > targetFat;
  } catch (e) {
    return false; // If parsing fails, allow selection
  }
}


void _addSelectedItems() async {
  if (selectedItems.isEmpty) return;

  try {
    // ✅ SHOW LOADING DIALOG
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Colors.indigo[900]!,
        ),
      ),
    );

    print('=== SENDING GYM FOOD TO API ===');
    print('Selected Day: $selectedDay');
    print('Meal: ${widget.mealName}');
    print('Items: ${selectedItems.length}');

    // ✅ CALL GYM CONTROLLER METHOD (WHICH HANDLES CONFIRMATION DIALOG INTERNALLY)
    await ref.read(DiProviders.gymControllerProvider.notifier)
        .addSelectedGymFoodToMeal(
          context: context,
          userId: widget.userId,
          meal: widget.mealName,
          selectedItems: selectedItems,
          day: selectedDay,
        );

    // ✅ SUCCESS: POP LOADING DIALOG AND NAVIGATE AWAY
    if (mounted) {
      Navigator.pop(context); // Pop loading dialog
      Navigator.pop(context); // Pop screen
    }

  } catch (e) {
    // ✅ ERROR: ONLY POP LOADING DIALOG, STAY ON SCREEN
    if (mounted) {
      Navigator.pop(context); // Pop loading dialog only
      
      // ✅ SHOW ERROR MESSAGE
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add items: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}


  String _getDayAbbreviation(String fullDay) {
    switch (fullDay) {
      case 'Monday': return 'MON';
      case 'Tuesday': return 'TUE';
      case 'Wednesday': return 'WED';
      case 'Thursday': return 'THU';
      case 'Friday': return 'FRI';
      case 'Saturday': return 'SAT';
      case 'Sunday': return 'SUN';
      default: return fullDay.substring(0, 3).toUpperCase();
    }
  }

  String _getRemainingCalories() {
    final currentMeal = _getCurrentMealPlan();
    if (currentMeal == null) return "0";
    
    final targetCalories = currentMeal.calories;
    final consumedCalories = selectedItems.fold<int>(0, (sum, item) => sum + item.calories);
    return (targetCalories - consumedCalories).toString();
  }

  String _getRemainingProtein() {
    final currentMeal = _getCurrentMealPlan();
    if (currentMeal == null) return "0.0";
    
    final targetProtein = currentMeal.protein.toDouble();
    final consumedProtein = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.protein));
    return (targetProtein - consumedProtein).toStringAsFixed(1);
  }

  String _getRemainingCarbs() {
    final currentMeal = _getCurrentMealPlan();
    if (currentMeal == null) return "0.0";
    
    final targetCarbs = currentMeal.carbs.toDouble();
    final consumedCarbs = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.carbs));
    return (targetCarbs - consumedCarbs).toStringAsFixed(1);
  }

  String _getRemainingFat() {
    final currentMeal = _getCurrentMealPlan();
    if (currentMeal == null) return "0.0";
    
    final targetFat = currentMeal.fats.toDouble();
    final consumedFat = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.fats));
    return (targetFat - consumedFat).toStringAsFixed(1);
  }
}
