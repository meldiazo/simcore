import '../../domain/entities/sales_projection.dart';

class SalesProjectionModel extends SalesProjection {
  SalesProjectionModel({
    required super.monthlyDemand,
    required super.estimatedPrice,
    required super.projectedRevenue,
    required super.scenario,
  });

  factory SalesProjectionModel.fromJson(Map<String, dynamic> json) {
    return SalesProjectionModel(
      monthlyDemand: json['monthlyDemand'] ?? 0,
      estimatedPrice: (json['estimatedPrice'] ?? 0.0).toDouble(),
      projectedRevenue: (json['projectedRevenue'] ?? 0.0).toDouble(),
      scenario: json['scenario'] ?? '',
    );
  }
}