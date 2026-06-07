import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_assumption_model.dart';
import '../models/sales_projection_model.dart';

class MarketRemoteDatasource {
  final String baseUrl = 'https://simcore-production.up.railway.app/api/v1/simulation/companies';

  Future<MarketAssumptionModel?> getAssumption(String companyId) async {
    final response = await http.get(Uri.parse('$baseUrl/$companyId/market/assumption'));
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return MarketAssumptionModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<MarketAssumptionModel> updateAssumption(String companyId, MarketAssumptionModel assumption) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$companyId/market/assumption'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(assumption.toJson()),
    );
    if (response.statusCode == 200) {
      return MarketAssumptionModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al actualizar supuestos de mercado');
  }

  Future<SalesProjectionModel?> getProjection(String companyId) async {
    final response = await http.get(Uri.parse('$baseUrl/$companyId/market/projection'));
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      return SalesProjectionModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  Future<SalesProjectionModel> generateProjection(String companyId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$companyId/market/projection/generate'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return SalesProjectionModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al generar proyección');
  }

  Future<void> completeMarket(String companyId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$companyId/market/complete'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al completar el módulo de mercado');
    }
  }
}