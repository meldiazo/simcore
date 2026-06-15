import 'package:simcore_frontend/features/simulation/company/domain/entities/company.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/module_progress.dart';

abstract class CompanyRepository {
  Future<List<Company>> getCompaniesByGroup({required int groupId});

  Future<Company> getCompanyById({required int companyId});

  Future<List<CompanyModuleProgress>> getModuleProgress({
    required int companyId,
  });

  Future<Map<String, dynamic>?> getActiveScenario({required int groupId});

  Future<List<Map<String, dynamic>>> getIncoherences({
    required int companyId,
    required String scenarioType,
  });

  Future<List<Map<String, dynamic>>> getDecisions({
    required int companyId,
  });

  Future<Company> createCompany({
    required int groupId,
    required String name,
    required String sector,
    required String industry,
    required String description,
    required String mission,
    required String vision,
  });

  Future<Company> activateCompany({required int companyId});

  Future<Company> closeCompany(
      {required int companyId, required String reason});

  Future<void> linkGroupToCompany(
      {required int groupId, required int companyId});

  Future<List<Company>> getCompaniesByCourse({required int courseId});
}
