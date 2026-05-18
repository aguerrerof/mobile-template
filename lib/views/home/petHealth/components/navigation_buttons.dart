import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_button.dart';

class NavigationButtons extends StatelessWidget {
  final int currentStep;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const NavigationButtons({
    required this.currentStep,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: CustomButton(
                onPressed: onBack,
                label: 'Atrás',
                type: CustomButtonType.outline,
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              onPressed: onNext,
              label: currentStep == 3 ? 'Finalizar' : 'Continuar',
              type: CustomButtonType.filled,
            ),
          ),
        ],
      ),
    );
  }
}

