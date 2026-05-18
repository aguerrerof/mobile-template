import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

Future<void> showPlatformAlertDialog({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  String cancelText = "Cancelar",
  String confirmText = "Aceptar",
  bool destructive = false,
}) async {
  if (Platform.isIOS) {
    return showCupertinoDialog(
      context: context,
      builder:
          (ctx) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  cancelText,
                  style: TextStyle(
                    color:
                        CupertinoTheme.of(ctx).brightness == Brightness.dark
                            ? CupertinoColors.white
                            : CupertinoTheme.of(ctx).primaryColor,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  onCancel?.call();
                },
              ),
              CupertinoDialogAction(
                isDestructiveAction: destructive,
                onPressed: () {
                  Navigator.pop(ctx);
                  onConfirm();
                },
                child: Text(confirmText),
              ),
            ],
          ),
    );
  } else {
    return showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: MyColors.backgroundColor,
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'Poppins',
                color: getTextColor(context),
              ),
            ),
            content: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                color: getTextColor(context),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onCancel?.call();
                },
                child: Text(
                  cancelText,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: getTextColor(context),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onConfirm();
                },
                child: Text(
                  confirmText,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: getTextColor(context),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

