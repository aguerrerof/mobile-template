import 'package:mobile_app_template/views/home/petHealth/components/gender_buttons.dart';

enum PetType { dog, cat }

extension PetTypeExtension on PetType {
  String get key {
    switch (this) {
      case PetType.dog:
        return 'dog';
      case PetType.cat:
        return 'cat';
    }
  }
}

class Species {
  final int id;
  final String key;
  final String name;

  Species({required this.id, required this.key, required this.name});

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      id: json['id'] ?? 0,
      key: json['key'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'key': key, 'name': name};
  }
}

class Breed {
  final int id;
  final String name;
  final bool isOther;

  Breed({required this.id, required this.name, required this.isOther});

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isOther: json['is_other'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_other': isOther};
  }
}

class Symptom {
  final int id;
  final String name;
  final String? category;
  final String speciesKey;
  final bool isOther;
  final bool active;

  Symptom({
    required this.id,
    required this.name,
    this.category,
    required this.speciesKey,
    required this.isOther,
    required this.active,
  });

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'],
      speciesKey: json['species_key'] ?? '',
      isOther: json['is_other'] ?? false,
      active: json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'species_key': speciesKey,
      'is_other': isOther,
      'active': active,
    };
  }
}

class MedicalCondition {
  final int id;
  final String name;
  final bool isOther;

  MedicalCondition({
    required this.id,
    required this.name,
    required this.isOther,
  });

  factory MedicalCondition.fromJson(Map<String, dynamic> json) {
    return MedicalCondition(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      isOther: json['is_other'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'is_other': isOther};
  }
}

class PetAssessment {
  PetType? type;
  String name = '';
  String breed = '';
  /// ID de raza cuando se selecciona de la lista; null si se ingresa texto libre.
  int? breedId;
  String age = '';
  String ageUnit = 'years'; // 'months' or 'years'
  String weight = '';
  String weightUnit = 'kg'; // 'kg' or 'g'
  PetGender? gender;
  bool isNeutered = false;
  List<String> symptoms = [];
  List<String> medicalConditions = [];
  String otherSymptoms = '';
}

class PossibleCondition {
  final String name;
  final String probability;

  PossibleCondition({required this.name, required this.probability});

  factory PossibleCondition.fromJson(Map<String, dynamic> json) {
    return PossibleCondition(
      name: json['name'] ?? '',
      probability: json['probability'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'probability': probability};
  }
}

class Recommendation {
  final String level; // 'home', 'soon', 'urgent'
  final String title;
  final String description;

  Recommendation({
    required this.level,
    required this.title,
    required this.description,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      level: json['level'] ?? 'home',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'level': level, 'title': title, 'description': description};
  }
}

class HealthInsightOutput {
  final Recommendation recommendation;
  final String justification;
  final List<PossibleCondition> possibleConditions;
  final String? disclaimer;

  HealthInsightOutput({
    required this.recommendation,
    required this.justification,
    required this.possibleConditions,
    this.disclaimer,
  });

  factory HealthInsightOutput.fromJson(Map<String, dynamic> json) {
    return HealthInsightOutput(
      recommendation: Recommendation.fromJson(json['recommendation'] ?? {}),
      justification: json['justification'] ?? '',
      possibleConditions:
          (json['possible_conditions'] as List<dynamic>?)
              ?.map(
                (item) =>
                    PossibleCondition.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      disclaimer: json['disclaimer'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendation': recommendation.toJson(),
      'justification': justification,
      'possible_conditions': possibleConditions.map((c) => c.toJson()).toList(),
      if (disclaimer != null) 'disclaimer': disclaimer,
    };
  }
}

class HealthInsightResponse {
  final bool cached;
  final HealthInsightOutput output;

  HealthInsightResponse({required this.cached, required this.output});

  factory HealthInsightResponse.fromJson(Map<String, dynamic> json) {
    return HealthInsightResponse(
      cached: json['cached'] ?? false,
      output: HealthInsightOutput.fromJson(json['output'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'cached': cached, 'output': output.toJson()};
  }
}

