import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

enum CustomButtonType { filled, outline, text }

class CustomButton extends StatelessWidget {
  final String? label;
  final VoidCallback onPressed;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final CustomButtonType type;
  final double? borderRadius;
  final double? borderWight;
  final double? height;
  final double? widht;
  final double? paddingHorizontal;
  final bool alwaysBackground;
  final Color? borderColor;
  final MainAxisAlignment textAligment;
  final bool boldText;

  const CustomButton({
    super.key,
    this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.type = CustomButtonType.filled,
    this.borderRadius,
    this.borderWight,
    this.height,
    this.widht,
    this.paddingHorizontal,
    this.alwaysBackground = false,
    this.borderColor,
    this.textAligment = MainAxisAlignment.center,
    this.boldText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Platform.isIOS;
    switch (type) {
      case CustomButtonType.filled:
        if (isIOS) {
          return SizedBox(
            height: height ?? 45,
            width: widht,
            child: ClipRRect(
              borderRadius:
                  borderRadius != null
                      ? BorderRadius.circular(borderRadius!)
                      : BorderRadius.zero,
              child: CupertinoButton(
                padding: EdgeInsets.symmetric(
                  horizontal: paddingHorizontal ?? 10,
                ),
                color: backgroundColor ?? MyColors.btnColor,
                onPressed: onPressed,
                child: _buildContent(context),
              ),
            ),
          );
        } else {
          return SizedBox(
            height: height ?? 45,
            width: widht,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                shadowColor:
                    backgroundColor == Colors.transparent
                        ? backgroundColor
                        : null,
                backgroundColor: backgroundColor ?? MyColors.btnColor,
                foregroundColor: textColor ?? MyColors.textBtnColor,
                padding:
                    paddingHorizontal != null
                        ? EdgeInsets.symmetric(horizontal: paddingHorizontal!)
                        : null,
                shape:
                    borderRadius != null
                        ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius!),
                        )
                        : null,
              ),
              child: _buildContent(context),
            ),
          );
        }
      case CustomButtonType.outline:
        if (isIOS) {
          return SizedBox(
            height: height ?? 45,
            width: widht,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      borderColor ??
                      textColor ??
                      MyColors.btnColor.withAlpha(150),
                  width: borderWight ?? 1,
                ),
                borderRadius: BorderRadius.circular(borderRadius ?? 8),
              ),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                color: alwaysBackground ? backgroundColor : Colors.transparent,
                onPressed: onPressed,
                child: _buildContent(context),
              ),
            ),
          );
        } else {
          return SizedBox(
            height: height ?? 45,
            width: widht,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    textColor ?? Theme.of(context).colorScheme.primary,
                side: BorderSide(
                  color: textColor ?? MyColors.btnColor.withAlpha(150),
                  width: borderWight ?? 1,
                ),
                shape:
                    borderRadius != null
                        ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(borderRadius!),
                        )
                        : null,
              ),
              child: _buildContent(context),
            ),
          );
        }
      case CustomButtonType.text:
        if (isIOS) {
          return SizedBox(
            height: height ?? 45,
            width: widht,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onPressed,
              child: _buildContent(context),
            ),
          );
        } else {
          return SizedBox(
            height: height ?? 45,
            width: widht,
            child: TextButton(
              onPressed: onPressed,
              child: _buildContent(context),
            ),
          );
        }
    }
  }

  Widget _buildContent(BuildContext context) {
    return Row(
      mainAxisAlignment: textAligment,
      children: [
        if (icon != null) ...[icon!, SizedBox(width: label != null ? 8 : 0)],
        if (label != null)
          Text(
            label ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color:
                  textColor ??
                  ((type == CustomButtonType.outline ||
                          type == CustomButtonType.text)
                      ? MyColors.btnColor
                      : MyColors.textBtnColor),
              fontSize: 14,
              fontWeight: boldText ? FontWeight.w600 : FontWeight.w400,
              fontFamily: 'Poppins',
            ),
          ),
      ],
    );
  }
}

