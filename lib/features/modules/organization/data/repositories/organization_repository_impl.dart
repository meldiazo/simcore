import 'package:simcore_frontend/core/domain/simcore_enums.dart';

import '../models/organization_area_model.dart';
import '../models/organization_position_model.dart';
import '../datasources/organization_remote_datasource.dart';

class OrganizationRepositoryImpl {
  final OrganizationRemoteDataSource remoteDataSource;

  OrganizationRepositoryImpl({required this.remoteDataSource});

  Future<List<OrganizationAreaModel>> getOrganization(
    String companyId, {
    String? scenarioType,
  }) async {
    final summary = await remoteDataSource.getSummary(
      companyId: int.tryParse(companyId) ?? 0,
      scenarioType: scenarioType ?? ScenarioType.probable.toApi(),
    );
    return summary.areas
        .map((area) => OrganizationAreaModel(
              areaId: area.id.toString(),
              name: area.name,
              description: area.description,
              positions: summary.positions
                  .where((position) => position.areaId == area.id)
                  .map((position) => OrganizationPositionModel(
                        id: position.id.toString(),
                        areaId: position.areaId.toString(),
                        title: position.title,
                        responsibilities: position.responsibilities,
                        headcount: position.headcount,
                        monthlySalary: position.monthlySalary,
                        capacityPerPerson: position.capacityPerPerson,
                      ))
                  .toList(),
            ))
        .toList();
  }

  Future<void> createArea(String companyId, OrganizationAreaModel area) async {
    await remoteDataSource.createArea(
      companyId: int.tryParse(companyId) ?? 0,
      data: area.toJson(),
    );
  }

  Future<void> createPosition(
      String companyId, OrganizationPositionModel position) async {
    await remoteDataSource.createPosition(
      companyId: int.tryParse(companyId) ?? 0,
      data: position.toJson(),
    );
  }

  Future<void> deletePosition(String companyId, String positionId) async {
    await remoteDataSource.deletePosition(
      companyId: int.tryParse(companyId) ?? 0,
      positionId: int.tryParse(positionId) ?? 0,
    );
  }

  Future<void> completeModule(String companyId) async {
    await remoteDataSource.completeModule(
      companyId: int.tryParse(companyId) ?? 0,
    );
  }
}
