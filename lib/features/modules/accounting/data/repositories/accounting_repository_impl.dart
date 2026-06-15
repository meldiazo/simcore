import '../datasources/accounting_remote_datasource.dart';
import '../models/accounting_entry_model.dart';
import '../models/financial_statement_model.dart';

abstract class AccountingRepository {
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

class AccountingRepositoryImpl implements AccountingRepository {
  final AccountingRemoteDataSource remoteDataSource;

  AccountingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> generateAccountingEntries(
    String companyId,
    String scenarioType,
  ) async {
    try {
      await remoteDataSource.generateAccountingEntries(companyId, scenarioType);
    } catch (e) {
      throw Exception('Error al generar asientos automáticos: $e');
    }
  }

  @override
  Future<List<AccountingEntryModel>> getAccountingEntries(
    String companyId,
    String scenarioType,
  ) async {
    try {
      return await remoteDataSource.getAccountingEntries(
          companyId, scenarioType);
    } catch (e) {
      throw Exception('Error al cargar la tabla de asientos: $e');
    }
  }

  @override
  Future<void> generateFinancialStatements(
    String companyId,
    String scenarioType,
  ) async {
    try {
      await remoteDataSource.generateFinancialStatements(
          companyId, scenarioType);
    } catch (e) {
      throw Exception('Error al procesar los estados financieros: $e');
    }
  }

  @override
  Future<List<FinancialStatementModel>> getFinancialStatements(
    String companyId,
    String scenarioType,
  ) async {
    try {
      return await remoteDataSource.getFinancialStatements(
          companyId, scenarioType);
    } catch (e) {
      throw Exception('Error al obtener los reportes financieros: $e');
    }
  }

  @override
  Future<void> completeAccountingModule(String companyId) async {
    try {
      await remoteDataSource.completeAccountingModule(companyId);
    } catch (e) {
      throw Exception('Error al registrar tu decisión en SimCore: $e');
    }
  }
}
