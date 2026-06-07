import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/modules/accounting/domain/entities/accounting_entry.dart';

class AccountingRemoteDataSource {
  AccountingRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AccountingEntry>> generateEntries({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/accounting-entries/generate',
      data: {'companyId': companyId, 'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(_parseEntry).toList(),
    );
  }

  Future<List<AccountingEntry>> getEntries({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/accounting-entries/company/$companyId/scenario',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(_parseEntry).toList(),
    );
  }

  Future<List<FinancialStatement>> generateStatements({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/financial-statements/generate',
      data: {'companyId': companyId, 'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(_parseStatement).toList(),
    );
  }

  Future<List<FinancialStatement>> getStatements({
    required int companyId,
    String scenarioType = 'PROBABLE',
  }) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/financial-statements/company/$companyId/scenario',
      queryParameters: {'scenarioType': scenarioType},
    );
    return result.fold(
      (e) => throw e,
      (data) => _extractList(data).map(_parseStatement).toList(),
    );
  }

  Future<void> completeModule({required int companyId}) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/accounting/complete',
    );
    result.fold((e) => throw e, (_) {});
  }

  AccountingEntry _parseEntry(Map<String, dynamic> json) {
    final lines = (json['lines'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((l) {
          final m = Map<String, dynamic>.from(l);
          return AccountingEntryLine(
            accountCode: m['accountCode']?.toString() ?? '',
            accountName: m['accountName']?.toString() ?? '',
            debit: _parseDouble(m, 'debit'),
            credit: _parseDouble(m, 'credit'),
          );
        })
        .toList();
    return AccountingEntry(
      id: _parseInt(json, 'id'),
      companyId: _parseInt(json, 'companyId'),
      scenarioType: json['scenarioType']?.toString() ?? 'PROBABLE',
      sourceModule: json['sourceModule']?.toString() ?? '',
      entryType: json['entryType']?.toString() ?? '',
      status: json['status']?.toString() ?? 'GENERATED',
      periodLabel: json['periodLabel']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      lines: lines,
    );
  }

  FinancialStatement _parseStatement(Map<String, dynamic> json) {
    final lines = (json['lines'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((l) {
          final m = Map<String, dynamic>.from(l);
          return FinancialStatementLine(
            label: m['label']?.toString() ?? '',
            amount: _parseDouble(m, 'amount'),
            isTotal: m['isTotal'] as bool? ?? false,
          );
        })
        .toList();
    return FinancialStatement(
      id: _parseInt(json, 'id'),
      companyId: _parseInt(json, 'companyId'),
      scenarioType: json['scenarioType']?.toString() ?? 'PROBABLE',
      statementType: json['statementType']?.toString() ?? '',
      periodLabel: json['periodLabel']?.toString() ?? '',
      status: json['status']?.toString() ?? 'GENERATED',
      lines: lines,
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    if (data is Map) {
      final json = Map<String, dynamic>.from(data);
      for (final key in ['data', 'content', 'items', 'entries', 'statements']) {
        final value = json[key];
        if (value is List) {
          return value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        }
      }
    }
    return const [];
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
