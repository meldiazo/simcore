import '../datasources/investment_financing_remote_datasource.dart';
import '../models/investment_item_model.dart';
import '../models/financing_option_model.dart';

class InvestmentFinancingRepositoryImpl {
  final InvestmentFinancingRemoteDataSource remoteDataSource;

  InvestmentFinancingRepositoryImpl({required this.remoteDataSource});

  

  Future<List<InvestmentItemModel>> getInvestmentItems(String companyId) async {
    try {
      return await remoteDataSource.getInvestmentItems(companyId);
    } catch (e) {
      throw Exception('Fallo al obtener la estructura de inversión. Verifica tu conexión.');
    }
  }

  Future<InvestmentItemModel> addInvestmentItem(String companyId, Map<String, dynamic> itemData) async {
    try {
      return await remoteDataSource.addInvestmentItem(companyId, itemData);
    } catch (e) {
      throw Exception('No se pudo registrar el requerimiento de capital.');
    }
  }

  Future<void> deleteInvestmentItem(String companyId, String itemId) async {
    try {
      await remoteDataSource.deleteInvestmentItem(companyId, itemId);
    } catch (e) {
      throw Exception('Error al eliminar el registro de inversión.');
    }
  }

  Future<void> completeInvestment(String companyId) async {
    try {
      await remoteDataSource.completeInvestment(companyId);
    } catch (e) {
      throw Exception('Error al confirmar la estructuración de inversión.');
    }
  }

  

  Future<List<FinancingOptionModel>> getFinancingOptions(String companyId) async {
    try {
      return await remoteDataSource.getFinancingOptions(companyId);
    } catch (e) {
      throw Exception('Fallo al cargar las alternativas de financiamiento.');
    }
  }

  Future<FinancingOptionModel> addFinancingOption(String companyId, Map<String, dynamic> optionData) async {
    try {
      return await remoteDataSource.addFinancingOption(companyId, optionData);
    } catch (e) {
      throw Exception('No se pudo registrar la opción de fondeo.');
    }
  }

  Future<void> selectFinancingOption(String companyId, String optionId) async {
    try {
      await remoteDataSource.selectFinancingOption(companyId, optionId);
    } catch (e) {
      throw Exception('No se pudo seleccionar esta estructura de capital.');
    }
  }

 
  Future<void> completeModuleProgress(String companyId) async {
    try {
      await remoteDataSource.completeModuleProgress(companyId);
    } catch (e) {
      throw Exception('Error al registrar el progreso en SimCore. Intenta nuevamente.');
    }
  }
}