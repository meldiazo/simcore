import '../../domain/entities/market_assumption.dart';

class MarketAssumptionModel extends MarketAssumption {
  MarketAssumptionModel({
    required super.targetSegment,
    required super.marketSizeEstimate,
    required super.demandUnitsPerMonth,
    required super.competitionDescription,
    required super.estimatedUnitPrice,
    required super.commercialJustification,
  });

  factory MarketAssumptionModel.fromJson(Map<String, dynamic> json) {
    return MarketAssumptionModel(
      targetSegment: json['targetSegment'] ?? '',
      marketSizeEstimate: (json['marketSizeEstimate'] ?? 0.0).toDouble(),
      demandUnitsPerMonth: json['demandUnitsPerMonth'] ?? 0,
      competitionDescription: json['competitionDescription'] ?? '',
      estimatedUnitPrice: (json['estimatedUnitPrice'] ?? 0.0).toDouble(),
      commercialJustification: json['commercialJustification'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetSegment': targetSegment,
      'marketSizeEstimate': marketSizeEstimate,
      'demandUnitsPerMonth': demandUnitsPerMonth,
      'competitionDescription': competitionDescription,
      'estimatedUnitPrice': estimatedUnitPrice,
      'commercialJustification': commercialJustification,
    };
  }
}