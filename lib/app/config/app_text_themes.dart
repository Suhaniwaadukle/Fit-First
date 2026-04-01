import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';

class AppTextTheme {
  static TextTheme lightTextTheme = _buildTextTheme(AppColors.kBlack);
  static TextTheme darkTextTheme = _buildTextTheme(AppColors.kWhite);

  static TextTheme _buildTextTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: color),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color),
      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      bodyLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      bodyMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: color),
      labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: color),
    );
  }
}
