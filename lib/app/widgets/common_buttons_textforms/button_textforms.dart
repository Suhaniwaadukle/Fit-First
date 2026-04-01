import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orka_sports/core/constants/app_colors.dart';
import '../../../core/constants/app_sizes_paddings.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    this.suffix,
    this.controller,
    required this.validator,
    this.obscureText,
    required this.keyboard,
    this.onChanged,
    this.text,
    this.contentPadding,
    this.preffix,
    this.hintText,
    this.colorFill,
    this.label,
    this.borderColor,
    this.focusBorderColor,
    this.enabledBorderColor,
    this.cursorColor,
    this.color,
    this.hintStyle,
    this.borderRadius,
    this.focussedBorderRadius,
    this.enabledBorderRadius,
    this.filled,
    this.inputFormatters,
    this.decoration,
    this.autovalidateMode,
    this.readOnly = false,
    this.fontSize,
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.textfieldOpacity,
  });

  final Widget? suffix;
  final Widget? preffix;
  final String? hintText;
  final Color? colorFill;
  final TextEditingController? controller;
  final String? Function(String?) validator;
  final bool? obscureText;
  final String? text;
  final TextInputType keyboard;
  final EdgeInsetsGeometry? contentPadding;
  final void Function(String)? onChanged;
  final Widget? label;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? enabledBorderColor;
  final Color? cursorColor;
  final Color? color;
  final TextStyle? hintStyle;
  final BorderRadius? borderRadius;
  final BorderRadius? focussedBorderRadius;
  final BorderRadius? enabledBorderRadius;
  final bool? filled;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration? decoration;
  final AutovalidateMode? autovalidateMode;
  final bool readOnly;
  final double? fontSize;
  final void Function()? onTap;
  final int? maxLines;
  final int? minLines;
  final double? textfieldOpacity;
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: textfieldOpacity ?? 1,
      child: TextFormField(
        onChanged: onChanged,
        obscureText: obscureText ?? false,
        keyboardType: keyboard,
        textInputAction: TextInputAction.done,
        controller: controller,
        cursorColor: cursorColor ?? AppColors.kBlack,
        style: TextStyle(color: color ?? AppColors.kBlack, fontSize: fontSize ?? 16),
        validator: validator,
        inputFormatters: inputFormatters,
        autovalidateMode: autovalidateMode,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        minLines: minLines,
        decoration: decoration ??
            InputDecoration(
              fillColor: colorFill,
              suffixIcon: suffix,
              hintText: hintText,
              hintStyle: hintStyle ??
                  Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontSize: 16, color: AppColors.kBlack.withValues(alpha: 0.4)),
              prefixIcon: preffix,
              filled: filled,
              label: (text != null || label != null)
                  ? label ?? Text(text ?? '', style: TextStyle(color: AppColors.kWhite.withAlpha((0.3 * 255).round())))
                  : null,
              contentPadding: contentPadding ?? EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: borderRadius ?? BorderRadius.circular(14),
                borderSide: BorderSide(color: borderColor ?? AppColors.kBlack.withValues(alpha: 0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: enabledBorderColor ?? AppColors.kBlack.withValues(alpha: 0.4)),
                borderRadius: enabledBorderRadius ?? BorderRadius.circular(14),
              ),
              enabled: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: focusBorderColor ?? AppColors.kBlack.withValues(alpha: 0.4)),
                borderRadius: focussedBorderRadius ?? BorderRadius.circular(14),
              ),
            ),
      ),
    );
  }
}

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    this.screen,
    required this.text,
    this.backgroundColor,
    required this.borderRadius,
    this.style,
    this.padding,
    this.onPressed,
    this.isLoading = false,
    this.side,
    this.foregroundColor,
    this.opacity,
  });

  final Widget? screen;
  final String text;
  final WidgetStateProperty<Color?>? backgroundColor;
  final BorderRadiusGeometry borderRadius;
  final TextStyle? style;
  final WidgetStateProperty<EdgeInsetsGeometry?>? padding;
  final void Function()? onPressed;
  final bool isLoading;
  final BorderSide? side;
  final WidgetStateProperty<Color?>? foregroundColor;
  final double? opacity;
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity ?? 1,
      child: AbsorbPointer(
        absorbing: opacity == 0.3 ? true : false,
        child: ElevatedButton(
          onPressed: onPressed ??
              (screen != null
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return screen!;
                          },
                        ),
                      );
                    }
                  : null),
          style: ButtonStyle(
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: backgroundColor,
            padding: padding,
            foregroundColor: foregroundColor ?? WidgetStateProperty.all(AppColors.kWhite),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: borderRadius, side: side ?? BorderSide.none),
            ),
          ),
          child: isLoading
              ? Container(
                  width: 20,
                  height: 20,
                  padding: const EdgeInsets.all(2),
                  child: const CircularProgressIndicator(color: AppColors.kWhite, strokeWidth: 2),
                )
              : FittedBox(fit: BoxFit.scaleDown, child: Text(text, style: style)),
        ),
      ),
    );
  }
}

class CommonTwoHeaderColumnTileWidget extends StatelessWidget {
  const CommonTwoHeaderColumnTileWidget({
    super.key,
    required this.headerTitle,
    required this.subWidget,
    this.headerStyle,
    this.spaceWidget,
    this.isManadatory,
  });
  final String headerTitle;
  final Widget subWidget;
  final TextStyle? headerStyle;
  final Widget? spaceWidget;
  final bool? isManadatory;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isManadatory == true ? "$headerTitle*" : headerTitle,
          style: headerStyle ??
              Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontSize: 16, color: AppColors.kBlack.withValues(alpha: 0.7)),
        ),
        spaceWidget ?? AppSize.kHeight10,
        subWidget,
      ],
    );
  }
}

class CommonToggleButton extends StatelessWidget {
  const CommonToggleButton({
    super.key,
    required this.value,
    this.onChanged,
    this.trackOutlineColor,
    this.toggleSize,
    this.absorbing,
    required this.isYesNo,
  });
  final bool value;
  final void Function(bool)? onChanged;
  final WidgetStateProperty<Color?>? trackOutlineColor;
  final double? toggleSize;
  final bool? absorbing;
  final bool isYesNo;
  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: absorbing ?? false,
      child: isYesNo
          ? Row(
              children: [
                const Text("Yes", style: TextStyle(color: AppColors.kBlack, fontSize: 18)),
                Transform.scale(
                  scale: toggleSize ?? 0.6,
                  child: Switch(
                    value: value,
                    onChanged: onChanged,
                    splashRadius: 0,
                    activeColor: AppColors.kWhite,
                    activeTrackColor: AppColors.kBlack,
                    inactiveTrackColor: AppColors.kWhite,
                    trackOutlineColor: trackOutlineColor ?? const WidgetStatePropertyAll(AppColors.kBlack),
                  ),
                ),
                const Text("No", style: TextStyle(color: AppColors.kBlack, fontSize: 18)),
              ],
            )
          : Transform.scale(
              scale: toggleSize ?? 0.62,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.kWhite,
                activeTrackColor: AppColors.kBlack,
                inactiveTrackColor: AppColors.kWhite,
                trackOutlineColor: trackOutlineColor ?? const WidgetStatePropertyAll(AppColors.kBlack),
              ),
            ),
    );
  }
}

// Common Check Box Widget
class CommonCheckBoxWidget extends StatelessWidget {
  const CommonCheckBoxWidget({super.key, this.value, this.onChanged});
  final bool? value;
  final void Function(bool?)? onChanged;
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.5,
      child: Checkbox.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.kBlack,
        side: BorderSide(color: AppColors.kBlack.withValues(alpha: 0.2)),
      ),
    );
  }
}

// Common Icon Widget
class CommonIconWidget extends StatelessWidget {
  const CommonIconWidget({super.key, required this.icon, required this.size, this.onPressed, this.color});
  final IconData icon;
  final double size;
  final void Function()? onPressed;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: Icon(icon, size: size, color: color));
  }
}

class CommonBottomButtonWidget extends StatelessWidget {
  final String leftButtonText;
  final String rightButtonText;
  final VoidCallback? onLeftButtonPressed;
  final VoidCallback? onRightButtonPressed;
  final bool isLeftButtonLoading;
  final bool isRightButtonLoading;
  final bool isLeftButtonEnabled;
  final bool isRightButtonEnabled;
  final bool isAbsorbing;
  final bool isSingleButon;
  final EdgeInsetsGeometry? padding;
  final Color? leftBackgroundColor;
  final Color? leftBorderColor;
  final Color? rightBackgroundColor;
  final Color? rightTextColor;
  final Color? leftTextColor;

  const CommonBottomButtonWidget({
    super.key,
    required this.leftButtonText,
    required this.rightButtonText,
    required this.onLeftButtonPressed,
    required this.onRightButtonPressed,
    required this.isLeftButtonLoading,
    required this.isRightButtonLoading,
    this.isLeftButtonEnabled = false,
    required this.isRightButtonEnabled,
    required this.isAbsorbing,
    this.padding,
    this.isSingleButon = false,
    this.leftBackgroundColor,
    this.leftBorderColor,
    this.rightBackgroundColor,
    this.rightTextColor,
    this.leftTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ??
          const EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: 20,
          ),
      child: AbsorbPointer(
        absorbing: isAbsorbing,
        child: Opacity(
          opacity: isAbsorbing ? 0.3 : 1,
          child: isSingleButon
              ? Opacity(
                  opacity: isRightButtonEnabled ? 0.3 : 1,
                  child: ButtonWidget(
                    isLoading: isRightButtonLoading,
                    screen: null,
                    text: rightButtonText,
                    style: const TextStyle(
                      color: AppColors.kWhite,
                      fontWeight: FontWeight.bold,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: WidgetStateProperty.all(
                      AppColors.kPrimaryColor,
                    ),
                    onPressed: isRightButtonEnabled ? null : onRightButtonPressed,
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Opacity(
                        opacity: isLeftButtonEnabled ? 0.3 : 1,
                        child: ButtonWidget(
                          isLoading: isLeftButtonLoading,
                          screen: null,
                          text: leftButtonText,
                          style: TextStyle(
                            fontSize: 16,
                            color: leftTextColor ?? AppColors.kPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          side: BorderSide(
                            color: leftBorderColor ?? Color.fromARGB(255, 248, 218, 219),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: WidgetStateProperty.all(
                            leftBackgroundColor ?? Color.fromARGB(255, 248, 218, 219),
                          ),
                          onPressed: isLeftButtonEnabled ? null : onLeftButtonPressed,
                        ),
                      ),
                    ),
                    AppSize.kWidth10,
                    Expanded(
                      child: Opacity(
                        opacity: isRightButtonEnabled ? 0.3 : 1,
                        child: ButtonWidget(
                          isLoading: isRightButtonLoading,
                          screen: null,
                          text: rightButtonText,
                          style: TextStyle(
                            fontSize: 16,
                            color: rightTextColor ?? AppColors.kWhite,
                            fontWeight: FontWeight.bold,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          backgroundColor: WidgetStateProperty.all(
                            rightBackgroundColor ?? AppColors.kPrimaryColor,
                          ),
                          onPressed: isRightButtonEnabled ? null : onRightButtonPressed,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
