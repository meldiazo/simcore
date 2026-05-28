class OrganizationArea {
  const OrganizationArea({
    required this.id,
    required this.companyId,
    required this.name,
    this.description,
  });

  final int id;
  final int companyId;
  final String name;
  final String? description;
}

class OrganizationPosition {
  const OrganizationPosition({
    required this.id,
    required this.areaId,
    required this.title,
    this.responsibilities,
    required this.headcount,
    required this.monthlySalary,
    this.capacityPerPerson,
  });

  final int id;
  final int areaId;
  final String title;
  final String? responsibilities;
  final int headcount;
  final double monthlySalary;
  final double? capacityPerPerson;
}

class OrganizationSummary {
  const OrganizationSummary({
    required this.companyId,
    required this.areas,
    required this.positions,
    required this.monthlyPersonnelCost,
    required this.estimatedMonthlyCapacity,
    required this.projectedMonthlyDemand,
    required this.warnings,
  });

  final int companyId;
  final List<OrganizationArea> areas;
  final List<OrganizationPosition> positions;
  final double monthlyPersonnelCost;
  final double estimatedMonthlyCapacity;
  final double projectedMonthlyDemand;
  final List<String> warnings;
}
