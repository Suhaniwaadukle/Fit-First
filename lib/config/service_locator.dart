import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetItService {
  static final getIt = GetIt.instance;

  Future<void> setupLocator() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(prefs);
  }
}
