import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';

class BenefitRow extends StatelessWidget {
  final Widget icon;
  final String text;

  const BenefitRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
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

