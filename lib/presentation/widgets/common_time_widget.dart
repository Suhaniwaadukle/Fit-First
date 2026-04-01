import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:orka_sports/app/widgets/common_formatter/common_formatter.dart';
import 'package:orka_sports/core/constants/app_colors.dart';

class CommonTimeWidget {
  Future<void> selectTimeCommon({
    required BuildContext context,
    required String existingTime,
    required void Function(String formattedTime) onTimeSelected,
  }) async {
    final CommonFormatter formatter = CommonFormatter();
    // Determine initial time
    TimeOfDay initialTime = existingTime.isNotEmpty ? formatter.parseTimeScheduler(existingTime) : TimeOfDay.now();

    // Show time picker
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.kPrimaryColor,
            colorScheme: const ColorScheme.light(primary: AppColors.kPrimaryColor),
            timePickerTheme: TimePickerThemeData(
              dialHandColor: AppColors.kWhite,
              dialBackgroundColor: AppColors.kPrimaryColor,
              dialTextColor: WidgetStateColor.resolveWith((states) {
                return states.contains(WidgetState.selected) ? AppColors.kPrimaryColor : AppColors.kWhite;
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                return states.contains(WidgetState.selected) ? AppColors.kWhite : AppColors.kPrimaryColor;
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                return states.contains(WidgetState.selected) ? AppColors.kPrimaryColor : AppColors.kWhite;
              }),
              helpTextStyle: TextStyle(color: AppColors.kPrimaryColor),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) {
      log("Time selection canceled");
      return;
    }

    // Format picked time
    final formattedTime = formatter.formatTimeWPGlobal(pickedTime);
    log("Selected time: $formattedTime");

    // Send back selected time to controller
    onTimeSelected(formattedTime);
  }
}
