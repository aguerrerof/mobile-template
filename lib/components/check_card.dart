import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class CheckCardWidget extends StatelessWidget {
  final String textString;
  final String subtitleString;
  final bool checked;
  final void Function() tapGesture;
  final Widget? child;
  final Color? borderColor;
  final Color? borderColorChecked;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final bool showAlwaysSubtitle;
  final Color? titleColor;
  final bool showCheck;
  final TextStyle? titleTextStyle;
  final bool hideChildWhenUnchecked;
  final double paddingTop;

  const CheckCardWidget({
    super.key,
    this.textString = '',
    this.checked = false,
    required this.tapGesture,
    this.subtitleString = '',
    this.child,
    this.borderColor,
    this.backgroundColor,
    this.padding,
    this.showAlwaysSubtitle = false,
    this.titleColor,
    this.borderColorChecked,
    this.showCheck = true,
    this.titleTextStyle,
    this.hideChildWhenUnchecked = false,
    this.paddingTop = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: tapGesture,
      child: Card(
        elevation: backgroundColor == Colors.transparent ? 0 : null,
        // shape: RoundedRectangleBorder(
        //   side:
        //       checked
        //           ? BorderSide(
        //             color: borderColorChecked ?? MyColors.selectedBorderColor,
        //             width: 2,
        //           )
        //           : BorderSide(
        //             color: borderColor ?? MyColors.borderColor,
        //             width: 1,
        //           ),
        //   borderRadius: BorderRadius.circular(12),
        // ),
        color: backgroundColor ?? MyColors.cardColor,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showCheck)
                    Icon(
                      checked
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked_outlined,
                      color:
                          checked
                              ? MyColors.selectedBorderColor
                              : MyColors.borderColor,
                    ),
                  if (showCheck) const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (textString != '')
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 0,
                              top: paddingTop,
                            ),
                            child: Text(
                              textString,
                              style:
                                  titleTextStyle ??
                                  TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                    color: titleColor ?? getTextColor(context),
                                  ),
                            ),
                          ),

                        hideChildWhenUnchecked
                            ? checked
                                ? child != null
                                    ? child!
                                    : SizedBox(height: 0)
                                : SizedBox(height: 0)
                            : child != null
                            ? child!
                            : SizedBox(height: 0),
                      ],
                    ),
                  ),
                ],
              ),
              if ((showAlwaysSubtitle || checked) && subtitleString != '')
                Text(
                  subtitleString,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: getTextColor(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

