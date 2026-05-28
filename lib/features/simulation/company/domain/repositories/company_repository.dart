import '../entities/company.dart';
import '../entities/module_progress.dart';

abstract class CompanyRepository {
  Future<List<Company>> getCompaniesByGroup(int groupId);
  Future<Company> getCompany(int id);
  Future<List<ModuleProgress>> getModules(int companyId);
  Future<SimulationScenario> getActiveScenario(int groupId);
  Future<List<Incoherence>> getIncoherences(int companyId);
  Future<List<DecisionLog>> getDecisions(int companyId);
  
  // Métodos de escritura de la HU-FE-09
  Future<Company> createCompany(Company company);
  Future<Company> updateCompany(Company company);
  
  // SOLUCIÓN AL ÚLTIMO ERROR: Agregamos la firma del método que le faltaba a la interfaz
  Future<void> activateCompany(int id);
}