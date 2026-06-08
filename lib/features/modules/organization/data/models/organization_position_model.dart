class OrganizationPositionModel {
  const OrganizationPositionModel({
    this.id,
    required this.areaId,
    required this.title,
    this.responsibilities,
    required this.headcount,
    required this.monthlySalary,
    this.capacityPerPerson,
  });

  final String? id;
  final String areaId;
  final String title;
  final String? responsibilities;
  final int headcount;
  final double monthlySalary;
  final double? capacityPerPerson;

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'areaId': areaId,
        'title': title,
        'responsibilities': responsibilities,
        'headcount': headcount,
        'monthlySalary': monthlySalary,
        'capacityPerPerson': capacityPerPerson,
      };
}
