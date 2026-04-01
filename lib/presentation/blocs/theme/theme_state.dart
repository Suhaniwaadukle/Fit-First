
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:orka_sports/core/enum/app_theme.dart';

class ThemeState extends Equatable {
  final ThemeData themeData;
  final AppTheme appTheme;
  const ThemeState(this.themeData, this.appTheme);

  @override
  List<Object?> get props => [themeData, appTheme];
}
