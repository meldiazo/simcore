import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/core/network/api_client_providers.dart';
import 'package:simcore_frontend/features/simulation/company/domain/repositories/company_repository.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart' as global_providers;

import '../../data/datasources/investment_financing_remote_datasource.dart';
import '../../data/repositories/investment_financing_repository_impl.dart';
import '../../data/models/investment_item_model.dart';
import '../../data/models/financing_option_model.dart';

final investmentFinancingRepositoryProvider = Provider((ref) {
  final dataSource = InvestmentFinancingRemoteDataSourceImpl(
    apiClient: ref.watch(simulationApiClientProvider),
  );
  return InvestmentFinancingRepositoryImpl(remoteDataSource: dataSource);
});

class InvestmentFinancingState {
  final bool isLoading;
  final bool isMarketComplete;
  final bool isInvestmentComplete;
  final List<InvestmentItemModel> investmentItems;
  final List<FinancingOptionModel> financingOptions;
  final String? errorMessage;
  final String? successMessage;

  InvestmentFinancingState({
    this.isLoading = false,
    this.isMarketComplete = false,
    this.isInvestmentComplete = false,
    this.investmentItems = const [],
    this.financingOptions = const [],
    this.errorMessage,
    this.successMessage,
  });

  InvestmentFinancingState copyWith({
    bool? isLoading,
    bool? isMarketComplete,
    bool? isInvestmentComplete,
    List<InvestmentItemModel>? investmentItems,
    List<FinancingOptionModel>? financingOptions,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return InvestmentFinancingState(
      isLoading: isLoading ?? this.isLoading,
      isMarketComplete: isMarketComplete ?? this.isMarketComplete,
      isInvestmentComplete: isInvestmentComplete ?? this.isInvestmentComplete,
      investmentItems: investmentItems ?? this.investmentItems,
      financingOptions: financingOptions ?? this.financingOptions,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      successMessage:
          clearSuccessMessage ? null : successMessage ?? this.successMessage,
    );
  }
}

class InvestmentFinancingNotifier
    extends StateNotifier<InvestmentFinancingState> {
  final InvestmentFinancingRepositoryImpl repository;
  final CompanyRepository companyRepository;
  final String companyId;
  final Ref _ref;

  InvestmentFinancingNotifier(
    this.repository,
    this.companyRepository,
    this.companyId,
    this._ref,
  ) : super(InvestmentFinancingState()) {
    _initializeModule();
  }
  Future<void> refresh() => _initializeModule();

  Future<void> _initializeModule() async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final parsedCompanyId = int.tryParse(companyId);

      if (parsedCompanyId == null || parsedCompanyId <= 0) {
        if (!mounted) return;

        state = state.copyWith(
          isLoading: false,
          isMarketComplete: false,
          isInvestmentComplete: false,
          investmentItems: const [],
          financingOptions: const [],
          errorMessage:
              'No se pudo validar el Módulo de Mercado porque el ID de empresa no es válido.',
        );
        return;
      }

      final moduleProgress = await companyRepository.getModuleProgress(
        companyId: parsedCompanyId,
      );

      final marketReady = moduleProgress.any(
        (module) =>
            module.module == SimModule.market &&
            module.status == ModuleStatus.complete,
      );

      final isInvestmentComplete = moduleProgress.any(
        (module) =>
            module.module == SimModule.investment &&
            module.status == ModuleStatus.complete,
      );

      if (!mounted) return;

      if (!marketReady) {
        state = state.copyWith(
          isLoading: false,
          isMarketComplete: false,
          isInvestmentComplete: false,
          investmentItems: const [],
          financingOptions: const [],
          errorMessage: null,
        );
        return;
      }

      final investments = await repository.getInvestmentItems(companyId);
      final financings = await repository.getFinancingOptions(companyId);

      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        isMarketComplete: true,
        isInvestmentComplete: isInvestmentComplete,
        investmentItems: investments,
        financingOptions: financings,
        errorMessage: null,
      );
    } catch (e) {
      if (!mounted) return;

      state = state.copyWith(
        isLoading: false,
        isMarketComplete: false,
        isInvestmentComplete: false,
        investmentItems: const [],
        financingOptions: const [],
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> addInvestmentItem(
    InvestmentType type,
    String description,
    double amount,
  ) async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      );

      final normalizedDescription = description.trim();

      await repository.addInvestmentItem(companyId, {
        'itemType': type.name,
        'name': normalizedDescription,
        'description': normalizedDescription,
        'quantity': 1,
        'unitCost': amount,
        if (type == InvestmentType.FIXED_ASSET) 'usefulLifeYears': 5,
      });

      final investments = await repository.getInvestmentItems(companyId);
      state = state.copyWith(
        isLoading: false,
        investmentItems: investments,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearSuccessMessage: true,
      );
    }
  }

  Future<void> addFinancingOption(
    FinancingType type,
    double amount,
    double interestRate,
    int termInMonths,
  ) async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      );

      final annualInterestRate =
          (interestRate / 100).clamp(0.0, 1.0).toDouble();

      await repository.addFinancingOption(companyId, {
        'sourceName': type.displayName,
        'sourceType': type.name,
        'principalAmount': amount,
        'annualInterestRate': annualInterestRate,
        'termMonths': termInMonths,
        'notes':
            'Opción simulada desde el módulo de Inversiones y Financiamiento.',
      });

      final financings = await repository.getFinancingOptions(companyId);
      state = state.copyWith(
        isLoading: false,
        financingOptions: financings,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearSuccessMessage: true,
      );
    }
  }

  Future<void> selectFinancingOption(String optionId) async {
    try {
      state = state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      );
      await repository.selectFinancingOption(companyId, optionId);

      final financings = await repository.getFinancingOptions(companyId);
      state = state.copyWith(
        isLoading: false,
        financingOptions: financings,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearSuccessMessage: true,
      );
    }
  }

  Future<void> completeModule() async {
    if (state.investmentItems.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Debes registrar al menos un requerimiento de inversión.',
        clearSuccessMessage: true,
      );
      return;
    }

    final hasSelectedFinancing =
        state.financingOptions.any((opt) => opt.isSelected);

    if (!hasSelectedFinancing) {
      state = state.copyWith(
        errorMessage:
            'Debes seleccionar una opción de financiamiento para continuar.',
        clearSuccessMessage: true,
      );
      return;
    }

    try {
      state = state.copyWith(
        isLoading: true,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      );
      await repository.completeFinancing(companyId);

      _ref.invalidate(companyModuleProgressProvider);
      _ref.invalidate(global_providers.moduleProgressProvider);

      state = state.copyWith(
        isLoading: false,
        isInvestmentComplete: true,
        successMessage: '¡Estructuración financiera completada exitosamente!',
        clearErrorMessage: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearSuccessMessage: true,
      );
    }
  }
}

final investmentFinancingProvider = StateNotifierProvider.autoDispose
    .family<InvestmentFinancingNotifier, InvestmentFinancingState, String>(
        (ref, companyId) {
  final repository = ref.watch(investmentFinancingRepositoryProvider);
  final companyRepository = ref.watch(companyRepositoryProvider);

  return InvestmentFinancingNotifier(
    repository,
    companyRepository,
    companyId,
    ref,
  );
});
