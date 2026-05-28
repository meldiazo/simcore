// CORRECCIÓN: Importación relativa para que siempre encuentre el archivo
import '../../domain/entities/scenario.dart';

class ScenarioVariableModel extends ScenarioVariable {
  const ScenarioVariableModel({
    required super.code,
    required super.name,
    required super.value,
    super.isLocked,
  });

  factory ScenarioVariableModel.fromJson(Map<String, dynamic> json) => ScenarioVariableModel(
    code: json['code'] ?? '',
    name: json['name'] ?? '',
    // Nos aseguramos de castear de forma segura el double desde el JSON
    value: (json['value'] ?? 0.0).toDouble(),
    isLocked: json['isLocked'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'value': value,
    'isLocked': isLocked,
  };
}

class ScenarioModel extends Scenario {
  const ScenarioModel({
    required super.id,
    required super.courseId,
    required super.name,
    required super.description,
    required super.type,
    super.isActive,
    super.variables,
  });

  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    return ScenarioModel(
      id: json['id'] ?? 0,
      courseId: json['courseId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: ScenarioType.values.firstWhere(
        (e) => e.name == json['type'], 
        orElse: () => ScenarioType.UNKNOWN
      ),
      isActive: json['isActive'] ?? false,
      variables: (json['variables'] as List?)
          ?.map((e) => ScenarioVariableModel.fromJson(e))
          .toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'name': name,
    'description': description,
    'type': type.name,
    'isActive': isActive,
    'variables': variables.map((v) => (v as ScenarioVariableModel).toJson()).toList(),
  };
}