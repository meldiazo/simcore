import 'package:simcore_frontend/core/network/api_exception.dart';
import '../datasources/investment_financing_remote_datasource.dart';
import '../models/investment_item_model.dart';
import '../models/financing_option_model.dart';

class InvestmentFinancingRepositoryImpl {
  final InvestmentFinancingRemoteDataSource remoteDataSource;

  InvestmentFinancingRepositoryImpl({required this.remoteDataSource});

  Future<List<InvestmentItemModel>> getInvestmentItems(String companyId) async {
    try {
      return await remoteDataSource.getInvestmentItems(companyId);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Fallo al obtener la estructura de inversión: $e');
    }
  }

  Future<InvestmentItemModel> addInvestmentItem(String companyId, Map<String, dynamic> itemData) async {
    try {
      return await remoteDataSource.addInvestmentItem(companyId, itemData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('No se pudo registrar el requerimiento de capital: $e');
    }
  }

  Future<void> deleteInvestmentItem(String companyId, String itemId) async {
    try {
      await remoteDataSource.deleteInvestmentItem(companyId, itemId);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al eliminar el registro de inversión: $e');
    }
  }

  Future<void> completeInvestment(String companyId) async {
    try {
      await remoteDataSource.completeInvestment(companyId);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al confirmar la estructuración de inversión: $e');
    }
  }

  Future<void> completeFinancing(String companyId) async {
    try {
      await remoteDataSource.completeFinancing(companyId);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al confirmar la estructura de financiamiento: $e');
    }
  }

  Future<List<FinancingOptionModel>> getFinancingOptions(String companyId) async {
    try {
      return await remoteDataSource.getFinancingOptions(companyId);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Fallo al cargar las alternativas de financiamiento: $e');
    }
  }

  Future<FinancingOptionModel> addFinancingOption(String companyId, Map<String, dynamic> optionData) async {
    try {
      return await remoteDataSource.addFinancingOption(companyId, optionData);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('No se pudo registrar la opción de fondeo: $e');
    }
  }

  Future<void> selectFinancingOption(String companyId, String optionId) async {
    try {
      await remoteDataSource.selectFinancingOption(companyId, optionId);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('No se pudo seleccionar esta estructura de capital: $e');
    }
  }

  Future<void> completeModuleProgress(String companyId) async {
    try {
      await remoteDataSource.completeModuleProgress(companyId);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Error al registrar el progreso en SimCore: $e');
    }
  }
}
