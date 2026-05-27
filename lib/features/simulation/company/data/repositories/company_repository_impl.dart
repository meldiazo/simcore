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
}
