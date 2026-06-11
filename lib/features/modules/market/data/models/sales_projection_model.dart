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
      monthlyDemand: _readInt(json, [
        'monthlyDemand',
        'demandUnitsPerMonth',
        'projectedMonthlyDemand',
        'unitsPerMonth',
      ]),
      estimatedPrice: _readDouble(json, [
        'estimatedPrice',
        'estimatedUnitPrice',
        'unitPrice',
        'price',
      ]),
      projectedRevenue: _readDouble(json, [
        'projectedRevenue',
        'monthlyRevenue',
        'totalRevenue',
        'revenue',
      ]),
      scenario: _readString(json, [
        'scenario',
        'scenarioType',
        'type',
      ], fallback: 'PROBABLE'),
    );
  }

  static int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  static double _readDouble(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value is double) return value;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
    }

    return 0.0;
  }

  static String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];

      if (value != null) return value.toString();
    }

    return fallback;
  }
}