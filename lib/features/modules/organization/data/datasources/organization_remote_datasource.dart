import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/modules/organization/domain/entities/organization_area.dart';

class OrganizationRemoteDataSource {
  OrganizationRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<OrganizationSummary> getSummary({required int companyId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/organization/summary',
    );
    return result.fold(
      (e) => throw e,
      (data) => _parseSummary(companyId, data),
    );
  }

  Future<OrganizationArea> createArea({
    required int companyId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/organization/areas',
      data: data,
    );
    return result.fold(
      (e) => throw e,
      (d) => _parseArea(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<OrganizationArea> updateArea({
    required int companyId,
    required int areaId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/organization/areas/$areaId',
      data: data,
    );
    return result.fold(
      (e) => throw e,
      (d) => _parseArea(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<OrganizationPosition> createPosition({
    required int companyId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/organization/positions',
      data: data,
    );
    return result.fold(
      (e) => throw e,
      (d) => _parsePosition(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<OrganizationPosition> updatePosition({
    required int companyId,
    required int positionId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/organization/positions/$positionId',
      data: data,
    );
    return result.fold(
      (e) => throw e,
      (d) => _parsePosition(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<void> deletePosition({required int companyId, required int positionId}) async {
    final result = await _apiClient.delete(
      '/api/v1/simulation/companies/$companyId/organization/positions/$positionId',
    );
    result.fold((e) => throw e, (_) {});
  }

  Future<void> completeModule({required int companyId}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/organization/complete',
    );
    result.fold((e) => throw e, (_) {});
  }

  OrganizationArea _parseArea(Map<String, dynamic> json) {
    return OrganizationArea(
      id: _parseInt(json, 'id'),
      companyId: _parseInt(json, 'companyId'),
      name: json['name']?.toString() ?? '',
      description: json['description'] as String?,
    );
  }

  OrganizationPosition _parsePosition(Map<String, dynamic> json) {
    return OrganizationPosition(
      id: _parseInt(json, 'id'),
      areaId: _parseInt(json, 'areaId'),
      title: json['title']?.toString() ?? '',
      responsibilities: json['responsibilities'] as String?,
      headcount: _parseInt(json, 'headcount'),
      monthlySalary: _parseDouble(json, 'monthlySalary'),
      capacityPerPerson: json['capacityPerPerson'] != null
          ? _parseDouble(json, 'capacityPerPerson')
          : null,
    );
  }

  OrganizationSummary _parseSummary(int companyId, dynamic data) {
    if (data == null) {
      return OrganizationSummary(
        companyId: companyId,
        areas: const [],
        positions: const [],
        monthlyPersonnelCost: 0,
        estimatedMonthlyCapacity: 0,
        projectedMonthlyDemand: 0,
        warnings: const [],
      );
    }
    final json = Map<String, dynamic>.from(data as Map);
    final areas = (json['areas'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => _parseArea(Map<String, dynamic>.from(e)))
        .toList();
    final positions = (json['positions'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((e) => _parsePosition(Map<String, dynamic>.from(e)))
        .toList();
    final warnings = (json['warnings'] as List<dynamic>? ?? [])
        .whereType<String>()
        .toList();
    return OrganizationSummary(
      companyId: companyId,
      areas: areas,
      positions: positions,
      monthlyPersonnelCost: _parseDouble(json, 'monthlyPersonnelCost'),
      estimatedMonthlyCapacity: _parseDouble(json, 'estimatedMonthlyCapacity'),
      projectedMonthlyDemand: _parseDouble(json, 'projectedMonthlyDemand'),
      warnings: warnings,
    );
  }

  static int _parseInt(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _parseDouble(Map<String, dynamic> json, String key) {
    final v = json[key];
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
