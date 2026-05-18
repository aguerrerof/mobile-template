import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_template/Services/services_api.dart';
import 'package:mobile_app_template/components/custom_flushbar.dart';
import 'package:mobile_app_template/models/pet_health_models.dart';
import 'package:mobile_app_template/views/home/petHealth/components/gender_buttons.dart';

class PetHealthWizardViewModel extends ChangeNotifier {
  bool _loading = false;
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final PetAssessment _assessment = PetAssessment();

  List<Species> _species = [];
  List<Breed> _breeds = [];
  List<Symptom> _symptoms = [];
  List<MedicalCondition> _medicalConditions = [];
  bool _speciesLoading = false;
  bool _breedsLoading = false;
  bool _symptomsLoading = false;
  bool _medicalConditionsLoading = false;
  HealthInsightResponse? _healthInsight;
  bool? _healthInsightError = false;
  bool _healthInsightLoading = false;

  bool get loading => _loading;
  int get currentStep => _currentStep;
  PageController get pageController => _pageController;
  PetAssessment get assessment => _assessment;
  List<Species> get species => _species;
  List<Breed> get breeds => _breeds;
  List<Symptom> get symptoms => _symptoms;
  List<MedicalCondition> get medicalConditions => _medicalConditions;
  bool get speciesLoading => _speciesLoading;
  bool get breedsLoading => _breedsLoading;
  bool get symptomsLoading => _symptomsLoading;
  bool get medicalConditionsLoading => _medicalConditionsLoading;
  HealthInsightResponse? get healthInsight => _healthInsight;
  bool get healthInsightLoading => _healthInsightLoading;
  bool get healthInsightError => _healthInsightError ?? false;

  void updateLoading(bool state) {
    _loading = state;
    notifyListeners();
  }

  void updateAssessmentType(PetType type) {
    _assessment.type = type;
    // Cargar razas y síntomas cuando se selecciona un tipo
    fetchBreeds(type.key);
    fetchSymptoms(type.key);
    notifyListeners();
  }

  void updateAssessmentName(String name) {
    _assessment.name = name;
    notifyListeners();
  }

  void updateAssessmentBreed(String breed) {
    _assessment.breed = breed;
    _assessment.breedId = null; // texto ingresado → se envía como "breed"
    notifyListeners();
  }

  void updateAssessmentBreedFromSelection(int breedId, String breedName) {
    _assessment.breedId = breedId;
    _assessment.breed = breedName;
    notifyListeners();
  }

  void updateAssessmentAge(String age) {
    _assessment.age = age;
    notifyListeners();
  }

  void updateAssessmentAgeUnit(String ageUnit) {
    _assessment.ageUnit = ageUnit;
    notifyListeners();
  }

  void updateAssessmentWeight(String weight) {
    _assessment.weight = weight;
    notifyListeners();
  }

  void updateAssessmentWeightUnit(String weightUnit) {
    _assessment.weightUnit = weightUnit;
    notifyListeners();
  }

  void updateAssessmentGender(PetGender gender) {
    _assessment.gender = gender;
    notifyListeners();
  }

  void updateAssessmentSymptoms(String symptom) {
    if (_assessment.symptoms.contains(symptom)) {
      _assessment.symptoms.remove(symptom);
    } else {
      _assessment.symptoms.add(symptom);
    }

    notifyListeners();
  }

  void updateAssessmentOtherSymptoms(String symptom) {
    _assessment.otherSymptoms = symptom;
  }

  String? validateCurrentStep() {
    switch (_currentStep) {
      case 0: // StepPetType
        if (_assessment.type == null) {
          return 'Por favor selecciona el tipo de mascota';
        }
        if (_assessment.name.trim().isEmpty) {
          return 'Por favor ingresa el nombre de tu mascota';
        }
      case 1: // StepPetData
        if (_assessment.breed.trim().isEmpty) {
          return 'Por favor ingresa o selecciona la raza';
        }
        if (_assessment.age.trim().isEmpty) {
          return 'Por favor ingresa la edad de tu mascota';
        }
        if (_assessment.gender == null) {
          return 'Por favor selecciona el género de tu mascota';
        }
      case 2: // StepSymptoms
        if (_assessment.symptoms.isEmpty &&
            _assessment.otherSymptoms.trim().isEmpty) {
          return 'Por favor selecciona al menos un síntoma o describe otros síntomas';
        }
      case 3: // StepResult
        // No hay validación en el último paso
        break;
    }
    return null; // Sin errores
  }

  void nextStep(BuildContext? context) {
    // Minimizar el teclado si está activo
    if (context != null) {
      FocusScope.of(context).unfocus();
    }

    if (currentStep < 3) {
      final error = validateCurrentStep();
      if (error != null) {
        // Mostrar mensaje de error si hay contexto
        if (context != null) {
          _showError(context, error);
        }
        return; // No avanzar si hay errores
      }

      _currentStep = currentStep + 1;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    } else {
      if (context != null) {
        Navigator.of(context).pop();
      }
    }
  }

  void _showError(BuildContext context, String message) {
    showCustomFlushbar(context, message: message);
  }

  void previousStep() {
    if (currentStep > 0) {
      _currentStep = currentStep - 1;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      notifyListeners();
    }
  }

  Future<void> fetchSpecies() async {
    _speciesLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getSpecies();
      if (result.success) {
        _species = result.data ?? [];
      } else {
        print('Error al obtener especies: ${result.getError()}');
      }
    } catch (e) {
      print('Error al obtener especies: $e');
    } finally {
      _speciesLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBreeds(String speciesKey) async {
    _breedsLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getBreeds(speciesKey);
      if (result.success) {
        _breeds = result.data ?? [];
      } else {
        print('Error al obtener razas: ${result.getError()}');
      }
    } catch (e) {
      print('Error al obtener razas: $e');
    } finally {
      _breedsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSymptoms(String speciesKey) async {
    _symptomsLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getSymptoms(speciesKey);
      if (result.success) {
        // Filtrar solo síntomas activos
        _symptoms = (result.data ?? []).where((s) => s.active).toList();
      } else {
        print('Error al obtener síntomas: ${result.getError()}');
      }
    } catch (e) {
      print('Error al obtener síntomas: $e');
    } finally {
      _symptomsLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMedicalConditions() async {
    _medicalConditionsLoading = true;
    notifyListeners();

    try {
      final result = await ServicesAPI().getMedicalConditions();
      if (result.success) {
        _medicalConditions = result.data ?? [];
      } else {
        print('Error al obtener condiciones médicas: ${result.getError()}');
      }
    } catch (e) {
      print('Error al obtener condiciones médicas: $e');
    } finally {
      _medicalConditionsLoading = false;
      notifyListeners();
    }
  }

  void updateAssessmentIsNeutered(bool value) {
    _assessment.isNeutered = value;
    notifyListeners();
  }

  void updateAssessmentMedicalCondition(String condition) {
    if (_assessment.medicalConditions.contains(condition)) {
      _assessment.medicalConditions.remove(condition);
    } else {
      _assessment.medicalConditions.add(condition);
    }
    notifyListeners();
  }

  Future<void> fetchHealthInsight() async {
    // if (_assessment.type == null ||
    //     _assessment.breed.isEmpty ||
    //     _assessment.gender == null) {
    //   print('Faltan datos requeridos para obtener el análisis');
    //   return;
    // }
    _healthInsightError = false;
    _healthInsightLoading = true;
    _healthInsight = null;
    notifyListeners();

    try {
      final selectedSpecies = _species.firstWhere(
        (s) => s.key == _assessment.type!.key,
        orElse: () => Species(id: 0, key: _assessment.type!.key, name: ''),
      );

      // Raza: si hay breedId (selección de lista) → breed_id; si no → breed (texto)
      final payload = <String, dynamic>{
        'species_id': selectedSpecies.id,
        'sex': _assessment.gender == PetGender.male ? 'male' : 'female',
        'is_neutered': _assessment.isNeutered,
        'age':
            _assessment.age.isNotEmpty
                ? double.tryParse(_assessment.age)
                : null,
        'age_unit': _assessment.ageUnit,
        'weight':
            _assessment.weight.isNotEmpty
                ? double.tryParse(_assessment.weight)
                : null,
        'weight_unit': _assessment.weightUnit,
      };
      if (_assessment.breedId != null) {
        payload['breed_id'] = _assessment.breedId;
      } else {
        payload['breed'] = _assessment.breed.trim();
      }

      // Convertir nombres de síntomas a IDs
      final symptomIds =
          _assessment.symptoms
              .map((symptomName) {
                try {
                  return _symptoms.firstWhere((s) => s.name == symptomName).id;
                } catch (e) {
                  return null;
                }
              })
              .where((id) => id != null)
              .cast<int>()
              .toList();

      // Convertir nombres de condiciones médicas a IDs
      final medicalConditionIds =
          _assessment.medicalConditions
              .map((conditionName) {
                try {
                  return _medicalConditions
                      .firstWhere((c) => c.name == conditionName)
                      .id;
                } catch (e) {
                  return null;
                }
              })
              .where((id) => id != null)
              .cast<int>()
              .toList();

      payload['symptoms'] = symptomIds;
      payload['medical_conditions'] = medicalConditionIds;
      payload['extra_symptoms'] = _assessment.otherSymptoms;

      final result = await ServicesAPI().getHealthInsight(payload);

      if (result.success && result.data != null) {
        _healthInsight = result.data;
      } else {
        print('Error al obtener análisis: ${result.getError()}');
        _healthInsightError = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error al obtener análisis de salud: $e');
      _healthInsightError = true;
      notifyListeners();
    } finally {
      _healthInsightLoading = false;
      notifyListeners();
    }
  }
}

