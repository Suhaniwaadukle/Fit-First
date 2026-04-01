import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';

class CommonContainerWithBorder extends StatelessWidget {
  const CommonContainerWithBorder({
    super.key,
    this.child,
    this.padding,
    required this.radius,
    this.color,
    this.borderColor,
  });
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? AppPaddings.containerPadding,
      decoration: BoxDecoration(
        color: color ?? AppColors.kWhite,
        border: Border.all(color: borderColor ?? AppColors.kBlack.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child ?? SizedBox.shrink(),
    );
  }
}

class CommonLoadingWidget extends StatelessWidget {
  const CommonLoadingWidget({super.key, this.circleColor});
  final Color? circleColor;
  @override
  Widget build(BuildContext context) {
    return Center(child: CircularProgressIndicator(color: circleColor ?? AppColors.kPrimaryColor, strokeWidth: 2.5));
  }
}

class CommonErrorWidget extends StatelessWidget {
  final String message;
  final IconData icon;
  final double iconSize;
  final TextStyle? messageStyle;
  final Color? iconColor;

  const CommonErrorWidget({
    super.key,
    required this.message,
    this.icon = CupertinoIcons.exclamationmark_circle,
    this.iconSize = 80,
    this.messageStyle,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? AppColors.kPrimaryColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: messageStyle ??
                TextStyle(
                  fontSize: 16,
                  color: AppColors.kBlack.withValues(
                    alpha: 0.7,
                  ),
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
