import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import 'package:orka_sports/core/constants/app_sizes_paddings.dart';
import 'package:orka_sports/app/widgets/navigation_widget/navigation_widget.dart';

void showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  TextStyle? titleStyle,
  TextStyle? messageStyle,
  String buttonText = 'Close',
  TextStyle? buttonTextStyle,
  Widget? content,
  EdgeInsetsGeometry? contentPadding,
  bool? barrierDismissible,
  Color? backgroundColor,
  Color? surfaceTintColor,
  double? borderRadius,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            AppSize.kWidth20,
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.kBlack.withAlpha((0.6 * 255).round()),
                child: const Icon(CupertinoIcons.clear, color: AppColors.kWhite, size: 20),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppColors.kWhite,
        surfaceTintColor: surfaceTintColor ?? AppColors.kWhite,
        contentPadding: contentPadding ?? const EdgeInsets.all(20.0),
        content: content,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius ?? 20.0)),
      );
    },
    barrierDismissible: barrierDismissible ?? true,
  );
}

void showCustomPopup(
  BuildContext context, {
  required String title,
  required String message,
  void Function()? onOkPressed,
  void Function()? onCancelPressed,
  required IconData iconData,
  required String okButtonText,
  required String cancelButtonText,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CustomPopup(
        title: title,
        message: message,
        okButtonText: okButtonText,
        iconData: iconData,
        onOkPressed: onOkPressed ??
            () {
              NavigationWidget.commonNavigatioPop(context: context);
            },
        backgroundColor: AppColors.kWhite,
        cancelButtonText: cancelButtonText,
        onCancelPressed: onCancelPressed ??
            () {
              NavigationWidget.commonNavigatioPop(context: context);
            },
      );
    },
  );
}

class CustomPopup extends StatefulWidget {
  final String title;
  final String message;
  final String okButtonText;
  final String cancelButtonText;
  final VoidCallback onOkPressed;
  final VoidCallback onCancelPressed;
  final Color backgroundColor;
  final TextStyle? titleStyle;
  final TextStyle? messageStyle;
  final Color okButtonColor;
  final TextStyle? okButtonTextStyle;
  final IconData iconData;

  const CustomPopup({
    super.key,
    required this.title,
    required this.message,
    required this.okButtonText,
    required this.onOkPressed,
    this.backgroundColor = AppColors.kWhite,
    this.titleStyle,
    this.messageStyle,
    this.okButtonColor = AppColors.kBlack,
    this.okButtonTextStyle,
    required this.iconData,
    required this.cancelButtonText,
    required this.onCancelPressed,
  });

  @override
  State<CustomPopup> createState() => _CustomPopupState();
}

class _CustomPopupState extends State<CustomPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: widget.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.kPrimaryColor.withValues(alpha: 0.1),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.kPrimaryColor,
                    child: Center(child: Icon(widget.iconData, color: AppColors.kWhite, size: 45)),
                  ),
                ),
                AppSize.kHeight10,
                Text(
                  widget.title,
                  style: widget.titleStyle ??
                      Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.kPrimaryColor),
                  textAlign: TextAlign.center,
                ),
                AppSize.kHeight5,

                // Message
                Text(
                  widget.message,
                  style: widget.messageStyle ??
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.kBlack.withValues(alpha: 0.5),
                          ),
                  textAlign: TextAlign.center,
                ),
                AppSize.kHeight20,
                // OK Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _controller.reverse().then((value) {
                            widget.onCancelPressed();
                          });
                        },
                        child: Text(
                          widget.cancelButtonText,
                          style: widget.okButtonTextStyle ??
                              Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(fontSize: 15, color: AppColors.kBlack),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _controller.reverse().then((value) {
                            widget.onOkPressed();
                          });
                        },
                        child: Text(
                          widget.okButtonText,
                          style: widget.okButtonTextStyle ??
                              Theme.of(
                                context,
                              ).textTheme.headlineSmall?.copyWith(fontSize: 15, color: AppColors.kPrimaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Common BottomSheet
class CommonBottomSheet extends StatelessWidget {
  final Widget child;
  final double height;
  final double borderRadius;
  final EdgeInsets padding;

  const CommonBottomSheet({
    super.key,
    required this.child,
    this.height = 300.0,
    this.borderRadius = 20.0,
    this.padding = const EdgeInsets.all(16.0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      child: child,
    );
  }
}

showCommonBottomSheet({
  required BuildContext context,
  required Widget child,
  double height = 300.0,
  double borderRadius = 20.0,
  EdgeInsets padding = const EdgeInsets.all(16.0),
  bool? isDismissible,
  bool? isScrollControlled,
}) {
  showModalBottomSheet(
    isScrollControlled: isScrollControlled ?? false,
    isDismissible: isDismissible ?? true,
    context: context,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius))),
    builder: (BuildContext context) {
      return CommonBottomSheet(height: height, borderRadius: borderRadius, padding: padding, child: child);
    },
  );
}
