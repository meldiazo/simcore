import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/modules/accounting/data/models/accounting_entry_model.dart';
import 'package:simcore_frontend/features/modules/accounting/data/models/financial_statement_model.dart';

abstract class AccountingRemoteDataSource {
  Future<void> generateAccountingEntries(String companyId, String scenarioType);
  Future<List<AccountingEntryModel>> getAccountingEntries(
    String companyId,
    String scenarioType,
  );
  Future<void> generateFinancialStatements(
      String companyId, String scenarioType);
  Future<List<FinancialStatementModel>> getFinancialStatements(
    String companyId,
    String scenarioType,
  );
  Future<void> completeAccountingModule(String companyId);
}

class AccountingRemoteDataSourceImpl implements AccountingRemoteDataSource {
  AccountingRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<void> generateAccountingEntries(
    String companyId,
    String scenarioType,
  ) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/accounting-entries/generate',
      data: {
        'companyId': int.tryParse(companyId) ?? companyId,
        'scenarioType': scenarioType,
      },
    );

    result.fold(
      (failure) => throw failure,
      (_) => null,
    );
  }

  @override
  Future<List<AccountingEntryModel>> getAccountingEntries(
    String companyId,
    String scenarioType,
  ) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/accounting-entries/company/$companyId/scenario',
      queryParameters: {
        'scenarioType': scenarioType,
      },
    );

    return result.fold(
      (failure) => throw failure,
      (data) => _extractList(data).map(AccountingEntryModel.fromJson).toList(),
    );
  }

  @override
  Future<void> generateFinancialStatements(
    String companyId,
    String scenarioType,
  ) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/financial-statements/generate',
      data: {
        'companyId': int.tryParse(companyId) ?? companyId,
        'scenarioType': scenarioType,
      },
    );

    result.fold(
      (failure) => throw failure,
      (_) => null,
    );
  }

  @override
  Future<List<FinancialStatementModel>> getFinancialStatements(
    String companyId,
    String scenarioType,
  ) async {
    final result = await _apiClient.get(
      '/api/v1/simulation/financial-statements/company/$companyId/scenario',
      queryParameters: {
        'scenarioType': scenarioType,
      },
    );

    return result.fold(
      (failure) => throw failure,
      (data) =>
          _extractList(data).map(FinancialStatementModel.fromJson).toList(),
    );
  }

  @override
  Future<void> completeAccountingModule(String companyId) async {
    final result = await _apiClient.patch(
      '/api/v1/simulation/companies/$companyId/modules/ACCOUNTING/complete',
    );

    result.fold(
      (failure) => throw failure,
      (_) => null,
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data == null) return const [];

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map) {
      final json = Map<String, dynamic>.from(data);

      for (final key in ['data', 'content', 'items', 'entries', 'statements']) {
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
}
