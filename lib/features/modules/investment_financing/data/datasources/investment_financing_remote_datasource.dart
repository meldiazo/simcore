import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/modules/investment_financing/domain/entities/financing_option.dart';
import 'package:simcore_frontend/features/modules/investment_financing/domain/entities/investment_item.dart';

class InvestmentFinancingRemoteDataSource {
  InvestmentFinancingRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  // ── Investment ──────────────────────────────────────────────────────────────

  Future<InvestmentSummary> getInvestmentSummary({required int companyId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/investment/summary',
    );
    return result.fold(
      (e) => throw e,
      (data) => _parseInvestmentSummary(companyId, data),
    );
  }

  Future<InvestmentItem> createInvestmentItem({
    required int companyId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/investment/items',
      data: data,
    );
    return result.fold(
      (e) => throw e,
      (d) => _parseItem(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<InvestmentItem> updateInvestmentItem({
    required int companyId,
    required int itemId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/investment/items/$itemId',
      data: data,
    );
    return result.fold(
      (e) => throw e,
      (d) => _parseItem(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<void> deleteInvestmentItem({required int companyId, required int itemId}) async {
    final result = await _apiClient.delete(
      '/api/v1/simulation/companies/$companyId/investment/items/$itemId',
    );
    result.fold((e) => throw e, (_) {});
  }

  Future<void> completeInvestment({required int companyId}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/investment/complete',
    );
    result.fold((e) => throw e, (_) {});
  }

  // ── Financing ───────────────────────────────────────────────────────────────

  Future<FinancingSummary> getFinancingSummary({required int companyId}) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/companies/$companyId/financing/summary',
    );
    return result.fold(
      (e) => throw e,
      (data) => _parseFinancingSummary(companyId, data),
    );
  }

  Future<FinancingOption> createFinancingOption({
    required int companyId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/financing/options',
      data: data,
    );
    return result.fold(
      (e) => throw e,
      (d) => _parseOption(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<FinancingOption> updateFinancingOption({
    required int companyId,
    required int optionId,
    required Map<String, dynamic> data,
  }) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/financing/options/$optionId',
      data: data,
    );
    return result.fold(
      (e) => throw e,
      (d) => _parseOption(Map<String, dynamic>.from(d as Map)),
    );
  }

  Future<void> deleteFinancingOption({required int companyId, required int optionId}) async {
    final result = await _apiClient.delete(
      '/api/v1/simulation/companies/$companyId/financing/options/$optionId',
    );
    result.fold((e) => throw e, (_) {});
  }

  Future<void> selectFinancingOption({required int companyId, required int optionId}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/financing/options/$optionId/select',
    );
    result.fold((e) => throw e, (_) {});
  }

  Future<void> completeFinancing({required int companyId}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/financing/complete',
    );
    result.fold((e) => throw e, (_) {});
  }

  // ── Parsers ─────────────────────────────────────────────────────────────────

  InvestmentItem _parseItem(Map<String, dynamic> json) {
    return InvestmentItem(
      id: _parseInt(json, 'id'),
      companyId: _parseInt(json, 'companyId'),
      itemType: InvestmentItemType.fromApi(json['itemType']?.toString() ?? 'FIXED_ASSET'),
      name: json['name']?.toString() ?? '',
      quantity: _parseInt(json, 'quantity'),
      unitCost: _parseDouble(json, 'unitCost'),
      totalCost: _parseDouble(json, 'totalCost'),
      usefulLifeYears: json['usefulLifeYears'] is int ? json['usefulLifeYears'] as int : null,
    );
  }

  InvestmentSummary _parseInvestmentSummary(int companyId, dynamic data) {
    if (data == null) {
      return InvestmentSummary(
        companyId: companyId,
        items: const [],
        totalFixedAssets: 0,
        totalWorkingCapital: 0,
        totalPreOperative: 0,
        grandTotal: 0,
        hasMinimumData: false,
      );
    }
    final json = Map<String, dynamic>.from(data as Map);
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .whereType<Map>()
        .map((e) => _parseItem(Map<String, dynamic>.from(e)))
        .toList();
    return InvestmentSummary(
      companyId: companyId,
      items: items,
      totalFixedAssets: _parseDouble(json, 'totalFixedAssets'),
      totalWorkingCapital: _parseDouble(json, 'totalWorkingCapital'),
      totalPreOperative: _parseDouble(json, 'totalPreOperative'),
      grandTotal: _parseDouble(json, 'grandTotal'),
      hasMinimumData: json['hasMinimumData'] as bool? ?? false,
    );
  }

  FinancingOption _parseOption(Map<String, dynamic> json) {
    return FinancingOption(
      id: _parseInt(json, 'id'),
      companyId: _parseInt(json, 'companyId'),
      sourceName: json['sourceName']?.toString() ?? '',
      sourceType: FinancingSourceType.fromApi(json['sourceType']?.toString() ?? 'OTHER'),
      principalAmount: _parseDouble(json, 'principalAmount'),
      annualInterestRate: _parseDouble(json, 'annualInterestRate'),
      termMonths: _parseInt(json, 'termMonths'),
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  FinancingSummary _parseFinancingSummary(int companyId, dynamic data) {
    if (data == null) {
      return FinancingSummary(
        companyId: companyId,
        options: const [],
        totalPrincipal: 0,
        hasMinimumData: false,
        hasSelectedOption: false,
      );
    }
    final json = Map<String, dynamic>.from(data as Map);
    final rawOptions = json['options'] as List<dynamic>? ?? [];
    final options = rawOptions
        .whereType<Map>()
        .map((e) => _parseOption(Map<String, dynamic>.from(e)))
        .toList();
    final selected = options.where((o) => o.isSelected).firstOrNull;
    return FinancingSummary(
      companyId: companyId,
      options: options,
      selectedOption: selected,
      totalPrincipal: _parseDouble(json, 'totalPrincipal'),
      hasMinimumData: json['hasMinimumData'] as bool? ?? false,
      hasSelectedOption: selected != null,
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
