import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/services/di_services.dart';
import 'package:orka_sports/presentation/view/body_iq/data/models/diet_models/meal_recommendations_model.dart';

class FoodSelectionScreen extends ConsumerStatefulWidget {
  final String mealName;
  final String userId;
  final int initialFoodType;
  final Function(FoodRecommendation) onItemAdded;
  final String doshaResult; // ✅ REQUIRED - always available from parent

  const FoodSelectionScreen({
    super.key,
    required this.mealName,
    required this.userId,
    required this.initialFoodType,
    required this.onItemAdded,
    required this.doshaResult, // ✅ Required parameter
  });

  @override
  ConsumerState<FoodSelectionScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends ConsumerState<FoodSelectionScreen> {
  List<FoodRecommendation> selectedItems = [];
  String selectedFilter = "All"; // Always start with "All"
  String selectedDay = _getCurrentDay();
  bool isLoading = false;
  MealRecommendationsResponse? recommendations;
  
  // Fixed: Always default to 0 (All)
  int selectedFoodType = 0;
  Map<String, int> foodTypeMapping = {
    'All': 0,
    'Veg': 1,
    'Non-Veg': 2,
    'Vegan': 3,
  };

  // Nutritional filtering toggle
  bool enableNutritionalFiltering = true;
  
  // Collapsible state for targets
  bool showTargets = false;

  static String _getCurrentDay() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[now.weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    // Always force default to "All"
    selectedFoodType = 0;
    selectedFilter = "All";
    _setInitialFilterFromFoodType();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadFoodRecommendations();
      }
    });
  }

  // ✅ SIMPLE: Direct dosha-based macro ratios
  Map<String, double> _getMacroRatios() {
    switch (widget.doshaResult.toLowerCase()) {
      case 'kapha': // Fat Loss
        return {'protein': 0.40, 'carbs': 0.30, 'fats': 0.30};
      case 'pitta': // Maintenance
        return {'protein': 0.30, 'carbs': 0.40, 'fats': 0.30};
      case 'vata': // Muscle Gain
        return {'protein': 0.30, 'carbs': 0.50, 'fats': 0.20};
      default: // Default to maintenance if unknown dosha
        return {'protein': 0.30, 'carbs': 0.40, 'fats': 0.30};
    }
  }

  // ✅ Calculate target macros using correct formula
  Map<String, int> _getTargetMacros() {
    final targetCalories = recommendations?.targetCalories ?? 0;
    final macroRatios = _getMacroRatios();
    
    return {
      'protein': ((targetCalories * macroRatios['protein']!) / 4).round(), // 1g protein = 4 kcal
      'carbs': ((targetCalories * macroRatios['carbs']!) / 4).round(),     // 1g carbs = 4 kcal
      'fats': ((targetCalories * macroRatios['fats']!) / 9).round(),       // 1g fats = 9 kcal
    };
  }

  void _setInitialFilterFromFoodType() {
    // Always default to "All"
    selectedFilter = "All";
    selectedFoodType = 0;
    
    print('=== FORCING DEFAULT TO ALL ===');
    print('Initial Food Type Passed: ${widget.initialFoodType}');
    print('Forced Selected Filter: $selectedFilter');
    print('Forced Selected Food Type: $selectedFoodType');
    print('User Dosha: ${widget.doshaResult}');
  }

  Future<void> _loadFoodRecommendations() async {
    if (!mounted) return;
    
    setState(() {
      isLoading = true;
    });

    try {
      print('=== LOADING FOOD RECOMMENDATIONS ===');
      print('User ID: ${widget.userId}');
      print('Meal Name: ${widget.mealName}');
      print('Selected Food Type: $selectedFoodType (${_getFoodTypeLabel(selectedFoodType)})');
      print('Selected Filter: $selectedFilter');
      print('User Dosha: ${widget.doshaResult}');
      
      final response = await ref.read(DiProviders.bodyIqControllerProvider.notifier)
          .getFoodItemsByMealAndDosha(
            userId: widget.userId,
            meal: widget.mealName,
            foodType: selectedFoodType,
          );

      print('=== RECEIVED RESPONSE ===');
      print('Status: ${response.status}');
      print('Meal: ${response.meal}');
      print('Target Calories: ${response.targetCalories}');
      print('Items Count: ${response.items.length}');
      
      if (response.items.isNotEmpty) {
        print('=== FIRST 3 ITEMS ===');
        for (int i = 0; i < response.items.length && i < 3; i++) {
          print('${i + 1}. ${response.items[i].itemName}');
        }
      }

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
      child: isLoading
          ? _buildLoadingWidget()
          : recommendations == null
              ? _buildErrorWidget()
              : Column(
                  children: [
                    _buildCompactControlsBar(),
                    _buildNutritionalInfoBanner(),
                    _buildDayPickerSection(),
                    Expanded(child: _buildFoodList()),
                    if (selectedItems.isNotEmpty) _buildCompactBottomActionBar(),
                  ],
                ),
    ),
    );
  }

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
                    selectedFoodType = foodTypeMapping[val] ?? 0;
                  });
                  _loadFoodRecommendations();
                },
              ),
            ),
          ),
          
          const Spacer(),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Smart Nutrition Filter",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.indigo[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: enableNutritionalFiltering,
                  onChanged: (v) => setState(() => enableNutritionalFiltering = v),
                  activeColor: Colors.indigo[700],
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.filter_alt, color: Colors.indigo[700], size: 14),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Updated nutritional banner with dosha-based calculations (no goal labels)
  Widget _buildNutritionalInfoBanner() {
    final targetCalories = recommendations?.targetCalories ?? 0;
    final targetMacros = _getTargetMacros();
    final macroRatios = _getMacroRatios();

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
                    "Targets: $targetCalories kcal • Selected: ${selectedItems.length}",
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
            // ✅ Dynamic macro targets with percentages
            Row(
              children: [
                Expanded(
                  child: _miniTarget(
                    Icons.fitness_center,
                    Colors.indigo[900]!,
                    "${targetMacros['protein']}g Protein (${(macroRatios['protein']! * 100).round()}%)"
                  ),
                ),
                Expanded(
                  child: _miniTarget(
                    Icons.grass,
                    Colors.green,
                    "${targetMacros['carbs']}g Carbs (${(macroRatios['carbs']! * 100).round()}%)"
                  ),
                ),
                Expanded(
                  child: _miniTarget(
                    Icons.opacity,
                    Colors.red,
                    "${targetMacros['fats']}g Fat (${(macroRatios['fats']! * 100).round()}%)"
                  ),
                ),
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
        Icon(icon, color: color, size: 9),
        const SizedBox(width: 1),
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
          const Text("Loading food recommendations..."),
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
          const Text('Failed to load food recommendations'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _loadFoodRecommendations();
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
            _loadFoodRecommendations();
          },
        ),
      ],
    );
  }

Widget _buildFoodList() {
  if (recommendations == null) return const SizedBox();
  
  List<FoodRecommendation> filteredItems = _getFilteredItems();

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


  List<FoodRecommendation> _getFilteredItems() {
    if (recommendations == null) return [];
    
    List<FoodRecommendation> items = recommendations!.items;
    
    // Only apply client-side filtering if not "All"
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
            return true;
        }
      }).toList();
    }
    
    // Apply nutritional filtering if enabled
    if (enableNutritionalFiltering) {
      items = _applyNutritionalFiltering(items);
    }
    
    print('=== FILTERING RESULTS ===');
    print('Selected Filter: $selectedFilter');
    print('Selected Food Type: $selectedFoodType');
    print('User Dosha: ${widget.doshaResult}');
    print('Total Items from API: ${recommendations!.items.length}');
    print('After Filter Applied: ${items.length}');
    
    return items;
  }

List<FoodRecommendation> _applyNutritionalFiltering(List<FoodRecommendation> items) {
  final remainingProtein = double.tryParse(_getRemainingProtein()) ?? 0.0;
  final remainingCarbs = double.tryParse(_getRemainingCarbs()) ?? 0.0;
  final remainingFat = double.tryParse(_getRemainingFat()) ?? 0.0;
  final remainingCalories = double.tryParse(_getRemainingCalories()) ?? 0.0;

  print('=== NUTRITIONAL FILTERING DEBUG ===');
  print('Smart Filter Enabled: $enableNutritionalFiltering');
  print('Remaining - P:$remainingProtein C:$remainingCarbs F:$remainingFat Cal:$remainingCalories');

  return items.where((item) {
    // ✅ ALWAYS show selected items
    if (selectedItems.contains(item)) {
      print('✅ KEEPING (selected): ${item.itemName}');
      return true;
    }
    
    try {
      final itemProtein = double.parse(item.protein);
      final itemCarbs = double.parse(item.carbs);
      final itemFat = double.parse(item.fats);
      final itemCalories = item.calories.toDouble();

      // ✅ DIRECT COMPARISON - if ANY macro exceeds remaining, exclude
      final proteinExceeds = itemProtein > remainingProtein;
      final carbsExceeds = itemCarbs > remainingCarbs;
      final fatExceeds = itemFat > remainingFat;
      final caloriesExceeds = itemCalories > remainingCalories;

      final shouldExclude = proteinExceeds || carbsExceeds || fatExceeds || caloriesExceeds;

      if (shouldExclude) {
        print('❌ EXCLUDING: ${item.itemName}');
        if (proteinExceeds) print('   → Protein exceeds: $itemProtein > $remainingProtein');
        if (carbsExceeds) print('   → Carbs exceeds: $itemCarbs > $remainingCarbs');
        if (fatExceeds) print('   → Fat exceeds: $itemFat > $remainingFat');
        if (caloriesExceeds) print('   → Calories exceeds: $itemCalories > $remainingCalories');
        return false;
      } else {
        print('✅ INCLUDING: ${item.itemName}');
        return true;
      }

    } catch (e) {
      print('⚠️  Error parsing nutrition for ${item.itemName}: $e');
      return true;
    }
  }).toList();
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

Widget _buildFoodItem(FoodRecommendation item, bool isSelected) {
  bool exceedsTargets = false;
  if (enableNutritionalFiltering) {
    try {
      final remainingProtein = double.tryParse(_getRemainingProtein()) ?? 0.0;
      final itemProtein = double.tryParse(item.protein ?? '0') ?? 0.0; // ✅ SAFE
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
            ? const Color(0xFF1A237E) // ✅ SAFE: Direct color instead of Colors.indigo[900]!
            : exceedsTargets 
                ? const Color(0xFFFF9800) // ✅ SAFE: Direct orange color
                : const Color(0xFF9E9E9E), // ✅ SAFE: Direct grey color
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
        // ✅ SAFE: Container with cached image
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EAF6), // ✅ SAFE: Direct indigo[50] color
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: (item.image != null && 
                   item.image!.isNotEmpty && 
                   !item.image!.endsWith('/'))
                ? CachedNetworkImage(
                    imageUrl: item.image!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    memCacheWidth: 80,
                    memCacheHeight: 80,
                    placeholder: (_, __) => Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFFE8EAF6),
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF1A237E), // ✅ SAFE: Direct indigo[900]
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 40,
                      height: 40,
                      color: const Color(0xFFE8EAF6),
                      child: const Icon(
                        Icons.restaurant, 
                        color: Color(0xFF1A237E), // ✅ SAFE: Direct indigo[900]
                        size: 20,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.restaurant, 
                    color: Color(0xFF1A237E), // ✅ SAFE: Direct indigo[900]
                    size: 20,
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
                      item.itemName ?? 'Unknown Item', // ✅ SAFE: Default value
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                "${item.quantity ?? 'N/A'} | ${item.calories ?? 0}kcal", // ✅ SAFE: Default values
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF757575), // ✅ SAFE: Direct grey[600]
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _buildNutritionalTag("P: ${item.protein ?? '0'}", Colors.green), // ✅ SAFE
                  const SizedBox(width: 3),
                  _buildNutritionalTag("C: ${item.carbs ?? '0'}", Colors.orange),   // ✅ SAFE
                  const SizedBox(width: 3),
                  _buildNutritionalTag("F: ${item.fats ?? '0'}", Colors.red),       // ✅ SAFE
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
              color: isSelected ? const Color(0xFF1A237E) : Colors.transparent, // ✅ SAFE
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF1A237E)  // ✅ SAFE: Direct indigo[900]
                    : const Color(0xFFBDBDBD), // ✅ SAFE: Direct grey
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          height: 42,
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
bool _wouldExceedTargets(FoodRecommendation item) {
  const double tolerance = 0.5; // Allow small margin

  try {
    // Calculate current totals from selected items
    final currentProtein = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.protein));
    final currentCarbs = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.carbs));
    final currentFat = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.fats));

    // Parse the new item's values
    final itemProtein = double.parse(item.protein);
    final itemCarbs = double.parse(item.carbs);
    final itemFat = double.parse(item.fats);

    // Calculate what totals would be after adding this item
    final newProtein = currentProtein + itemProtein;
    final newCarbs = currentCarbs + itemCarbs;
    final newFat = currentFat + itemFat;

    // Get targets
    final targetMacros = _getTargetMacros();
    final targetProtein = targetMacros['protein']!.toDouble();
    final targetCarbs = targetMacros['carbs']!.toDouble();
    final targetFat = targetMacros['fats']!.toDouble();

    // ✅ DEBUG: Log the check
    print('=== EXCEED CHECK: ${item.itemName} ===');
    print('Current - P:$currentProtein C:$currentCarbs F:$currentFat');
    print('Item - P:$itemProtein C:$itemCarbs F:$itemFat');
    print('New Total - P:$newProtein C:$newCarbs F:$newFat');
    print('Targets - P:$targetProtein C:$targetCarbs F:$targetFat');

    // Check if any target would be exceeded
    final proteinExceeds = newProtein > (targetProtein + tolerance);
    final carbsExceeds = newCarbs > (targetCarbs + tolerance);
    final fatExceeds = newFat > (targetFat + tolerance);

    return proteinExceeds || carbsExceeds || fatExceeds;

  } catch (e) {
    print('Error parsing nutrition for ${item.itemName}: $e');
    return false; // Allow if parsing fails
  }
}

  
  void _toggleSelection(FoodRecommendation item) {
  // Check if trying to add item (not removing)
  if (!selectedItems.contains(item)) {
    // Check if adding this item would exceed nutritional targets
    if (enableNutritionalFiltering && _wouldExceedTargets(item)) {
      // ✅ SHOW ERROR MESSAGE (like GymFoodSelectionScreen)
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

    print('=== SENDING FOOD TO API ===');
    print('Selected Day: $selectedDay');
    print('Meal: ${widget.mealName}');
    print('Items: ${selectedItems.length}');
    print('User Dosha: ${widget.doshaResult}');

    // ✅ CALL CONTROLLER METHOD (WHICH HANDLES CONFIRMATION DIALOG INTERNALLY)
    await ref.read(DiProviders.bodyIqControllerProvider.notifier)
        .addSelectedFoodToMeal(
          context: context,
          userId: widget.userId,
          meal: widget.mealName == "Snack" ? "Snack" : widget.mealName,
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
    final targetCalories = recommendations?.targetCalories ?? 0;
    final consumedCalories = selectedItems.fold<int>(0, (sum, item) => sum + item.calories);
    return (targetCalories - consumedCalories).toString();
  }

  // ✅ Updated remaining calculations with dosha-based macro targets
  String _getRemainingProtein() {
    final targetMacros = _getTargetMacros();
    final consumedProtein = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.protein));
    return (targetMacros['protein']! - consumedProtein).toStringAsFixed(1);
  }

  String _getRemainingCarbs() {
    final targetMacros = _getTargetMacros();
    final consumedCarbs = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.carbs));
    return (targetMacros['carbs']! - consumedCarbs).toStringAsFixed(1);
  }

  String _getRemainingFat() {
    final targetMacros = _getTargetMacros();
    final consumedFat = selectedItems.fold<double>(0, (sum, item) => sum + double.parse(item.fats));
    return (targetMacros['fats']! - consumedFat).toStringAsFixed(1);
  }
}
