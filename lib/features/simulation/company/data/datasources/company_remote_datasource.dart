import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/simulation/company/data/models/company_model.dart';
import 'package:simcore_frontend/features/simulation/company/data/models/module_progress_model.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/company.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/module_progress.dart';

class CompanyRemoteDataSource {
  CompanyRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Company>> getCompaniesByGroup({required int groupId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies',
      queryParameters: {'groupId': groupId},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data)
          .map(CompanyModel.fromJson)
          .toList(),
    );
  }

  Future<Company> getCompanyById({required int companyId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId',
    );
    return result.fold(
      (e) => throw e,
      (data) => CompanyModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<List<CompanyModuleProgress>> getModuleProgress({
    required int companyId,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/modules',
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data)
          .map(CompanyModuleProgressModel.fromJson)
          .toList(),
    );
  }

  Future<Map<String, dynamic>?> getActiveScenario({
    required int groupId,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/scenarios/active',
      queryParameters: {'groupId': groupId},
    );
    return result.fold(
      (e) => throw e,
      (data) {
        if (data == null) return null;
        return Map<String, dynamic>.from(data as Map);
      },
    );
  }

  Future<List<Map<String, dynamic>>> getIncoherences({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/incoherences',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data),
    );
  }

  Future<List<Map<String, dynamic>>> getDecisions({
    required int companyId,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/decisions/company/$companyId',
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data),
    );
  }

  Future<Company> createCompany({
    required int groupId,
    required String name,
    required String sector,
    required String industry,
    required String description,
    required String mission,
    required String vision,
    required SimulationType simulationType,
  }) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies',
      data: {
        'groupId': groupId,
        'name': name,
        'sector': sector,
        'industry': industry,
        'description': description,
        'mission': mission,
        'vision': vision,
        'simulationType': simulationType.toApi(),
      },
    );
    return result.fold(
      (e) => throw e,
      (data) => CompanyModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Company> activateCompany({required int companyId}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/activate',
    );
    return result.fold(
      (e) => throw e,
      (data) => CompanyModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Company> closeCompany({required int companyId, required String reason}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/close',
      data: {'reason': reason},
    );
    return result.fold(
      (e) => throw e,
      (data) => CompanyModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<void> linkGroupToCompany({required int groupId, required int companyId}) async {
    final result = await _apiClient.patch(
      '/api/v1/iam/groups/$groupId/company',
      data: {'companyId': companyId},
    );
    result.fold((e) => throw e, (_) {});
  }

  Future<List<Company>> getCompaniesByCourse({required int courseId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies',
      queryParameters: {'courseId': courseId},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data)
          .map(CompanyModel.fromJson)
          .toList(),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      for (final key in ['data', 'content', 'items', 'modules', 'companies']) {
        final value = json[key];
        if (value is List) {
          return value
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
      }
    }
    return const [];
  }
}
