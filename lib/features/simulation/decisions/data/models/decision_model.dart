
import 'package:simcore_frontend/features/simulation/decisions/entities/decision.dart';

class DecisionModel extends Decision {
  DecisionModel({
    required super.id,
    required super.companyId,
    required super.module,
    required super.decisionType,
    required super.payload,
    required super.justification,
    super.createdAt,
  });

  factory DecisionModel.fromJson(Map<String, dynamic> json) {
    return DecisionModel(
      id: json['id'] ?? '',
      companyId: json['companyId'] ?? '',
      module: json['module'] ?? '',
      decisionType: json['decisionType'] ?? '',
      payload: json['payload'] ?? {},
      justification: json['justification'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'module': module,
      'decisionType': decisionType,
      'payload': payload,
      'justification': justification,
    };
  }
}