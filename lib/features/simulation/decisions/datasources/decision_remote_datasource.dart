import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_impact_model.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/models/decision_model.dart';

class DecisionRemoteDatasource {
  final String baseUrl = 'https://simcore-production.up.railway.app/api/v1/simulation/decisions';

  Future<List<DecisionModel>> getDecisions(String companyId, String module) async {
    final response = await http.get(Uri.parse('$baseUrl?companyId=$companyId&module=$module'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => DecisionModel.fromJson(json)).toList();
    }
    throw Exception('Error al obtener decisiones');
  }

  Future<DecisionModel> createDecision(DecisionModel decision) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(decision.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return DecisionModel.fromJson(json.decode(response.body));
    }
    throw Exception('Error al crear decisión');
  }

  Future<List<DecisionModel>> getCompanyDecisions(String companyId) async {
    final response = await http.get(Uri.parse('$baseUrl/company/$companyId'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => DecisionModel.fromJson(json)).toList();
    }
    throw Exception('Error al obtener decisiones de la compañía');
  }

  Future<List<DecisionModel>> getDecisionHistory(String companyId, String module, String decisionType) async {
    final response = await http.get(Uri.parse('$baseUrl/history?companyId=$companyId&module=$module&decisionType=$decisionType'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => DecisionModel.fromJson(json)).toList();
    }
    throw Exception('Error al obtener historial');
  }

  Future<List<DecisionImpactModel>> getDecisionImpact(String decisionId) async {
    final response = await http.get(Uri.parse('$baseUrl/$decisionId/impact'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => DecisionImpactModel.fromJson(json)).toList();
    }
    throw Exception('Error al obtener impacto');
  }
}