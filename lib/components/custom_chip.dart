import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class CustomChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const CustomChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedColor,
    this.unselectedColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final selectedTextColorTemp = selectedTextColor ?? getTextColor(context);
    final selectedColorTemp = selectedColor ?? MyColors.cardSelectedColor;
    final unselectedColorTemp = unselectedColor ?? MyColors.cardColor;
    final selectedBorderColorTemp = selectedBorderColor ?? MyColors.btnColor;
    final unselectedBorderColorTemp =
        unselectedBorderColor ?? Colors.grey.shade300;
    final unselectedTextColorTemp =
        unselectedTextColor ?? getTextColor(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColorTemp : unselectedColorTemp,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                selected ? selectedBorderColorTemp : unselectedBorderColorTemp,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              Padding(
                padding: EdgeInsetsGeometry.only(right: 3),
                child: Icon(
                  Icons.check,
                  color: selectedTextColorTemp,
                  size: 12,
                ),
              ),

            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Poppins',
                color:
                    selected ? selectedTextColorTemp : unselectedTextColorTemp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

