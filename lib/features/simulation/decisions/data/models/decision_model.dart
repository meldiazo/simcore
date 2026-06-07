import 'package:simcore_frontend/features/simulation/decisions/domain/entities/decision.dart';

class DecisionModel extends Decision {
  const DecisionModel({
    required super.id,
    required super.companyId,
    required super.module,
    required super.decisionType,
    required super.payload,
    required super.justification,
    required super.status,
    super.decisionVersion,
  });

  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    return DecisionModel(
      id: _parseInt(json, 'id'),
      companyId: _parseInt(json, 'companyId'),
      module: json['module']?.toString() ?? '',
      decisionType: json['decisionType']?.toString() ?? '',
      payload: json['payload']?.toString() ?? '',
      justification: json['justification']?.toString() ?? '',
      status: json['status']?.toString() ?? 'DRAFT',
      decisionVersion: _parseInt(json, 'decisionVersion', defaultValue: 1),
    );
  }

  static int _parseInt(Map<String, dynamic> json, String key, {int defaultValue = 0}) {
    final v = json[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? defaultValue;
    return defaultValue;
  }
}
