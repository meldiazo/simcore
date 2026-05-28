import '../../domain/entities/company.dart';
import '../../domain/entities/module_progress.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';
import '../models/company_model.dart'; 

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDataSource remoteDataSource;
  CompanyRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Company>> getCompaniesByGroup(int groupId) async {
    final companies = await remoteDataSource.getCompaniesByGroup(groupId);
    return companies.map((c) => c as Company).toList();
  }

  @override
  Future<Company> getCompany(int id) async {
    return await remoteDataSource.getCompany(id);
  }

  @override
  Future<List<ModuleProgress>> getModules(int companyId) async {
    final modules = await remoteDataSource.getModules(companyId);
    return modules.map((m) => m as ModuleProgress).toList();
  }

  @override
  Future<SimulationScenario> getActiveScenario(int groupId) async {
    final model = await remoteDataSource.getActiveScenario(groupId);
    return SimulationScenario(id: model.id, name: model.name, description: model.description);
  }

  @override
  Future<List<Incoherence>> getIncoherences(int companyId) async {
    final models = await remoteDataSource.getIncoherences(companyId);
    return models.map((m) => Incoherence(id: m.id, title: m.title, message: m.message)).toList();
  }

  @override
  Future<List<DecisionLog>> getDecisions(int companyId) async {
    final models = await remoteDataSource.getDecisions(companyId);
    return models.map((m) => DecisionLog(id: m.id, module: m.module, description: m.description)).toList();
  }

  // Mapeo HU-FE-09
  CompanyModel _mapToModel(Company c) => CompanyModel(
    id: c.id, name: c.name, groupId: c.groupId, sector: c.sector,
    industry: c.industry, description: c.description, mission: c.mission,
    vision: c.vision, status: c.status,
  );

  @override
  Future<Company> createCompany(Company company) async {
    return await remoteDataSource.createCompany(_mapToModel(company));
  }

  @override
  Future<Company> updateCompany(Company company) async {
    return await remoteDataSource.updateCompany(_mapToModel(company));
  }

  @override
  Future<void> activateCompany(int id) async {
    await remoteDataSource.activateCompany(id);
  }
}