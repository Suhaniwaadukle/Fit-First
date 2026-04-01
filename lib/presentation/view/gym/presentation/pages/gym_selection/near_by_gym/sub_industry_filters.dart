import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/presentation/view/gym/data/models/get_sub_industry_model.dart';
import 'package:orka_sports/presentation/view/gym/domain/entities/gym_entity.dart';
import 'package:orka_sports/presentation/view/gym/presentation/controllers/gym_controller.dart';

class SubIndustryFilterRow extends StatelessWidget {
  final List<SubIndustryData> subIndustries;
  final String? selectedId;
  final Function(SubIndustryData) onSelected;
  final GymController gymController;
  final GymEntity gymEntity;

  const SubIndustryFilterRow({
    super.key,
    required this.subIndustries,
    required this.selectedId,
    required this.onSelected,
    required this.gymController,
    required this.gymEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Clear Button Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select Sub-Industry',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            Visibility(
              visible: gymEntity.selectedSubIndustryId.isNotEmpty,
              child: TextButton(
                onPressed: () {
                  onSelected(SubIndustryData(id: null, name: '', icon: null));
                  gymController.onSelectedSubIndustryId(context, value: "");
                  gymController.getNearByGyms(context, type: "NearByGym");
                },
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        Visibility(visible: gymEntity.selectedSubIndustryId.isEmpty, child: AppSize.kHeight10),
        // Horizontal Filter List
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: subIndustries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = subIndustries[index];
              final isSelected = item.id == selectedId;

              return GestureDetector(
                onTap: () => onSelected(item),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 100,
                  decoration: BoxDecoration(
                    color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.white,
                    border: Border.all(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      item.icon != null
                          ? Image.network(
                              item.icon!,
                              height: 35,
                              width: 35,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                            )
                          : const Icon(Icons.fitness_center, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        item.name ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
