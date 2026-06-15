// ignore_for_file: unnecessary_type_check

import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/core/network/api_exception.dart';
import 'package:simcore_frontend/features/modules/organization/domain/entities/organization_area.dart';

class OrganizationRemoteDataSource {
  OrganizationRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<OrganizationSummary> getSummary({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    if (companyId <= 0) {
      return _emptySummary(
        companyId,
        warnings: const [
          'No hay empresa activa en el contexto de simulación.',
        ],
      );
    }

    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/organization',
      queryParameters: {
        'scenarioType': scenarioType,
      },
    );

    return result.fold(
      (e) {
        if (e is ApiException) {
          if (e.type == ErrorType.notFound) {
            return _emptySummary(
              companyId,
              warnings: const [
                'Aún no existe estructura organizativa registrada para esta empresa.',
              ],
            );
          }

          if (e.type == ErrorType.serverError) {
            return _emptySummary(
              companyId,
              warnings: const [
                'El backend no pudo calcular Organización. Verifica que Mercado tenga proyección generada y que la empresa esté activa.',
              ],
            );
          }
        }

        throw e;
      },
      (data) => _parseSummary(companyId, data),
    );
  }

  Future<OrganizationArea> createArea({
    required int companyId,
    required Map<String, dynamic> data,
  }) async {
    final body = Map<String, dynamic>.from(data);

    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/organization/areas',
      data: body,
    );

    return result.fold(
      (e) => throw e,
      (d) {
        if (d is Map) {
          return _parseArea(Map<String, dynamic>.from(d));
        }

        return OrganizationArea(
          id: 0,
          companyId: companyId,
          name: body['name']?.toString() ?? '',
          description: body['description']?.toString(),
        );
      },
    );
  }

  Future<OrganizationArea> updateArea({
    required int companyId,
    required int areaId,
    required Map<String, dynamic> data,
  }) async {
    final body = Map<String, dynamic>.from(data);

    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/organization/areas/$areaId',
      data: body,
    );

    return result.fold(
      (e) => throw e,
      (d) {
        if (d is Map) {
          return _parseArea(Map<String, dynamic>.from(d));
        }

        return OrganizationArea(
          id: areaId,
          companyId: companyId,
          name: body['name']?.toString() ?? '',
          description: body['description']?.toString(),
        );
      },
    );
  }

  Future<OrganizationPosition> createPosition({
    required int companyId,
    required Map<String, dynamic> data,
  }) async {
    final body = _sanitizePositionRequest(data);

    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/organization/positions',
      data: body,
    );

    return result.fold(
      (e) => throw e,
      (d) {
        if (d is Map) {
          return _parsePosition(Map<String, dynamic>.from(d));
        }

        return _parsePosition(body);
      },
    );
  }

  Future<OrganizationPosition> updatePosition({
    required int companyId,
    required int positionId,
    required Map<String, dynamic> data,
  }) async {
    final body = _sanitizePositionRequest(data);

    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/organization/positions/$positionId',
      data: body,
    );

    return result.fold(
      (e) => throw e,
      (d) {
        if (d is Map) {
          return _parsePosition(Map<String, dynamic>.from(d));
        }

        return _parsePosition({
          ...body,
          'id': positionId,
        });
      },
    );
  }

  Future<void> deletePosition({
    required int companyId,
    required int positionId,
  }) async {
    final result = await _apiClient.delete(
      '/api/v1/simulation/companies/$companyId/organization/positions/$positionId',
    );

    result.fold(
      (e) => throw e,
      (_) => null,
    );
  }

  Future<void> completeModule({required int companyId}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/modules/ORGANIZATION/complete',
    );

    result.fold(
      (e) => throw e,
      (_) => null,
    );
  }

  Map<String, dynamic> _sanitizePositionRequest(Map<String, dynamic> data) {
    final body = Map<String, dynamic>.from(data);

    final headcount = _toInt(body['headcount']);
    final monthlySalary = _toDouble(body['monthlySalary']);
    final capacityPerPerson = _toDouble(body['capacityPerPerson']);

    body['areaId'] = _toInt(body['areaId']);
    body['title'] = body['title']?.toString().trim() ?? '';
    body['responsibilities'] = body['responsibilities']?.toString();
    body['headcount'] = headcount <= 0 ? 1 : headcount;
    body['monthlySalary'] = monthlySalary <= 0 ? 1.0 : monthlySalary;
    body['capacityPerPerson'] = capacityPerPerson < 0 ? 0.0 : capacityPerPerson;

    return body;
  }

  OrganizationSummary _emptySummary(
    int companyId, {
    List<String> warnings = const [],
  }) {
    return OrganizationSummary(
      companyId: companyId,
      areas: const [],
      positions: const [],
      monthlyPersonnelCost: 0,
      estimatedMonthlyCapacity: 0,
      projectedMonthlyDemand: 0,
      warnings: warnings,
    );
  }

  OrganizationArea _parseArea(Map<String, dynamic> json) {
    return OrganizationArea(
      id: _readInt(json, ['id', 'areaId']),
      companyId: _readInt(json, ['companyId']),
      name: _readString(json, ['name', 'areaName']),
      description: _readNullableString(json, ['description']),
    );
  }

  OrganizationPosition _parsePosition(Map<String, dynamic> json) {
    return OrganizationPosition(
      id: _readInt(json, ['id', 'positionId']),
      areaId: _readInt(json, ['areaId']),
      title: _readString(json, ['title', 'name', 'positionName']),
      responsibilities: _readNullableString(json, ['responsibilities', 'description']),
      headcount: _readInt(json, ['headcount', 'quantity']),
      monthlySalary: _readDouble(json, ['monthlySalary', 'salary']),
      capacityPerPerson: _readNullableDouble(json, [
        'capacityPerPerson',
        'monthlyCapacityPerPerson',
        'capacity',
      ]),
    );
  }

  OrganizationSummary _parseSummary(int companyId, dynamic data) {
    if (data == null) {
      return _emptySummary(companyId);
    }

    if (data is! Map) {
      return _emptySummary(
        companyId,
        warnings: [
          'El backend devolvió una respuesta de organización no reconocida.',
        ],
      );
    }

    final json = Map<String, dynamic>.from(data);

    final areas = _readList(json, ['areas', 'organizationAreas'])
        .map(_parseArea)
        .toList();

    final positions = _readList(json, ['positions', 'organizationPositions'])
        .map(_parsePosition)
        .toList();

    final warnings = _readStringList(json, [
      'warnings',
      'alerts',
      'incoherences',
    ]);

    return OrganizationSummary(
      companyId: _readInt(json, ['companyId'], fallback: companyId),
      areas: areas,
      positions: positions,
      monthlyPersonnelCost: _readDouble(json, [
        'monthlyPersonnelCost',
        'totalMonthlyCost',
        'personnelCost',
      ]),
      estimatedMonthlyCapacity: _readDouble(json, [
        'estimatedMonthlyCapacity',
        'totalCapacity',
        'monthlyCapacity',
      ]),
      projectedMonthlyDemand: _readDouble(json, [
        'projectedMonthlyDemand',
        'projectedDemand',
        'monthlyDemand',
      ]),
      warnings: warnings,
    );
  }

  List<Map<String, dynamic>> _readList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];

      if (value is List) {
        return value
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }
    }

    return const [];
  }

  List<String> _readStringList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];

      if (value is List) {
        return value
            .map((item) => item.toString())
            .where((item) => item.trim().isNotEmpty)
            .toList();
      }
    }

    return const [];
  }

  String _readString(
    Map<String, dynamic> json,
    List<String> keys, {
    String fallback = '',
  }) {
    for (final key in keys) {
      final value = json[key];

      if (value != null) return value.toString();
    }

    return fallback;
  }

  String? _readNullableString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    return null;
  }

  int _readInt(
    Map<String, dynamic> json,
    List<String> keys, {
    int fallback = 0,
  }) {
    for (final key in keys) {
      final value = json[key];
      final parsed = _tryInt(value);

      if (parsed != null) return parsed;
    }

    return fallback;
  }

  double _readDouble(
    Map<String, dynamic> json,
    List<String> keys, {
    double fallback = 0,
  }) {
    for (final key in keys) {
      final value = json[key];
      final parsed = _tryDouble(value);

      if (parsed != null) return parsed;
    }

    return fallback;
  }

  double? _readNullableDouble(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      final parsed = _tryDouble(value);

      if (parsed != null) return parsed;
    }

    return null;
  }

  int _toInt(dynamic value) => _tryInt(value) ?? 0;

  double _toDouble(dynamic value) => _tryDouble(value) ?? 0;

  int? _tryInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  double? _tryDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
