import 'package:equatable/equatable.dart';
import 'package:orka_sports/core/enum/app_theme.dart';

abstract class ThemeEvent extends Equatable {}

class ToggleTheme extends ThemeEvent {
  final AppTheme appTheme;
  ToggleTheme(this.appTheme);

  @override
  List<Object?> get props => [appTheme];
}
