class MarketAssumption {
  final String targetSegment;
  final double marketSizeEstimate;
  final int demandUnitsPerMonth;
  final String competitionDescription;
  final double estimatedUnitPrice;
  final String commercialJustification;

  MarketAssumption({
    required this.targetSegment,
    required this.marketSizeEstimate,
    required this.demandUnitsPerMonth,
    required this.competitionDescription,
    required this.estimatedUnitPrice,
    required this.commercialJustification,
  });
}