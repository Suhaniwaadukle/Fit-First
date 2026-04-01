import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.bottom,
    this.titleStyle,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      title: titleWidget ??
          Text(
            title ?? '',
            style: titleStyle ??
                Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 22,
                    ),
          ),
      actions: actions,
      backgroundColor: backgroundColor,
      elevation: elevation,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
