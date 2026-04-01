import 'package:flutter/material.dart';

class NavigationWidget {
  // CommonNavigation
  static commonNavigation({required BuildContext context, required String route}) {
    Navigator.of(context).pushNamed(route);
  }

  static commonNavigationPushReplace({required BuildContext context, required String route}) {
    Navigator.of(context).pushReplacementNamed(route);
  }

  static commonNavigatioPop({required BuildContext context}) {
    Navigator.of(context).pop();
  }
}
