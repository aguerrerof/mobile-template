import 'package:flutter/material.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;

  const CustomStepper({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= currentStep;
          return Expanded(
            child: Container(
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? MyColors.btnColor : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }),
      ),
    );
  }
}

