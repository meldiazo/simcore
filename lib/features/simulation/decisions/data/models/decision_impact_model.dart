import 'package:simcore_frontend/features/simulation/decisions/entities/decision_impact.dart';

class DecisionImpactModel extends DecisionImpact {
  DecisionImpactModel({
    required super.impactId,
    required super.decisionId,
    required super.affectedModule,
    required super.description,
    required super.impactValue,
  });

  factory DecisionImpactModel.fromJson(Map<String, dynamic> json) {
    return DecisionImpactModel(
      impactId: json['impactId'] ?? '',
      decisionId: json['decisionId'] ?? '',
      affectedModule: json['affectedModule'] ?? '',
      description: json['description'] ?? '',
      impactValue: (json['impactValue'] ?? 0.0).toDouble(),
    );
  }
}