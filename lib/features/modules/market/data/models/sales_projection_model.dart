import 'package:simcore_frontend/features/modules/market/domain/entities/sales_projection.dart';

class SalesProjectionPeriodModel extends SalesProjectionPeriod {
  const SalesProjectionPeriodModel({
    required super.period,
    required super.units,
    required super.revenue,
  });

  factory SalesProjectionPeriodModel.fromJson(Map<String, dynamic> json) {
    return SalesProjectionPeriodModel(
      period: json['period']?.toString() ?? '',
      units: json['units'] is int ? json['units'] as int : 0,
      revenue: _parseDouble(json, 'revenue'),
    );
  }

  static double _parseDouble(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}

class SalesProjectionModel extends SalesProjection {
  const SalesProjectionModel({
    required super.id,
    required super.companyId,
    super.notes,
    super.periods,
  });

  factory SalesProjectionModel.fromJson(Map<String, dynamic> json) {
    final periods = (json['periods'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((p) => SalesProjectionPeriodModel.fromJson(Map<String, dynamic>.from(p)))
        .toList();
    return SalesProjectionModel(
      id: _parseInt(json, 'id'),
      companyId: _parseInt(json, 'companyId'),
      notes: json['notes'] as String?,
      periods: periods,
    );
  }

  static int _parseInt(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}
