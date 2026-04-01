import 'package:flutter/material.dart';

// For images
class AppImages {
  static const path = 'assets/images/';
  static const splashImages = '${path}orka-strive.png';
}

// For sizing

class AppSize {
  static const kHeight5 = SizedBox(height: 5);
  static const kHeight8 = SizedBox(height: 8);
  static const kHeight10 = SizedBox(height: 10);
  static const kHeight15 = SizedBox(height: 15);
  static const kHeight20 = SizedBox(height: 20);
  static const kHeight30 = SizedBox(height: 30);
  static const kHeight40 = SizedBox(height: 40);
  static const kHeight50 = SizedBox(height: 50);
  static const kHeight60 = SizedBox(height: 60);

  // Width
  static const kWidth5 = SizedBox(width: 5);
  static const kWidth10 = SizedBox(width: 10);
  static const kWidth15 = SizedBox(width: 15);
  static const kWidth20 = SizedBox(width: 20);
  static const kWidth30 = SizedBox(width: 30);
  static const kWidth40 = SizedBox(width: 40);
  static const kWidth50 = SizedBox(width: 50);
  static const kWidth60 = SizedBox(width: 60);
  // Icon Size
  static const double appIconSize = 24;
}

// Paddings
class AppPaddings {
  static const backgroundP = EdgeInsets.all(30);
  static const backgroundPAll = EdgeInsets.all(24);
  static const bottomnavP = EdgeInsets.only(
    left: 20,
    right: 20,
    bottom: 40,
  );
  static const buttonPadding = EdgeInsets.all(12);
  static const textFormPadding = EdgeInsets.symmetric(vertical: 15, horizontal: 20);
  static const containerPadding = EdgeInsets.all(15);
}
