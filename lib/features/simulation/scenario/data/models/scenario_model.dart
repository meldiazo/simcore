import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/simulation/scenario/domain/entities/scenario.dart';

class ScenarioVariableModel extends ScenarioVariable {
  const ScenarioVariableModel(
      {required super.code, required super.value, super.description});

  factory ScenarioVariableModel.fromJson(Map<String, dynamic> json) {
    return ScenarioVariableModel(
      code: json['code'] as String? ?? '',
      value: json['value']?.toString() ?? '',
      description: json['description'] as String?,
    );
  }
}

class ScenarioModel extends Scenario {
  const ScenarioModel({
    required super.id,
    required super.courseId,
    required super.name,
    required super.type,
    required super.status,
    super.description,
    super.variables,
  });

  factory ScenarioModel.fromJson(Map<String, dynamic> json) {
    final vars = (json['variables'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map(
            (v) => ScenarioVariableModel.fromJson(Map<String, dynamic>.from(v)))
        .toList();
    return ScenarioModel(
      id: json['id'] as int? ?? 0,
      courseId: json['courseId'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      type: ScenarioType.fromApi(
        json['type']?.toString() ?? ScenarioType.probable.toApi(),
      ),
      status: json['status']?.toString() ?? 'DRAFT',
      description: json['description'] as String?,
      variables: vars,
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'courseId': courseId,
        'name': name,
        'description': description,
        'type': type.toApi(),
        'variables': variables
            .map((v) => {
                  'code': v.code,
                  'value': v.value,
                  'description': v.description
                })
            .toList(),
      };
}
