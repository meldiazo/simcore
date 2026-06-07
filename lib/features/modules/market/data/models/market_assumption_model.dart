import 'package:simcore_frontend/features/modules/market/domain/entities/market_assumption.dart';

class MarketAssumptionModel extends MarketAssumption {
  const MarketAssumptionModel({
    required super.id,
    required super.companyId,
    super.targetSegment,
    super.marketSizeEstimate,
    super.demandUnitsPerMonth,
    super.competitionDescription,
    super.estimatedUnitPrice,
    super.commercialJustification,
    super.hasMinimumData,
  });

  factory MarketAssumptionModel.fromJson(Map<String, dynamic> json) {
    return MarketAssumptionModel(
      id: _parseInt(json, 'id'),
      companyId: _parseInt(json, 'companyId'),
      targetSegment: json['targetSegment'] as String?,
      marketSizeEstimate: _parseDouble(json, 'marketSizeEstimate'),
      demandUnitsPerMonth: json['demandUnitsPerMonth'] is int
          ? json['demandUnitsPerMonth'] as int
          : null,
      competitionDescription: json['competitionDescription'] as String?,
      estimatedUnitPrice: _parseDouble(json, 'estimatedUnitPrice'),
      commercialJustification: json['commercialJustification'] as String?,
      hasMinimumData: json['hasMinimumData'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'targetSegment': targetSegment,
    'marketSizeEstimate': marketSizeEstimate,
    'demandUnitsPerMonth': demandUnitsPerMonth,
    'competitionDescription': competitionDescription,
    'estimatedUnitPrice': estimatedUnitPrice,
    'commercialJustification': commercialJustification,
  };

  static int _parseInt(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double? _parseDouble(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
