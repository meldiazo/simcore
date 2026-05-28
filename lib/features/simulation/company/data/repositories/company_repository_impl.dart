import 'package:simcore_frontend/features/simulation/company/data/datasources/company_remote_datasource.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/company.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/module_progress.dart';
import 'package:simcore_frontend/features/simulation/company/domain/repositories/company_repository.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  CompanyRepositoryImpl(this._dataSource);

  final CompanyRemoteDataSource _dataSource;

  @override
  Future<List<Company>> getCompaniesByGroup({required int groupId}) =>
      _dataSource.getCompaniesByGroup(groupId: groupId);

  @override
  Future<Company> getCompanyById({required int companyId}) =>
      _dataSource.getCompanyById(companyId: companyId);

  @override
  Future<List<CompanyModuleProgress>> getModuleProgress({
    required int companyId,
  }) =>
      _dataSource.getModuleProgress(companyId: companyId);

  @override
  Future<Map<String, dynamic>?> getActiveScenario({required int groupId}) =>
      _dataSource.getActiveScenario(groupId: groupId);

  @override
  Future<List<Map<String, dynamic>>> getIncoherences({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) =>
      _dataSource.getIncoherences(
        companyId: companyId,
        scenarioType: scenarioType,
      );

  @override
  Future<List<Map<String, dynamic>>> getDecisions({
    required int companyId,
  }) =>
      _dataSource.getDecisions(companyId: companyId);

  @override
  Future<Company> createCompany({
    required int groupId,
    required String name,
    required String sector,
    required String industry,
    required String description,
    required String mission,
    required String vision,
  }) =>
      _dataSource.createCompany(
        groupId: groupId,
        name: name,
        sector: sector,
        industry: industry,
        description: description,
        mission: mission,
        vision: vision,
      );

  @override
  Future<Company> activateCompany({required int companyId}) =>
      _dataSource.activateCompany(companyId: companyId);

  @override
  Future<Company> closeCompany({required int companyId, required String reason}) =>
      _dataSource.closeCompany(companyId: companyId, reason: reason);

  @override
  Future<void> linkGroupToCompany({required int groupId, required int companyId}) =>
      _dataSource.linkGroupToCompany(groupId: groupId, companyId: companyId);
}
