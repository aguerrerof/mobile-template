import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/components/custom_text_field.dart';
import 'package:mobile_app_template/models/pet_health_models.dart';
import 'package:mobile_app_template/utils/global_functions.dart';
import 'package:mobile_app_template/views/home/petHealth/components/gender_buttons.dart';
import 'package:mobile_app_template/views/home/petHealth/pet_health_wizard_view_model.dart';
import 'package:mobile_app_template/views/theme/extension_colors.dart';
import 'package:provider/provider.dart';

class StepPetData extends StatefulWidget {
  const StepPetData({super.key});

  @override
  State<StepPetData> createState() => _StepPetDataState();
}

class _StepPetDataState extends State<StepPetData> {
  final TextEditingController _breedController = TextEditingController();
  final FocusNode _breedFocusNode = FocusNode();
  bool _showBreedSuggestions = false;
  List<Breed> _filteredBreeds = [];
  String? _lastLoadedSpeciesKey;
  bool _isLoadingBreeds = false;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<PetHealthWizardViewModel>();
    _breedController.text = viewModel.assessment.breed;
    _breedFocusNode.addListener(() {
      if (_breedFocusNode.hasFocus) {
        // Cuando obtiene el foco, mostrar sugerencias si hay razas
        _showSuggestionsIfAvailable();
      } else {
        // Cuando pierde el foco, ocultar sugerencias después de un pequeño delay
        // para permitir que el usuario haga tap en una opción
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_breedFocusNode.hasFocus) {
            _onBreedFieldUnfocus();
          }
        });
      }
    });

    // Cargar razas si hay un tipo seleccionado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBreedsIfNeeded();
    });
  }

  void _showSuggestionsIfAvailable() {
    final viewModel = context.read<PetHealthWizardViewModel>();
    if (viewModel.breeds.isNotEmpty) {
      setState(() {
        _filteredBreeds = viewModel.breeds;
        _showBreedSuggestions = true;
      });
    }
  }

  void _loadBreedsIfNeeded() {
    if (_isLoadingBreeds) return; // Evitar múltiples llamadas simultáneas

    final viewModel = context.read<PetHealthWizardViewModel>();
    if (viewModel.assessment.type != null && !viewModel.breedsLoading) {
      final currentSpeciesKey = viewModel.assessment.type!.key;

      // Solo cargar si no se ha cargado para esta especie
      if (_lastLoadedSpeciesKey != currentSpeciesKey) {
        _lastLoadedSpeciesKey = currentSpeciesKey;
        _isLoadingBreeds = true;

        // Usar addPostFrameCallback para evitar llamadas durante el build
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted) {
            try {
              await viewModel.fetchBreeds(currentSpeciesKey);
            } finally {
              if (mounted) {
                setState(() {
                  _isLoadingBreeds = false;
                });
              }
            }
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _breedController.dispose();
    _breedFocusNode.dispose();
    super.dispose();
  }

  void _filterBreeds(String query) {
    final viewModel = context.read<PetHealthWizardViewModel>();
    setState(() {
      if (query.isEmpty) {
        _filteredBreeds = viewModel.breeds;
        // Mostrar todas las sugerencias si el campo tiene foco
        _showBreedSuggestions =
            _breedFocusNode.hasFocus && _filteredBreeds.isNotEmpty;
      } else {
        _filteredBreeds =
            viewModel.breeds
                .where(
                  (breed) =>
                      breed.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
        _showBreedSuggestions = _filteredBreeds.isNotEmpty;
      }
    });
  }

  void _selectBreed(Breed breed) {
    final viewModel = context.read<PetHealthWizardViewModel>();
    _breedController.text = breed.name;
    viewModel.updateAssessmentBreedFromSelection(breed.id, breed.name);
    setState(() {
      _showBreedSuggestions = false;
    });
    _breedFocusNode.unfocus();
  }

  void _onBreedFieldUnfocus() {
    // Al perder foco solo cerramos sugerencias; el texto se mantiene (libre o seleccionado).
    setState(() {
      _showBreedSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PetHealthWizardViewModel>();

    // Verificar si necesitamos cargar razas (solo una vez por especie)
    _loadBreedsIfNeeded();

    // Si las razas se cargaron y el campo tiene foco, mostrar sugerencias
    if (viewModel.breeds.isNotEmpty &&
        _breedFocusNode.hasFocus &&
        !_showBreedSuggestions &&
        _breedController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showSuggestionsIfAvailable();
        }
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Datos de ${viewModel.assessment.name}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              color: getTextColor(context),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                title: 'Raza',
                placeholder: 'Buscar raza...',
                controller: _breedController,
                focusNode: _breedFocusNode,
                suffix: Icon(Icons.search, color: getTextColor(context)),
                onChanged: (value) {
                  viewModel.updateAssessmentBreed(value);
                  _filterBreeds(value);
                },
                onTap: () {
                  _showSuggestionsIfAvailable();
                },
                inputAction: TextInputAction.done,
                onSubmit: (value) {
                  _onBreedFieldUnfocus();
                  FocusScope.of(context).unfocus();
                },
              ),
              if (_showBreedSuggestions && _filteredBreeds.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: MyColors.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredBreeds.length,
                      itemBuilder: (context, index) {
                        final breed = _filteredBreeds[index];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            title: Text(
                              breed.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                                color: getTextColor(context),
                              ),
                            ),
                            onTap: () => _selectBreed(breed),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          if (viewModel.breedsLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CircularProgressIndicator(),
            ),
          SizedBox(height: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      title: 'Edad',
                      placeholder: '',
                      keyboardType: TextInputType.number,
                      onChanged:
                          (value) => viewModel.updateAssessmentAge(value),
                      initialValue: viewModel.assessment.age,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? SizedBox(height: 8)
                            : SizedBox(height: 27),

                        Material(
                          color: MyColors.backgroundColor,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: MyColors.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              value: viewModel.assessment.ageUnit,
                              dropdownColor: MyColors.backgroundColor,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: getTextColor(context),
                              ),
                              items:
                                  ['months', 'years'].map((unit) {
                                    return DropdownMenuItem<String>(
                                      value: unit,
                                      child: Text(
                                        unit == 'months' ? 'Meses' : 'Años',
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  viewModel.updateAssessmentAgeUnit(value);
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      title: 'Peso - Opcional',
                      placeholder: '',
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {
                        // Validar peso mínimo de 0.1
                        if (value.isNotEmpty) {
                          final weightValue = double.tryParse(value);
                          if (weightValue != null && weightValue < 0.1) {
                            return; // No actualizar si es menor a 0.1
                          }
                        }
                        viewModel.updateAssessmentWeight(value);
                      },
                      initialValue: viewModel.assessment.weight,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Theme.of(context).platform == TargetPlatform.iOS
                            ? SizedBox(height: 8)
                            : SizedBox(height: 27),
                        Material(
                          color: MyColors.backgroundColor,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: MyColors.backgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                              value: viewModel.assessment.weightUnit,
                              dropdownColor: MyColors.backgroundColor,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                color: getTextColor(context),
                              ),
                              items:
                                  ['kg', 'g'].map((unit) {
                                    return DropdownMenuItem<String>(
                                      value: unit,
                                      child: Text(unit.toUpperCase()),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  viewModel.updateAssessmentWeightUnit(value);
                                  FocusScope.of(context).unfocus();
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 10),
          GenderCardGroup(
            selected: viewModel.assessment.gender,
            onSelect: (p) {
              viewModel.updateAssessmentGender(p);
              FocusScope.of(context).unfocus();
            },
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  '¿Está esterilizado?',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    color: getTextColor(context),
                  ),
                ),
              ),
              CupertinoSwitch(
                value: viewModel.assessment.isNeutered,
                onChanged: (value) {
                  viewModel.updateAssessmentIsNeutered(value);
                  FocusScope.of(context).unfocus();
                },
                activeTrackColor: MyColors.btnColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

