import 'package:flutter/material.dart';
import 'package:locket/core/configs/theme/app_colors.dart';

class DisplayMessage {
  static void error(BuildContext context, String message) {
    var snackbar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  static void success(BuildContext context, String message) {
    var snackbar = SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.primary,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
