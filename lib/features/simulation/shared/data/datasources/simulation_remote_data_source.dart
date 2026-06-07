import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/simulation/shared/data/datasources/simulation_data_source.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/simulation/shared/data/models/simulation_context_model.dart';
import 'package:simcore_frontend/features/simulation/shared/domain/entities/simulation_context.dart';

class SimulationRemoteDataSource implements SimulationDataSource {
  SimulationRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<StudentUser> getCurrentUser() {
    return _notIntegrated(
      'getCurrentUser todavía depende de datos demo heredados. '
      'Debe integrarse luego con AuthUser y SimulationContext.',
    );
  }

  @override
  Future<CurrentCycle> getCurrentCycle() {
    return _notIntegrated(
      'getCurrentCycle todavía no tiene endpoint real conectado.',
    );
  }

  @override
  Future<List<TeamMember>> getTeamMembers() {
    return _notIntegrated(
      'getTeamMembers todavía no tiene endpoint real conectado.',
    );
  }

  @override
  Future<List<KpiMetric>> getKpis() {
    return _notIntegrated(
      'getKpis todavía no tiene endpoint real conectado.',
    );
  }

  @override
  Future<List<AlertItem>> getAlerts() {
    return _notIntegrated(
      'getAlerts debe reemplazarse por incoherencias reales del backend.',
    );
  }

  @override
  Future<List<ModuleProgress>> getModuleProgress({
    int companyId = 1,
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/modules',
    );

    return result.fold(
      (failure) {
        throw failure;
      },
      (data) {
        final modules = _extractList(data);

        return modules.map(_moduleProgressFromJson).toList();
      },
    );
  }
  @override
  Future<SimulationContext> getSimulationContext({required int companyId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId',
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        final json = Map<String, dynamic>.from(data as Map);
        return SimulationContextModel.fromCompanyJson(json);
      },
    );
  }

  @override
  Future<SimulationContext> getSimulationContextByGroupId({required int groupId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies',
      queryParameters: {'groupId': groupId},
    );

    return result.fold(
      (failure) => throw failure,
      (data) {
        final json = Map<String, dynamic>.from(data as Map);
        return SimulationContextModel.fromCompanyJson(json);
      },
    );
  }

  @override
  Future<List<RankingTeam>> getRanking() {
    return _notIntegrated(
      'getRanking debe reemplazarse por comparación académica real.',
    );
  }

  @override
  Future<List<MarketSegment>> getMarketSegments() {
    return _notIntegrated(
      'getMarketSegments todavía no está conectado al módulo Mercado real.',
    );
  }

  @override
  Future<List<Competitor>> getCompetitors() {
    return _notIntegrated(
      'getCompetitors todavía no está conectado al módulo Mercado real.',
    );
  }

  @override
  Future<List<ScenarioData>> getFinancialScenarios() {
    return _notIntegrated(
      'getFinancialScenarios debe reemplazarse por escenarios reales.',
    );
  }

  @override
  Future<List<CashFlowEntry>> getCashFlow() {
    return _notIntegrated(
      'getCashFlow debe reemplazarse por estados financieros reales.',
    );
  }

  @override
  Future<List<Inefficiency>> getOrganizationalInefficiencies() {
    return _notIntegrated(
      'getOrganizationalInefficiencies debe reemplazarse por incoherencias reales.',
    );
  }

  @override
  Future<List<AdminTeamStatus>> getAdminTeams() {
    return _notIntegrated(
      'getAdminTeams debe reemplazarse por dashboard docente real.',
    );
  }

  Future<T> _notIntegrated<T>(String message) {
    return Future<T>.error(
      UnsupportedError('Fuente de datos no integrada: $message'),
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map) {
      final json = Map<String, dynamic>.from(data);

      for (final key in ['modules', 'data', 'content', 'items']) {
        final value = json[key];

        if (value is List) {
          return value
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
    }

    return const [];
  }

  ModuleProgress _moduleProgressFromJson(Map<String, dynamic> json) {
  final moduleValue = _readString(
    json,
    ['module', 'id', 'moduleId', 'moduleCode', 'code'],
  );

  final statusValue = _readString(
    json,
    ['status', 'state'],
  );

  final module = SimModule.fromApi(moduleValue);
  final status = ModuleStatus.fromApi(statusValue);

  final progress = _readInt(
    json,
    ['progress', 'completionPercentage', 'percentage'],
  );

  return ModuleProgress(
    module: module,
    status: status,
    progress: progress > 0 ? progress : status.progressHint,
    summary: [
      'Origen: API real',
      'Estado backend: ${status.toApi()}',
      if (json['updatedAt'] != null) 'Actualizado: ${json['updatedAt']}',
    ],
  );
}


  String _readString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value != null) {
        return value.toString();
      }
    }

    return '';
  }

  int _readInt(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];

      if (value is int) return value;
      if (value is double) return value.round();
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
    }

    return 0;
  }
}
