import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/simulation/scenario/domain/entities/scenario.dart';

class ScenarioVariableModel extends ScenarioVariable {
  const ScenarioVariableModel({
    required super.code,
    required super.value,
    super.displayName,
    super.unit,
    super.minValue,
    super.maxValue,
    super.locked,
    super.description,
  });

  factory ScenarioVariableModel.fromJson(Map<String, dynamic> json) {
    return ScenarioVariableModel(
      code: json['code'] as String? ?? '',
      value: json['value']?.toString() ?? '',
      displayName: json['displayName'] as String?,
      unit: json['unit'] as String?,
      minValue: _readDouble(json['minValue']),
      maxValue: _readDouble(json['maxValue']),
      locked: json['locked'] == true,
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
    super.groupsCanSeeEachOther,
    super.blockR1,
    super.blockR2,
    super.blockR3,
    super.blockR4,
    super.blockR5,
    super.blockR6,
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
      type: ScenarioType.fromApi(json['type']?.toString() ?? 'PROBABLE'),
      status: json['status']?.toString() ?? 'DRAFT',
      description: json['description'] as String?,
      variables: vars,
      groupsCanSeeEachOther: json['groupsCanSeeEachOther'] == true,
      blockR1: json['blockR1'] != false,
      blockR2: json['blockR2'] != false,
      blockR3: json['blockR3'] != false,
      blockR4: json['blockR4'] != false,
      blockR5: json['blockR5'] != false,
      blockR6: json['blockR6'] != false,
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

double? _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
