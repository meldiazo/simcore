import 'package:simcore_frontend/core/network/api_client.dart';
import '../models/investment_item_model.dart';
import '../models/financing_option_model.dart';

abstract class InvestmentFinancingRemoteDataSource {
  // Endpoints de Inversión
  Future<List<InvestmentItemModel>> getInvestmentItems(String companyId);
  Future<InvestmentItemModel> addInvestmentItem(
      String companyId, Map<String, dynamic> itemData);
  Future<InvestmentItemModel> updateInvestmentItem(
      String companyId, String itemId, Map<String, dynamic> itemData);
  Future<void> deleteInvestmentItem(String companyId, String itemId);
  Future<void> completeInvestment(String companyId);

  // Endpoints de Financiamiento
  Future<List<FinancingOptionModel>> getFinancingOptions(String companyId);
  Future<FinancingOptionModel> addFinancingOption(
      String companyId, Map<String, dynamic> optionData);
  Future<FinancingOptionModel> updateFinancingOption(
      String companyId, String optionId, Map<String, dynamic> optionData);
  Future<void> deleteFinancingOption(String companyId, String optionId);
  Future<void> selectFinancingOption(String companyId, String optionId);
  Future<void> completeFinancing(String companyId);

  // Progreso Global del Módulo
  Future<void> completeModuleProgress(String companyId);
}

class InvestmentFinancingRemoteDataSourceImpl
    implements InvestmentFinancingRemoteDataSource {
  final ApiClient _apiClient;

  InvestmentFinancingRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<InvestmentItemModel>> getInvestmentItems(String companyId) async {
    final result = await _apiClient
        .get('/api/v1/simulation/companies/$companyId/investment');
    return result.fold(
      (exception) => throw exception,
      (data) => _extractList(data).map(InvestmentItemModel.fromJson).toList(),
    );
  }

  @override
  Future<InvestmentItemModel> addInvestmentItem(
      String companyId, Map<String, dynamic> itemData) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/investment/items',
      data: itemData,
    );
    return result.fold(
      (exception) => throw exception,
      (data) =>
          InvestmentItemModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<InvestmentItemModel> updateInvestmentItem(
      String companyId, String itemId, Map<String, dynamic> itemData) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/investment/items/$itemId',
      data: itemData,
    );
    return result.fold(
      (exception) => throw exception,
      (data) =>
          InvestmentItemModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<void> deleteInvestmentItem(String companyId, String itemId) async {
    final result = await _apiClient.delete(
        '/api/v1/simulation/companies/$companyId/investment/items/$itemId');
    result.fold((exception) => throw exception, (_) => null);
  }

  @override
  Future<void> completeInvestment(String companyId) async {
    final result = await _apiClient
        .patch('/api/v1/simulation/companies/$companyId/investment/complete');
    result.fold((exception) => throw exception, (_) => null);
  }

  @override
  Future<List<FinancingOptionModel>> getFinancingOptions(
      String companyId) async {
    final result = await _apiClient
        .get('/api/v1/simulation/companies/$companyId/financing');
    return result.fold(
      (exception) => throw exception,
      (data) => _extractList(data).map(FinancingOptionModel.fromJson).toList(),
    );
  }

  @override
  Future<FinancingOptionModel> addFinancingOption(
      String companyId, Map<String, dynamic> optionData) async {
    final result = await _apiClient.post(
      '/api/v1/simulation/companies/$companyId/financing/options',
      data: optionData,
    );
    return result.fold(
      (exception) => throw exception,
      (data) =>
          FinancingOptionModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<FinancingOptionModel> updateFinancingOption(String companyId,
      String optionId, Map<String, dynamic> optionData) async {
    final result = await _apiClient.put(
      '/api/v1/simulation/companies/$companyId/financing/options/$optionId',
      data: optionData,
    );
    return result.fold(
      (exception) => throw exception,
      (data) =>
          FinancingOptionModel.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  @override
  Future<void> deleteFinancingOption(String companyId, String optionId) async {
    final result = await _apiClient.delete(
        '/api/v1/simulation/companies/$companyId/financing/options/$optionId');
    result.fold((exception) => throw exception, (_) => null);
  }

  @override
  Future<void> selectFinancingOption(String companyId, String optionId) async {
    final result = await _apiClient.patch(
        '/api/v1/simulation/companies/$companyId/financing/options/$optionId/select');
    result.fold((exception) => throw exception, (_) => null);
  }

  @override
  Future<void> completeFinancing(String companyId) async {
    final result = await _apiClient
        .patch('/api/v1/simulation/companies/$companyId/financing/complete');
    result.fold((exception) => throw exception, (_) => null);
  }

  @override
  Future<void> completeModuleProgress(String companyId) async {
    // Endpoint general para marcar el módulo INVESTMENT como completado en el progreso del estudiante
    final result = await _apiClient.patch(
        '/api/v1/simulation/companies/$companyId/modules/INVESTMENT/complete');
    result.fold((exception) => throw exception, (_) => null);
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
      for (final key in [
        'data',
        'content',
        'items',
        'investmentItems',
        'financingOptions'
      ]) {
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
