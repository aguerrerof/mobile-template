import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';

enum PetGender { male, female }

class GenderCardGroup extends StatelessWidget {
  final PetGender? selected;
  final ValueChanged<PetGender> onSelect;

  const GenderCardGroup({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sexo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: 'Poppins',
            color: getTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _GenderCard(
              label: 'Macho',
              icon: Icons.male,
              selected: selected == PetGender.male,
              onTap: () => onSelect(PetGender.male),
            ),
            const SizedBox(width: 12),
            _GenderCard(
              label: 'Hembra',
              icon: Icons.female,
              selected: selected == PetGender.female,
              onTap: () => onSelect(PetGender.female),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyColors.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? MyColors.btnColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 32, color: getTextColor(context)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
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

