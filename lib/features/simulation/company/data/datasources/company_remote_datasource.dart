import 'package:dio/dio.dart';
import '../models/company_model.dart';
import '../models/module_progress_model.dart';

abstract class ApiClient {
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters});
  Future<Response<T>> post<T>(String path, {dynamic data});
  Future<Response<T>> put<T>(String path, {dynamic data});
  Future<Response<T>> patch<T>(String path, {dynamic data});
}

// Modelos internos con validación de nulidad para evitar "undefined getters"
class SimulationScenarioModel {
  final int id;
  final String name;
  final String description;
  SimulationScenarioModel({required this.id, required this.name, required this.description});
  factory SimulationScenarioModel.fromJson(Map<String, dynamic> json) => 
    SimulationScenarioModel(id: json['id'] ?? 0, name: json['name'] ?? '', description: json['description'] ?? '');
}

class IncoherenceModel {
  final int id;
  final String title;
  final String message;
  IncoherenceModel({required this.id, required this.title, required this.message});
  factory IncoherenceModel.fromJson(Map<String, dynamic> json) => 
    IncoherenceModel(id: json['id'] ?? 0, title: json['title'] ?? 'Alerta', message: json['message'] ?? '');
}

class DecisionLogModel {
  final int id;
  final String module;
  final String description;
  DecisionLogModel({required this.id, required this.module, required this.description});
  factory DecisionLogModel.fromJson(Map<String, dynamic> json) => 
    DecisionLogModel(id: json['id'] ?? 0, module: json['module'] ?? 'Sistema', description: json['description'] ?? '');
}

class CompanyRemoteDataSource {
  final ApiClient dio;
  CompanyRemoteDataSource(this.dio);

  // MÉTODOS DE LECTURA (HU-FE-08)
  Future<List<CompanyModel>> getCompaniesByGroup(int groupId) async {
    final response = await dio.get('/api/v1/simulation/companies?groupId=$groupId');
    return (response.data as List).map((e) => CompanyModel.fromJson(e)).toList();
  }

  Future<CompanyModel> getCompany(int id) async {
    final response = await dio.get('/api/v1/simulation/companies/$id');
    return CompanyModel.fromJson(response.data);
  }

  Future<List<ModuleProgressModel>> getModules(int id) async {
    final response = await dio.get('/api/v1/simulation/companies/$id/modules');
    return (response.data as List).map((e) => ModuleProgressModel.fromJson(e)).toList();
  }

  Future<SimulationScenarioModel> getActiveScenario(int groupId) async {
    final response = await dio.get('/api/v1/simulation/scenarios/active?groupId=$groupId');
    return SimulationScenarioModel.fromJson(response.data);
  }

  Future<List<IncoherenceModel>> getIncoherences(int companyId) async {
    final response = await dio.get('/api/v1/simulation/companies/$companyId/incoherences');
    return (response.data as List).map((e) => IncoherenceModel.fromJson(e)).toList();
  }

  Future<List<DecisionLogModel>> getDecisions(int companyId) async {
    final response = await dio.get('/api/v1/simulation/decisions/company/$companyId');
    return (response.data as List).map((e) => DecisionLogModel.fromJson(e)).toList();
  }

  // MÉTODOS DE ACCIÓN (HU-FE-09)
  Future<CompanyModel> createCompany(CompanyModel model) async {
    final response = await dio.post('/api/v1/simulation/companies', data: model.toJson());
    return CompanyModel.fromJson(response.data);
  }

  Future<CompanyModel> updateCompany(CompanyModel model) async {
    final response = await dio.put('/api/v1/simulation/companies/${model.id}', data: model.toJson());
    return CompanyModel.fromJson(response.data);
  }

  Future<void> activateCompany(int id) async {
    await dio.patch('/api/v1/simulation/companies/$id/activate');
  }
}