import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/investment_item_model.dart';
import '../models/financing_option_model.dart';

abstract class InvestmentFinancingRemoteDataSource {
  // Endpoints de Inversión
  Future<List<InvestmentItemModel>> getInvestmentItems(String companyId);
  Future<InvestmentItemModel> addInvestmentItem(String companyId, Map<String, dynamic> itemData);
  Future<InvestmentItemModel> updateInvestmentItem(String companyId, String itemId, Map<String, dynamic> itemData);
  Future<void> deleteInvestmentItem(String companyId, String itemId);
  Future<void> completeInvestment(String companyId);

  // Endpoints de Financiamiento
  Future<List<FinancingOptionModel>> getFinancingOptions(String companyId);
  Future<FinancingOptionModel> addFinancingOption(String companyId, Map<String, dynamic> optionData);
  Future<FinancingOptionModel> updateFinancingOption(String companyId, String optionId, Map<String, dynamic> optionData);
  Future<void> deleteFinancingOption(String companyId, String optionId);
  Future<void> selectFinancingOption(String companyId, String optionId);
  Future<void> completeFinancing(String companyId);
  
  // Progreso Global del Módulo
  Future<void> completeModuleProgress(String companyId);
}

class InvestmentFinancingRemoteDataSourceImpl implements InvestmentFinancingRemoteDataSource {
  final http.Client client;
  final String baseUrl = 'https://simcore-production.up.railway.app/api/v1';

  InvestmentFinancingRemoteDataSourceImpl({required this.client});

   
   
  @override
  Future<List<InvestmentItemModel>> getInvestmentItems(String companyId) async {
    final response = await client.get(Uri.parse('$baseUrl/simulation/companies/$companyId/investment'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => InvestmentItemModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar items de inversión');
    }
  }

  @override
  Future<InvestmentItemModel> addInvestmentItem(String companyId, Map<String, dynamic> itemData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/simulation/companies/$companyId/investment/items'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(itemData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return InvestmentItemModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al agregar item de inversión');
    }
  }

  @override
  Future<InvestmentItemModel> updateInvestmentItem(String companyId, String itemId, Map<String, dynamic> itemData) async {
    final response = await client.put(
      Uri.parse('$baseUrl/simulation/companies/$companyId/investment/items/$itemId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(itemData),
    );
    if (response.statusCode == 200) {
      return InvestmentItemModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar item de inversión');
    }
  }

  @override
  Future<void> deleteInvestmentItem(String companyId, String itemId) async {
    final response = await client.delete(Uri.parse('$baseUrl/simulation/companies/$companyId/investment/items/$itemId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar item de inversión');
    }
  }

  @override
  Future<void> completeInvestment(String companyId) async {
    final response = await client.patch(Uri.parse('$baseUrl/simulation/companies/$companyId/investment/complete'));
    if (response.statusCode != 200) {
      throw Exception('Error al completar inversión');
    }
  }



  @override
  Future<List<FinancingOptionModel>> getFinancingOptions(String companyId) async {
    final response = await client.get(Uri.parse('$baseUrl/simulation/companies/$companyId/financing'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FinancingOptionModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar opciones de financiamiento');
    }
  }

  @override
  Future<FinancingOptionModel> addFinancingOption(String companyId, Map<String, dynamic> optionData) async {
    final response = await client.post(
      Uri.parse('$baseUrl/simulation/companies/$companyId/financing/options'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(optionData),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return FinancingOptionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al agregar opción de financiamiento');
    }
  }

  @override
  Future<FinancingOptionModel> updateFinancingOption(String companyId, String optionId, Map<String, dynamic> optionData) async {
    final response = await client.put(
      Uri.parse('$baseUrl/simulation/companies/$companyId/financing/options/$optionId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(optionData),
    );
    if (response.statusCode == 200) {
      return FinancingOptionModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al actualizar opción de financiamiento');
    }
  }

  @override
  Future<void> deleteFinancingOption(String companyId, String optionId) async {
    final response = await client.delete(Uri.parse('$baseUrl/simulation/companies/$companyId/financing/options/$optionId'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar opción de financiamiento');
    }
  }

  @override
  Future<void> selectFinancingOption(String companyId, String optionId) async {
    final response = await client.patch(Uri.parse('$baseUrl/simulation/companies/$companyId/financing/options/$optionId/select'));
    if (response.statusCode != 200) {
      throw Exception('Error al seleccionar opción de financiamiento');
    }
  }

  @override
  Future<void> completeFinancing(String companyId) async {
    final response = await client.patch(Uri.parse('$baseUrl/simulation/companies/$companyId/financing/complete'));
    if (response.statusCode != 200) {
      throw Exception('Error al completar financiamiento');
    }
  }

  
  
  @override
  Future<void> completeModuleProgress(String companyId) async {
    // Endpoint general para marcar el módulo INVESTMENT como completado en el progreso del estudiante
    final response = await client.patch(Uri.parse('$baseUrl/modules/INVESTMENT/complete'));
    if (response.statusCode != 200) {
      throw Exception('Error al registrar el progreso del módulo');
    }
  }
}