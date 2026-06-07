class SalesProjectionPeriod {
  const SalesProjectionPeriod({
    required this.period,
    required this.units,
    required this.revenue,
  });

  final String period;
  final int units;
  final double revenue;
}

class SalesProjection {
  const SalesProjection({
    required this.id,
    required this.companyId,
    this.notes,
    this.periods = const [],
  });

  final int id;
  final int companyId;
  final String? notes;
  final List<SalesProjectionPeriod> periods;
}
