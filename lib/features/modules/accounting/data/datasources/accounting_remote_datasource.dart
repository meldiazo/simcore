import 'package:dio/dio.dart';
import '../models/accounting_entry_model.dart';
import '../models/financial_statement_model.dart';

abstract class AccountingRemoteDataSource {
  Future<void> generateAccountingEntries(String companyId);
  Future<List<AccountingEntryModel>> getAccountingEntries(String companyId);
  Future<void> generateFinancialStatements(String companyId);
  Future<List<FinancialStatementModel>> getFinancialStatements(String companyId);
  Future<void> completeAccountingModule(String companyId);
}

class AccountingRemoteDataSourceImpl implements AccountingRemoteDataSource {
  final Dio client;

  AccountingRemoteDataSourceImpl({required this.client});

  @override
  Future<void> generateAccountingEntries(String companyId) async {
    // Endpoint: POST /accounting-entries/generate
    await client.post(
      '/api/v1/simulation/accounting-entries/generate',
      data: {'companyId': companyId}, 
    );
  }

  @override
  Future<List<AccountingEntryModel>> getAccountingEntries(String companyId) async {
    final response = await client.get(
      '/api/v1/simulation/accounting-entries/company/$companyId/scenario',
      queryParameters: {'scenarioType': 'PROBABLE'},
    );
    
    return (response.data as List)
        .map((json) => AccountingEntryModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> generateFinancialStatements(String companyId) async {
    await client.post(
      '/api/v1/simulation/financial-statements/generate',
      data: {'companyId': companyId},
    );
  }

  @override
  Future<List<FinancialStatementModel>> getFinancialStatements(String companyId) async {
    final response = await client.get(
      '/api/v1/simulation/financial-statements/company/$companyId/scenario',
      queryParameters: {'scenarioType': 'PROBABLE'},
    );

    return (response.data as List)
        .map((json) => FinancialStatementModel.fromJson(json))
        .toList();
  }

  @override
  Future<void> completeAccountingModule(String companyId) async {
    await client.patch(
      '/api/v1/simulation/companies/$companyId/modules/ACCOUNTING/complete',
      data: {
        'module': 'ACCOUNTING',
        'decisionType': 'ACCOUNTING_REVIEW'
      }
    );
  }
}