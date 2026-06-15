import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import '../../domain/entities/sales_projection.dart';

class SalesProjectionModel extends SalesProjection {
  SalesProjectionModel({
    required super.monthlyDemand,
    required super.estimatedPrice,
    required super.projectedRevenue,
    required super.scenario,
  });

  factory SalesProjectionModel.fromJson(Map<String, dynamic> json) {
    // 1. Buscamos en la raíz por si acaso
    int extractedDemand = _readInt(json, [
      'monthlyDemand',
      'demandUnitsPerMonth',
      'projectedMonthlyDemand',
      'unitsPerMonth'
    ]);
    double extractedPrice = _readDouble(
        json, ['estimatedPrice', 'estimatedUnitPrice', 'unitPrice', 'price']);

    // 2. Escarbamos directamente en el mes 1 sin condiciones raras
    if (json.containsKey('periods') &&
        json['periods'] != null &&
        (json['periods'] as List).isNotEmpty) {
      final firstPeriod = json['periods'][0] as Map<String, dynamic>;

      // Sobreescribimos con los datos reales del periodo
      if (extractedDemand == 0) {
        extractedDemand = _readInt(firstPeriod, ['demandUnits']);
      }
      if (extractedPrice == 0.0) {
        extractedPrice = _readDouble(firstPeriod, ['unitPrice']);
      }
    }

    return SalesProjectionModel(
      monthlyDemand: extractedDemand,
      estimatedPrice: extractedPrice,
      projectedRevenue: _readDouble(json,
          ['totalRevenue', 'projectedRevenue', 'monthlyRevenue', 'revenue']),
      scenario: _readString(
        json,
        ['scenarioType', 'scenario', 'type'],
        fallback: ScenarioType.probable.toApi(),
      ),
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
