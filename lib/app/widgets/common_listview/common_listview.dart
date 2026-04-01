import 'package:flutter/material.dart';
import 'package:orka_sports/core/constants/app_colors.dart';

class CommonListviewBuilder extends StatelessWidget {
  const CommonListviewBuilder({
    super.key,
    required this.separatorBuilder,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollDirection,
    this.controller,
    this.physics,
  });

  final Widget Function(BuildContext, int) separatorBuilder;
  final int itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  final Axis? scrollDirection;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: controller,
      shrinkWrap: true,
      scrollDirection: scrollDirection ?? Axis.vertical,
      physics: physics ?? const BouncingScrollPhysics(),
      itemBuilder: itemBuilder,
      separatorBuilder: separatorBuilder,
      itemCount: itemCount,
    );
  }
}

class CommonListTile extends StatelessWidget {
  const CommonListTile({
    super.key,
    this.title,
    this.subTitle,
    this.trailing,
    this.isSubtitle = false,
    this.tileColor,
    this.contentPadding,
    this.elevation,
    this.onTap,
    this.leading,
    this.titleStyle,
    this.subtitleStyle,
    this.borderRadius,
    this.borderColor,
    this.subtitleWidget,
    this.titleMaxLines,
    this.overflowTitle,
    this.titleWidget,
  });
  final String? title;
  final TextStyle? titleStyle;
  final String? subTitle;
  final TextStyle? subtitleStyle;
  final Widget? trailing;
  final bool isSubtitle;
  final Color? tileColor;
  final double? elevation;
  final EdgeInsetsGeometry? contentPadding;
  final void Function()? onTap;
  final Widget? leading;
  final double? borderRadius;
  final Color? borderColor;
  final Widget? subtitleWidget;
  final int? titleMaxLines;
  final TextOverflow? overflowTitle;
  final Widget? titleWidget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null)
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: double.infinity, // Allow the height to expand
            ),
            child: leading!,
          ),
        Expanded(
          child: ListTile(
            splashColor: AppColors.kWhite,
            dense: false, // Set to false for a standard height
            tileColor: tileColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 15),
              side: BorderSide(color: borderColor ?? AppColors.kBlack.withAlpha((0.1 * 255).round())),
            ),
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
            title: titleWidget ??
                Text(
                  title ?? '',
                  maxLines: titleMaxLines,
                  overflow: overflowTitle,
                  style: titleStyle ?? TextStyle(fontSize: 14, color: AppColors.kBlack.withAlpha((0.4 * 255).round())),
                ),
            subtitle: isSubtitle
                ? subtitleWidget ?? Text(subTitle ?? '', style: subtitleStyle ?? const TextStyle(fontSize: 14))
                : null,
            trailing: trailing,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}
