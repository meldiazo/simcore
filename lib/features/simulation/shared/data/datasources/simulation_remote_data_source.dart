import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/simulation/shared/data/datasources/simulation_data_source.dart';

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
  Future<List<DecisionModule>> getDecisionModules({
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

        return modules.map(_decisionModuleFromJson).toList();
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

  DecisionModule _decisionModuleFromJson(Map<String, dynamic> json) {
    final id = _readString(
      json,
      ['module', 'id', 'moduleId', 'moduleCode', 'code'],
    );

    final name = _readString(
      json,
      ['name', 'moduleName', 'displayName', 'title', 'module'],
    );

    final status = _readString(
      json,
      ['status', 'state'],
    );

    final progress = _readInt(
      json,
      ['progress', 'completionPercentage', 'percentage'],
    );

    final safeId = id.isEmpty ? name.toLowerCase().replaceAll(' ', '-') : id;

    return DecisionModule(
      id: safeId,
      name: name.isEmpty
          ? _humanizeModuleName(safeId)
          : _humanizeModuleName(name),
      status: _statusFromJson(status),
      progress: progress > 0 ? progress : _progressFromStatus(status),
      summary: [
        'Origen: API real',
        if (status.isNotEmpty) 'Estado backend: $status',
        if (json['updatedAt'] != null) 'Actualizado: ${json['updatedAt']}',
      ],
    );
  }

  DecisionStatus _statusFromJson(String value) {
    return switch (value.toUpperCase()) {
      'COMPLETE' ||
      'COMPLETED' ||
      'DONE' ||
      'SUBMITTED' =>
        DecisionStatus.submitted,
      'IN_PROGRESS' || 'DRAFT' => DecisionStatus.draft,
      'REQUIRES_REVISION' || 'LOCKED' => DecisionStatus.locked,
      'PENDING' || 'OUTDATED' => DecisionStatus.pending,
      _ => DecisionStatus.pending,
    };
  }

  int _progressFromStatus(String value) {
    return switch (value.toUpperCase()) {
      'COMPLETE' || 'COMPLETED' || 'DONE' || 'SUBMITTED' => 100,
      'IN_PROGRESS' || 'DRAFT' => 50,
      'REQUIRES_REVISION' || 'OUTDATED' => 25,
      _ => 0,
    };
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

  String _humanizeModuleName(String id) {
    return switch (id.toUpperCase()) {
      'MARKET' || 'MERCADO' => 'Módulo Mercado',
      'INVESTMENT' || 'FINANCE' || 'FINANZAS' => 'Inversiones y Financiamiento',
      'ORGANIZATION' || 'HR' || 'RRHH' => 'Estructuras Organizativas',
      'ACCOUNTING' || 'CONTABILIDAD' => 'Módulo Contabilidad',
      'ANALYSIS' || 'ANALISIS' => 'Análisis General',
      _ => 'Módulo SIMCORE',
    };
  }
}
