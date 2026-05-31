import '../models/organization_area_model.dart';
import '../models/organization_position_model.dart';
import '../datasources/organization_remote_datasource.dart';

class OrganizationRepositoryImpl {
  final OrganizationRemoteDatasource remoteDataSource;

  OrganizationRepositoryImpl({required this.remoteDataSource});

  Future<List<OrganizationAreaModel>> getOrganization(String companyId) async {
    return await remoteDataSource.getOrganization(companyId);
  }

  Future<void> createArea(String companyId, OrganizationAreaModel area) async {
    await remoteDataSource.createArea(companyId, area);
  }

  Future<void> createPosition(String companyId, OrganizationPositionModel position) async {
    await remoteDataSource.createPosition(companyId, position);
  }

  Future<void> deletePosition(String companyId, String positionId) async {
    await remoteDataSource.deletePosition(companyId, positionId);
  }

  Future<void> completeModule(String companyId) async {
    await remoteDataSource.completeModule(companyId);
  }
}