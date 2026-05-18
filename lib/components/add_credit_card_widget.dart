import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddDottedCardButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String? subtitle;
  final Widget? icon;
  final bool? showPlus;
  final Color? backgroundColor;
  final EdgeInsets? internalPadding;
  final bool withDot;
  final bool selected;
  final List<double> dashPattern;
  final bool showSelectedCheck;
  final bool hideTrailingWhenUnselected;
  final bool checkoutCardDesign;
  final String? leadingLabel;
  final Widget? leadingFooter;

  const AddDottedCardButton({
    super.key,
    required this.onTap,
    required this.title,
    this.subtitle,
    this.icon,
    this.showPlus,
    this.backgroundColor,
    this.internalPadding,
    this.withDot = true,
    this.selected = false,
    this.dashPattern = const [6, 3],
    this.showSelectedCheck = false,
    this.hideTrailingWhenUnselected = false,
    this.checkoutCardDesign = false,
    this.leadingLabel,
    this.leadingFooter,
  });

  @override
  Widget build(BuildContext context) {
    if (checkoutCardDesign) {
      return GestureDetector(
        onTap: onTap,
        child: Skeleton.ignore(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1D5DB), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 88,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2F5EA8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child:
                        leadingFooter ??
                        Text(
                          leadingLabel ?? '',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle ?? '',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (showSelectedCheck && selected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E8B47),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Skeleton.ignore(
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            strokeWidth: 1,
            color: withDot ? Colors.grey : Colors.transparent,
            radius: Radius.circular(12),
            dashPattern: dashPattern,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border:
                  selected
                      ? Border.all(
                        color: MyColors.selectedBorderColor,
                        width: 2.0,
                      )
                      : null,
            ),
            padding:
                internalPadding ??
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    icon ??
                        Icon(
                          Icons.credit_card,
                          size: 40,
                          color: MyColors.btnColor,
                        ),
                    if (showPlus != null && showPlus == true)
                      Container(
                        decoration: BoxDecoration(
                          color: MyColors.btnColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                // Títulos
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    if (subtitle != null)
                      Text(
                        subtitle ?? '',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                      ),
                  ],
                ),
                const Spacer(),
                if (showSelectedCheck && selected)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E8B47),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                else if (!hideTrailingWhenUnselected)
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 15,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

