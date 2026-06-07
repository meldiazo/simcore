class MarketAssumption {
  const MarketAssumption({
    required this.id,
    required this.companyId,
    this.targetSegment,
    this.marketSizeEstimate,
    this.demandUnitsPerMonth,
    this.competitionDescription,
    this.estimatedUnitPrice,
    this.commercialJustification,
    this.hasMinimumData = false,
  });

  final int id;
  final int companyId;
  final String? targetSegment;
  final double? marketSizeEstimate;
  final int? demandUnitsPerMonth;
  final String? competitionDescription;
  final double? estimatedUnitPrice;
  final String? commercialJustification;
  final bool hasMinimumData;
}
