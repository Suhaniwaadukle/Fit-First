import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';

class SelectableCard extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Icon icon;

  const SelectableCard({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppColors.kPrimaryColor : AppColors.kBlack.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.kPrimaryColor.withValues(alpha: 0.09) : AppColors.kWhite,
        ),
        child: Row(
          spacing: 6,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            icon,
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isSelected ? AppColors.kPrimaryColor : AppColors.kBlack.withValues(alpha: 0.8),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommonTextFieldWithHeader extends StatelessWidget {
  final String label;
  final Widget textField;

  const CommonTextFieldWithHeader({super.key, required this.label, required this.textField});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        Text("$label *", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500)),
        textField,
      ],
    );
  }
}
