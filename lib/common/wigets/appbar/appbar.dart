import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/index.dart';

class BasicAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? action;
  final Widget? leading;
  final Color? backgroundColor;
  final bool hideBack;
  final double? height;
  const BasicAppbar({
    this.title,
    this.hideBack = false,
    this.action,
    this.backgroundColor,
    this.height,
    this.leading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      toolbarHeight: height ?? 80,
      title: title ?? const Text(''),
      titleSpacing: 0,
      leadingWidth: leading != null ? 150 : null,
      actions: [action ?? Container()],
      leading:
          leading ??
          (hideBack
              ? null
              : IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: SizedBox(
                  height: 50,
                  width: 50,
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: AppDimensions.iconMd,
                    color: Colors.white,
                  ),
                ),
              )),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 80);
}
