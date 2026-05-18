import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OptionOfferWidget extends StatelessWidget {
  final String icon;
  final String title;
  final Color? colorFilter;
  const OptionOfferWidget({
    super.key,
    required this.icon,
    required this.title,
    this.colorFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: SvgPicture.asset(
            icon,
            semanticsLabel: ' ',
            fit: BoxFit.none,
            width: 10,
            height: 10,
            colorFilter:
                colorFilter != null
                    ? ColorFilter.mode(colorFilter!, BlendMode.srcIn)
                    : null,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: getTextColor(context),
          ),
        ),
      ],
    );
  }
}

