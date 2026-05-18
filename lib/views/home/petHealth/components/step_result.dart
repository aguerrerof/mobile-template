import 'package:flutter/material.dart';
import 'package:mobile_app_template/models/pet_health_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/petHealth/pet_health_wizard_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class StepResult extends StatefulWidget {
  const StepResult({super.key});

  @override
  State<StepResult> createState() => _StepResultState();
}

class _StepResultState extends State<StepResult> {
  @override
  void initState() {
    super.initState();
    // Llamar al servicio cuando se monta el widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<PetHealthWizardViewModel>();
      if (!viewModel.healthInsightLoading) {
        viewModel.fetchHealthInsight();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PetHealthWizardViewModel>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultado para ${viewModel.assessment.name}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: getTextColor(context),
            ),
          ),
          const SizedBox(height: 16),

          if (viewModel.healthInsightLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: MyColors.btnColor),
              ),
            ),
          if (viewModel.healthInsight != null)
            _buildHealthInsightContent(viewModel.healthInsight!.output),

          if (viewModel.healthInsightError)
            Card(
              color: MyColors.backgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No se pudo obtener el análisis de salud. Por favor intenta nuevamente.',
                  style: TextStyle(fontSize: 16, color: getTextColor(context)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'home':
        return Colors.green;
      case 'soon':
        return Colors.orange;
      case 'urgent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLevelText(String level) {
    switch (level.toLowerCase()) {
      case 'home':
        return 'Cuidado en casa';
      case 'soon':
        return 'Consulta pronto';
      case 'urgent':
        return 'Consulta urgente';
      default:
        return level.toUpperCase();
    }
  }

  Widget _buildHealthInsightContent(HealthInsightOutput output) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección 1: Recommendation Card
        Card(
          color: MyColors.backgroundColor,
          child: Container(
            decoration: BoxDecoration(
              color: MyColors.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getLevelColor(output.recommendation.level),
                width: 2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getLevelColor(
                            output.recommendation.level,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getLevelText(output.recommendation.level),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _getLevelColor(output.recommendation.level),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    output.recommendation.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: getTextColor(context),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    output.recommendation.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: getTextColor(context),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Sección 2: Justification Card
        Card(
          color: MyColors.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Justificación',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: getTextColor(context),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  output.justification,
                  style: TextStyle(
                    fontSize: 14,
                    color: getTextColor(context),
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Sección 3: Possible Conditions List
        Text(
          'Posibles Condiciones',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: getTextColor(context),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 8),
        if (output.possibleConditions.isEmpty)
          Card(
            color: MyColors.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'No se identificaron posibles condiciones.',
                style: TextStyle(
                  fontSize: 14,
                  color: getTextColor(context),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          )
        else
          ...output.possibleConditions.map((condition) {
            return Card(
              color: MyColors.backgroundColor,
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            condition.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: getTextColor(context),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Probabilidad: ${condition.probability}',
                            style: TextStyle(
                              fontSize: 12,
                              color: (getTextColor(context) ?? Colors.black)
                                  .withOpacity(0.7),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),

        // Disclaimer si existe
        if (output.disclaimer != null && output.disclaimer!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            color: MyColors.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                output.disclaimer!,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: (getTextColor(context) ?? Colors.black).withOpacity(
                    0.7,
                  ),
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

