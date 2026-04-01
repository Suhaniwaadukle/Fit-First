import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';

class QuizWidgets {
  static Widget buildLogo({required IconData icon}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(color: AppColors.kPrimaryColor, borderRadius: BorderRadius.circular(40)),
      child: Icon(icon, color: AppColors.kWhite, size: 40),
    );
  }

  static Widget buildTitleSection(BuildContext context, {required String title, required String subTitle}) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
        AppSize.kHeight8,
        Text(
          subTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: AppColors.kBlack.withAlpha(128), fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
