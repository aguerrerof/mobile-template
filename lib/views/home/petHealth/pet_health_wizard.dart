import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_scaffold.dart';
import 'package:mobile_app_template/components/nav_bar_header.dart';
import 'package:mobile_app_template/models/pet_health_models.dart';
import 'package:mobile_app_template/views/home/petHealth/components/navigation_buttons.dart';
import 'package:mobile_app_template/views/home/petHealth/components/step_data.dart';
import 'package:mobile_app_template/views/home/petHealth/components/step_pet_type.dart';
import 'package:mobile_app_template/views/home/petHealth/components/step_result.dart';
import 'package:mobile_app_template/views/home/petHealth/components/step_symptoms.dart';
import 'package:mobile_app_template/views/home/petHealth/components/stepper.dart';
import 'package:mobile_app_template/views/home/petHealth/pet_health_wizard_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class PetHealthWizard extends StatefulWidget {
  const PetHealthWizard({super.key});

  @override
  State<PetHealthWizard> createState() => _PetHealthWizardState();
}

class _PetHealthWizardState extends State<PetHealthWizard> {
  late PetHealthWizardViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = PetHealthWizardViewModel();
    // Cargar especies y condiciones médicas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchSpecies();
      viewModel.fetchMedicalConditions();
    });
  }

  @override
  void dispose() {
    viewModel.pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: viewModel,
      child: Consumer<PetHealthWizardViewModel>(
        builder: (context, vm, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {});

          return CustomScaffold(
            useSafeArea: true,
            child: Column(
              children: [
                NavBarHeader(
                  showBackButton: true,
                  showSearch: false,
                  showShoppingCart: false,
                  searchBelow: false,
                  showImageApp: false,
                  children: Center(
                    child: Text(
                      'Cuidados para tu mascota',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: MyColors.navBarText,
                      ),
                    ),
                  ),
                ),

                CustomStepper(currentStep: viewModel.currentStep),
                Expanded(
                  child: PageView(
                    controller: viewModel.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StepPetType(),
                      StepPetData(),
                      StepSymptoms(),
                      StepResult(),
                    ],
                  ),
                ),
                NavigationButtons(
                  currentStep: viewModel.currentStep,
                  onNext: () => viewModel.nextStep(context),
                  onBack: viewModel.previousStep,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

