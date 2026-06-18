import '../datasources/accounting_remote_datasource.dart';
import '../models/accounting_entry_model.dart';
import '../models/financial_statement_model.dart';

abstract class AccountingRepository {
  Future<void> generateAccountingEntries(String companyId);
  Future<List<AccountingEntryModel>> getAccountingEntries(String companyId);
  Future<void> generateFinancialStatements(String companyId);
  Future<List<FinancialStatementModel>> getFinancialStatements(
      String companyId);
  Future<void> startAccountingModule(String companyId);
  Future<void> completeAccountingModule(String companyId);
}

class AccountingRepositoryImpl implements AccountingRepository {
  final AccountingRemoteDataSource remoteDataSource;

  AccountingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> generateAccountingEntries(String companyId) async {
    try {
      await remoteDataSource.generateAccountingEntries(companyId);
    } catch (e) {
      throw Exception('Error al generar asientos automáticos: $e');
    }
  }

  @override
  Future<List<AccountingEntryModel>> getAccountingEntries(
      String companyId) async {
    try {
      return await remoteDataSource.getAccountingEntries(companyId);
    } catch (e) {
      throw Exception('Error al cargar la tabla de asientos: $e');
    }
  }

  @override
  Future<void> generateFinancialStatements(String companyId) async {
    try {
      await remoteDataSource.generateFinancialStatements(companyId);
    } catch (e) {
      throw Exception('Error al procesar los estados financieros: $e');
    }
  }

  @override
  Future<List<FinancialStatementModel>> getFinancialStatements(
      String companyId) async {
    try {
      return await remoteDataSource.getFinancialStatements(companyId);
    } catch (e) {
      throw Exception('Error al obtener los reportes financieros: $e');
    }
  }

  @override
  Future<void> startAccountingModule(String companyId) async {
    try {
      await remoteDataSource.startAccountingModule(companyId);
    } catch (e) {
      throw Exception('Error al iniciar el módulo de contabilidad: $e');
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
