class SalesProjection {
  final int monthlyDemand;
  final double estimatedPrice;
  final double projectedRevenue;
  final String scenario;

  SalesProjection({
    required this.monthlyDemand,
    required this.estimatedPrice,
    required this.projectedRevenue,
    required this.scenario,
  });
}