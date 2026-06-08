import 'organization_area_model.dart';

class OrganizationSummaryModel {
  const OrganizationSummaryModel({
    required this.areas,
    required this.projectedDemand,
  });

  final List<OrganizationAreaModel> areas;
  final double projectedDemand;

  double get totalCapacity => areas.fold(
        0,
        (sum, area) =>
            sum +
            area.positions.fold(
              0,
              (areaSum, position) =>
                  areaSum +
                  ((position.capacityPerPerson ?? 0) * position.headcount),
            ),
      );

  double get totalMonthlyCost => areas.fold(
        0,
        (sum, area) =>
            sum +
            area.positions.fold(
              0,
              (areaSum, position) =>
                  areaSum + (position.monthlySalary * position.headcount),
            ),
      );
}
