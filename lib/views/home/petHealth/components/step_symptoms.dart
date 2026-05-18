import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_chip.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/models/pet_health_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/petHealth/pet_health_wizard_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class StepSymptoms extends StatefulWidget {
  const StepSymptoms({super.key});

  @override
  State<StepSymptoms> createState() => _StepSymptomsState();
}

class _StepSymptomsState extends State<StepSymptoms> {
  late PetHealthWizardViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read<PetHealthWizardViewModel>();
    // Cargar síntomas y condiciones médicas cuando se entra al step
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.assessment.type != null) {
        viewModel.fetchSymptoms(viewModel.assessment.type!.key);
      }
      if (viewModel.medicalConditions.isEmpty &&
          !viewModel.medicalConditionsLoading) {
        viewModel.fetchMedicalConditions();
      }
    });
  }

  void toggleSymptom(String symptom) {
    viewModel.updateAssessmentSymptoms(symptom);
  }

  @override
  Widget build(BuildContext context) {
    viewModel = context.watch<PetHealthWizardViewModel>();

    // Usar síntomas de la API si están disponibles, si no usar lista vacía
    final symptomsList =
        viewModel.symptoms.isNotEmpty
            ? viewModel.symptoms.map((s) => s.name).toList()
            : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Síntomas observados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),

          if (viewModel.symptomsLoading)
            const Center(child: CircularProgressIndicator())
          else if (symptomsList.isEmpty)
            Text(
              'No hay síntomas disponibles. Por favor selecciona un tipo de mascota primero.',
              style: TextStyle(
                fontSize: 14,
                color: getTextColor(context)?.withOpacity(0.6) ?? Colors.grey,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  symptomsList.map((s) {
                    return CustomChoiceChip(
                      label: s,
                      selected: viewModel.assessment.symptoms.contains(s),
                      onTap: () => toggleSymptom(s),
                      selectedColor: MyColors.cardColor,
                    );
                  }).toList(),
            ),

          if (viewModel.medicalConditions.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Condiciones médicas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
                color: getTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            if (viewModel.medicalConditionsLoading)
              const Center(child: CircularProgressIndicator())
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    viewModel.medicalConditions.map((condition) {
                      return CustomChoiceChip(
                        label: condition.name,
                        selected: viewModel.assessment.medicalConditions
                            .contains(condition.name),
                        onTap:
                            () => viewModel.updateAssessmentMedicalCondition(
                              condition.name,
                            ),
                        selectedColor: MyColors.cardColor,
                      );
                    }).toList(),
              ),
          ],

          const SizedBox(height: 16),
          CustomTextField(
            // controller: controller,
            title: '',
            placeholder: 'Otros síntomas? Describelos aquí',
            keyboardType: TextInputType.text,
            onChanged:
                (value) => viewModel.updateAssessmentOtherSymptoms(value),
            initialValue: viewModel.assessment.otherSymptoms,
          ),
          // TextField(
          //   controller: controller,
          //   maxLines: 3,
          //   decoration: const InputDecoration(
          //     hintText: '',
          //     border: OutlineInputBorder(),
          //   ),
          // ),
        ],
      ),
    );
  }
}

