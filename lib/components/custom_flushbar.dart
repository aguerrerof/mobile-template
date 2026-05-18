import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

void showCustomFlushbar(
  BuildContext context, {
  String message = '',
  Color backgroundColor = MyColors.acentOne,
  Color textColor = Colors.white,
  int duration = 3,
}) {
  Flushbar(
    messageText: Text(
      message,
      style: TextStyle(
        color: textColor,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
    ),
    backgroundColor: backgroundColor.withAlpha(200),
    icon: Icon(Icons.error_outline, size: 28.0, color: textColor),
    leftBarIndicatorColor: backgroundColor,
    margin: const EdgeInsets.all(12),
    borderRadius: BorderRadius.circular(12),
    duration: Duration(seconds: duration),
    flushbarPosition: FlushbarPosition.TOP,
    animationDuration: const Duration(milliseconds: 500),
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeIn,
  ).show(context);
}

