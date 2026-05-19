import 'package:core_sim_ia/core/network/api_client.dart';
import 'package:core_sim_ia/features/shared/data/demo/simcore_demo_data.dart';
import 'package:core_sim_ia/features/stratova/data/datasources/stratova_data_source.dart';
import 'package:core_sim_ia/features/stratova/data/datasources/stratova_mock_data_source.dart';

class StratovaRemoteDataSource implements StratovaDataSource {
  StratovaRemoteDataSource(
    this._apiClient, {
    StratovaDataSource? fallback,
  }) : _fallback = fallback ?? StratovaMockDataSource();

  final ApiClient _apiClient;
  final StratovaDataSource _fallback;

  @override
  Future<StudentUser> getCurrentUser() {
    return _fallback.getCurrentUser();
  }

  @override
  Future<CurrentCycle> getCurrentCycle() {
    return _fallback.getCurrentCycle();
  }

  @override
  Future<List<TeamMember>> getTeamMembers() {
    return _fallback.getTeamMembers();
  }

  @override
  Future<List<KpiMetric>> getKpis() {
    return _fallback.getKpis();
  }

  @override
  Future<List<AlertItem>> getAlerts() {
    return _fallback.getAlerts();
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
        return _fallback.getDecisionModules(companyId: companyId);
      },
      (data) async {
        final modules = _extractList(data);

        if (modules.isEmpty) {
          return _fallback.getDecisionModules(companyId: companyId);
        }

        return modules.map(_decisionModuleFromJson).toList();
      },
    );
  }

  @override
  Future<List<RankingTeam>> getRanking() {
    return _fallback.getRanking();
  }

  @override
  Future<List<MarketSegment>> getMarketSegments() {
    return _fallback.getMarketSegments();
  }

  @override
  Future<List<Competitor>> getCompetitors() {
    return _fallback.getCompetitors();
  }

  @override
  Future<List<ScenarioData>> getFinancialScenarios() {
    return _fallback.getFinancialScenarios();
  }

  @override
  Future<List<CashFlowEntry>> getCashFlow() {
    return _fallback.getCashFlow();
  }

  @override
  Future<List<Inefficiency>> getOrganizationalInefficiencies() {
    return _fallback.getOrganizationalInefficiencies();
  }

  @override
  Future<List<AdminTeamStatus>> getAdminTeams() {
    return _fallback.getAdminTeams();
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().toList();
    }

    if (data is Map<String, dynamic>) {
      for (final key in ['modules', 'data', 'content', 'items']) {
        final value = data[key];

        if (value is List) {
          return value.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    return const [];
  }

  DecisionModule _decisionModuleFromJson(Map<String, dynamic> json) {
    final id = _readString(
      json,
      ['id', 'moduleId', 'moduleCode', 'code'],
    );

    final name = _readString(
      json,
      ['name', 'moduleName', 'displayName', 'title'],
    );

    final status = _readString(
      json,
      ['status', 'state'],
    );

    final safeId = id.isEmpty ? name.toLowerCase().replaceAll(' ', '-') : id;

    return DecisionModule(
      id: safeId,
      name: name.isEmpty ? _humanizeModuleName(safeId) : name,
      status: _statusFromJson(status),
      progress: _readInt(
        json,
        ['progress', 'completionPercentage', 'percentage'],
      ),
      summary: [
        'Origen: API real',
        if (status.isNotEmpty) 'Estado: $status',
        if (json['updatedAt'] != null) 'Actualizado: ${json['updatedAt']}',
      ],
    );
  }

  DecisionStatus _statusFromJson(String value) {
    return switch (value.toUpperCase()) {
      'SUBMITTED' || 'COMPLETED' || 'DONE' => DecisionStatus.submitted,
      'DRAFT' || 'IN_PROGRESS' => DecisionStatus.draft,
      'LOCKED' => DecisionStatus.locked,
      _ => DecisionStatus.pending,
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
      if (value is String) return int.tryParse(value) ?? 0;
    }

    return 0;
  }

  String _humanizeModuleName(String id) {
    return switch (id.toLowerCase()) {
      'market' || 'mercado' || 'market_module' => 'Módulo Mercado',
      'finance' || 'finanzas' || 'financial' => 'Módulo Finanzas',
      'hr' || 'rrhh' || 'organization' || 'organizational' => 'Módulo RRHH',
      'operations' || 'operaciones' => 'Módulo Operaciones',
      'accounting' || 'contabilidad' => 'Módulo Contabilidad',
      'analysis' || 'analisis' => 'Análisis General',
      _ => 'Módulo SIMCORE',
    };
  }
}
