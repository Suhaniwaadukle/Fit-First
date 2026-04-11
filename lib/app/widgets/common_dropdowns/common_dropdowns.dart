import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';

class CommonDropDownWidget extends StatelessWidget {
  final List<String> items;
  final String hintText;
  final String primaryValue;
  final void Function(String?)? onDropDwChanged;
  final Widget? widgetIcon;
  final double? dropdownOpacity;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final Color? isDropIconColor;
  final bool? absorbing;

  const CommonDropDownWidget({
    super.key,
    required this.items,
    this.hintText = 'Select type',
    required this.primaryValue,
    this.onDropDwChanged,
    this.widgetIcon,
    this.dropdownOpacity,
    this.radius,
    this.padding,
    this.isDropIconColor,
    this.absorbing,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: absorbing ?? false,
      child: Opacity(
        opacity: dropdownOpacity ?? 1,
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            isExpanded: true,
            customButton: Container(
              padding: padding ??
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius ?? 15),
                color: AppColors.kWhite,
                border: Border.all(
                  color: AppColors.kBlack.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  AppSize.kWidth5,
                  widgetIcon ?? const SizedBox.shrink(),
                  widgetIcon == null
                      ? const SizedBox.shrink()
                      : AppSize.kWidth15,
                  Expanded(
                    child: Text(
                      primaryValue,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 16,
                        color: primaryValue == hintText
                            ? AppColors.kBlack.withValues(alpha: 0.4)
                            : AppColors.kBlack,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: isDropIconColor ??
                        AppColors.kBlack.withAlpha((0.76 * 255).round()),
                    size: 18,
                  ),
                ],
              ),
            ),
            items: items.isEmpty
                ? [
              DropdownMenuItem<String>(
                value: 'no_data',
                enabled: false,
                child: Center(
                  child: Text(
                    'No data found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
            ]
                : items
                .map(
                  (String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
                .toList(),
            value: items.contains(primaryValue) ? primaryValue : null,
            onChanged: onDropDwChanged,
            buttonStyleData: ButtonStyleData(
              overlayColor: WidgetStatePropertyAll(AppColors.kWhite),
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: AppColors.kWhite,
              ),
              offset: const Offset(0, -10),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: WidgetStateProperty.all<double>(6),
                thumbVisibility: WidgetStateProperty.all<bool>(true),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 40,
              padding: const EdgeInsets.only(left: 14, right: 14),
              overlayColor: WidgetStatePropertyAll(AppColors.kWhite),
            ),
          ),
        ),
      ),
    );
  }
}