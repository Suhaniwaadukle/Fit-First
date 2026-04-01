import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orka_sports/app/config/themes.dart';
import 'package:orka_sports/core/enum/app_theme.dart';
import 'package:orka_sports/core/services/shared_prefs.dart';
import 'package:orka_sports/presentation/blocs/theme/theme_event.dart';
import 'package:orka_sports/presentation/blocs/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferencesService prefsService;
  static const _themeKey = 'app_theme';

  ThemeBloc(this.prefsService) : super(ThemeState(AppThemes.lightTheme, AppTheme.light)) {
    on<ToggleTheme>((event, emit) async {
      final isDark = state.appTheme == AppTheme.dark;
      final newTheme = isDark ? AppTheme.light : AppTheme.dark;
      await prefsService.setString(key: _themeKey, value: newTheme.name);
      emit(ThemeState(
        newTheme == AppTheme.dark ? AppThemes.darkTheme : AppThemes.lightTheme,
        newTheme,
      ));
    });
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeString = prefsService.getString(_themeKey);
    if (themeString == AppTheme.dark.name) {
      add(ToggleTheme(AppTheme.dark)); // Switch to dark if saved
    }
  }
}
