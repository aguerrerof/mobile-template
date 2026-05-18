import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/models/pet_health_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/petHealth/pet_health_wizard_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class StepPetType extends StatelessWidget {
  // final PetAssessment assessment;

  const StepPetType({super.key});

  PetType? _getPetTypeFromSpeciesKey(String key) {
    switch (key.toLowerCase()) {
      case 'dog':
      case 'perro':
        return PetType.dog;
      case 'cat':
      case 'gato':
        return PetType.cat;
      default:
        return null;
    }
  }

  String _getImageForSpecies(String key) {
    switch (key.toLowerCase()) {
      case 'dog':
      case 'perro':
        return 'assets/images/dog.png';
      case 'cat':
      case 'gato':
        return 'assets/images/cat.png';
      default:
        return 'assets/images/dog.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PetHealthWizardViewModel>();

    // Si hay especies de la API, usarlas; si no, usar las opciones por defecto
    final speciesList =
        viewModel.species.isNotEmpty
            ? viewModel.species
            : [
              Species(id: 1, key: 'dog', name: 'Perro'),
              Species(id: 2, key: 'cat', name: 'Gato'),
            ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '¿A quién revisamos hoy?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: getTextColor(context),
            ),
          ),
          const SizedBox(height: 24),

          if (viewModel.speciesLoading)
            const Center(child: CircularProgressIndicator())
          else
            Row(
              children:
                  speciesList.map((species) {
                    final petType = _getPetTypeFromSpeciesKey(species.key);
                    if (petType == null) return const SizedBox.shrink();

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right:
                              speciesList.indexOf(species) <
                                      speciesList.length - 1
                                  ? 8
                                  : 0,
                        ),
                        child: _PetTypeCard(
                          image: _getImageForSpecies(species.key),
                          label: species.name,
                          selected: viewModel.assessment.type == petType,
                          onTap: () => viewModel.updateAssessmentType(petType),
                          icon: null,
                        ),
                      ),
                    );
                  }).toList(),
            ),

          const SizedBox(height: 24),

          CustomTextField(
            title: 'Como se llama tu mascota?',
            placeholder: '',
            keyboardType: TextInputType.streetAddress,
            onChanged: (value) => viewModel.updateAssessmentName(value),
            initialValue: viewModel.assessment.name,
          ),
        ],
      ),
    );
  }
}

class _PetTypeCard extends StatelessWidget {
  final IconData? icon;
  final String? image;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PetTypeCard({
    this.icon,
    this.image,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: MyColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? MyColors.btnColor : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (icon != null)
                Icon(icon, size: 48)
              else if (image != null)
                Image.asset(image!, width: 48),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
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

