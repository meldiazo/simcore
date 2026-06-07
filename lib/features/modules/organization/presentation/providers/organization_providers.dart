import 'package:flutter/material.dart';
import '../models/organization_summary_model.dart';
import '../models/organization_area_model.dart';
import '../repositories/organization_repository_impl.dart';

class OrganizationProvider extends ChangeNotifier {
  final OrganizationRepositoryImpl repository;
  final String companyId;

  OrganizationSummaryModel? summary;
  bool isLoading = false;

  OrganizationProvider({required this.repository, required this.companyId});

 
  Future<void> loadOrganization(double marketDemand) async {
    isLoading = true;
    notifyListeners();

    try {
      final areas = await repository.getOrganization(companyId);
      summary = OrganizationSummaryModel(
        areas: areas,
        projectedDemand: marketDemand, 
      );
    } catch (e) {
      debugPrint("Error al cargar organización: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmOrganizationStructure() async {
    isLoading = true;
    notifyListeners();
    try {
      await repository.completeModule(companyId);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}