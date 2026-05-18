import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';

Widget emptyView(
  BuildContext context,
  String? title,
  String? subtitle,
  Widget? image,
  String? titleButton,
  VoidCallback? onTap,
  String? titleButton2,
  VoidCallback? onTap2,
) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image != null) image,
          const SizedBox(height: 16),
          if (title != null)
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 8),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          if (titleButton != null && onTap != null)
            CustomButton(
              onPressed: onTap,
              label: titleButton,
              borderRadius: 22,
            ),
          const SizedBox(height: 20),
          if (titleButton2 != null && onTap2 != null)
            CustomButton(
              onPressed: onTap2,
              label: titleButton2,
              type: CustomButtonType.outline,
              borderRadius: 22,
            ),
        ],
      ),
    ),
  );
}

