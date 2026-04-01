import 'package:flutter/material.dart';
import 'package:orka_sports/app/widgets/appbar/appbar.dart';
import 'package:orka_sports/app/widgets/common_buttons_textforms/button_textforms.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';

class AddDietScreen extends StatefulWidget {
  const AddDietScreen({super.key});

  @override
  State<AddDietScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends State<AddDietScreen> {
  final List<FoodItem> foods = [
    FoodItem(name: "Olive oil", kcal: 90, quantity: 10, protein: 0, carbs: 0, fat: 10),
    FoodItem(name: "Rice dry uncooked", kcal: 357, quantity: 100, protein: 14.7, carbs: 74.9, fat: 1.1),
    FoodItem(name: "Pigeon Pea (Toor dal)", kcal: 343, quantity: 100, protein: 22, carbs: 64, fat: 2),
    FoodItem(name: "Milk whole 3.25%", kcal: 63, quantity: 100, protein: 3, carbs: 5, fat: 3.4),
    FoodItem(name: "Wheat flour whole", kcal: 364, quantity: 100, protein: 10, carbs: 73.5, fat: 1),
  ];
  int selectedFilterIndex = 0;
  final List<String> filters = ["All", "Vegetarian", "Non-Vegetarian"];
  final Set<int> selectedIndexes = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: "Select Food",
        titleStyle: Theme.of(context).textTheme.headlineSmall,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(filters.length, (index) {
                return CustomFilterChip(
                  label: filters[index],
                  isSelected: selectedFilterIndex == index,
                  onTap: () {
                    setState(() {
                      selectedFilterIndex = index;
                    });
                  },
                );
              }),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foods.length,
              itemBuilder: (context, index) {
                final item = foods[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppColors.kBlack.withValues(
                        alpha: 0.1,
                      ),
                    ),
                  ),
                  elevation: 0,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(12),
                    leading: Icon(Icons.fastfood, size: 40, color: AppColors.kPrimaryColor),
                    title: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${item.quantity}gm | ${item.kcal}kcal"),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(child: NutrientTag(label: "P", value: item.protein)),
                            SizedBox(width: 6),
                            Expanded(child: NutrientTag(label: "C", value: item.carbs)),
                            SizedBox(width: 6),
                            Expanded(child: NutrientTag(label: "F", value: item.fat)),
                          ],
                        )
                      ],
                    ),
                    trailing: Checkbox(
                      value: selectedIndexes.contains(index),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            selectedIndexes.add(index);
                          } else {
                            selectedIndexes.remove(index);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: AppPaddings.bottomnavP,
        child: Row(
          children: [
            Icon(Icons.expand_less, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text("0 foods selected", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
            Expanded(
              child: ButtonWidget(
                text: "Add to Breakfast",
                borderRadius: BorderRadius.circular(15),
                backgroundColor: WidgetStatePropertyAll(AppColors.kPrimaryColor),
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: AppColors.kWhite, fontWeight: FontWeight.bold),
                onPressed: () {
                  // CustomSmoothNavigator.push(context, ProgressTrackerScreen());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomFilterChip({super.key, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isSelected ? AppColors.kWhite : AppColors.kBlack,
            ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.kPrimaryColor,
      checkmarkColor: AppColors.kWhite,
    );
  }
}

class FoodItem {
  final String name;
  final int kcal;
  final int quantity;
  final double protein;
  final double carbs;
  final double fat;

  FoodItem({
    required this.name,
    required this.kcal,
    required this.quantity,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class NutrientTag extends StatelessWidget {
  final String label;
  final double value;

  const NutrientTag({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text("$label: ${value.toStringAsFixed(1)}", style: TextStyle(fontSize: 12)),
    );
  }
}
