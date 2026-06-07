import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/investment_financing_remote_datasource.dart';
import '../../data/repositories/investment_financing_repository_impl.dart';
import '../../data/models/investment_item_model.dart';
import '../../data/models/financing_option_model.dart';
import 'package:http/http.dart' as http;



final httpClientProvider = Provider((ref) => http.Client());

final investmentFinancingRepositoryProvider = Provider((ref) {
  final client = ref.watch(httpClientProvider);
  final dataSource = InvestmentFinancingRemoteDataSourceImpl(client: client);
  return InvestmentFinancingRepositoryImpl(remoteDataSource: dataSource);
});


class InvestmentFinancingState {
  final bool isLoading;
  final bool isMarketComplete; // Crítico: Validación de integración cruzada
  final List<InvestmentItemModel> investmentItems;
  final List<FinancingOptionModel> financingOptions;
  final String? errorMessage;

  InvestmentFinancingState({
    this.isLoading = false,
    this.isMarketComplete = false,
    this.investmentItems = const [],
    this.financingOptions = const [],
    this.errorMessage,
  });

  InvestmentFinancingState copyWith({
    bool? isLoading,
    bool? isMarketComplete,
    List<InvestmentItemModel>? investmentItems,
    List<FinancingOptionModel>? financingOptions,
    String? errorMessage,
  }) {
    return InvestmentFinancingState(
      isLoading: isLoading ?? this.isLoading,
      isMarketComplete: isMarketComplete ?? this.isMarketComplete,
      investmentItems: investmentItems ?? this.investmentItems,
      financingOptions: financingOptions ?? this.financingOptions,
      errorMessage: errorMessage, 
    );
  }
}



class InvestmentFinancingNotifier extends StateNotifier<InvestmentFinancingState> {
  final InvestmentFinancingRepositoryImpl repository;
  final String companyId;

  InvestmentFinancingNotifier(this.repository, this.companyId) : super(InvestmentFinancingState()) {
    _initializeModule();
  }

  Future<void> _initializeModule() async {
    state = state.copyWith(isLoading: true);
    try {
      // Mock temporal del mercado para poder probar
      final marketReady = true; 

      if (!marketReady) {
        state = state.copyWith(isLoading: false, isMarketComplete: false);
        return; 
      }

      // Si el mercado está listo, cargamos la estructura financiera
      final investments = await repository.getInvestmentItems(companyId);
      final financings = await repository.getFinancingOptions(companyId);

      state = state.copyWith(
        isLoading: false,
        isMarketComplete: true,
        investmentItems: investments,
        financingOptions: financings,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  
  // NUEVO MÉTODO: AGREGAR INVERSIÓN
  
  Future<void> addInvestmentItem(InvestmentType type, String description, double amount) async {
    try {
      
      state = state.copyWith(isLoading: true, errorMessage: null); 
      
      
      await repository.addInvestmentItem(companyId, {
        'type': type.name,
        'description': description,
        'amount': amount,
      });
      
      
      final investments = await repository.getInvestmentItems(companyId);
      state = state.copyWith(isLoading: false, investmentItems: investments);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());

    }

    
    // NUEVO MÉTODO: AGREGAR OPCIÓN DE FINANCIAMIENTO
  Future<void> addFinancingOption(FinancingType type, double amount, double interestRate, int termInMonths) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      await repository.addFinancingOption(companyId, {
        'type': type.name,
        'amount': amount,
        'interestRate': interestRate,
        'termInMonths': termInMonths,
      });
      
      final financings = await repository.getFinancingOptions(companyId);
      state = state.copyWith(isLoading: false, financingOptions: financings);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
  }
  
  
  Future<void> selectFinancingOption(String optionId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await repository.selectFinancingOption(companyId, optionId);
      

      final financings = await repository.getFinancingOptions(companyId);
      state = state.copyWith(isLoading: false, financingOptions: financings);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> completeModule() async {
    if (state.investmentItems.isEmpty) {
      state = state.copyWith(errorMessage: "Debes registrar al menos un requerimiento de inversión.");
      return;
    }
    
    final hasSelectedFinancing = state.financingOptions.any((opt) => opt.isSelected);
    if (!hasSelectedFinancing) {
      state = state.copyWith(errorMessage: "Debes seleccionar una opción de financiamiento para continuar.");
      return;
    }

    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      await repository.completeInvestment(companyId);
      await repository.completeFinancing(companyId);
      await repository.completeModuleProgress(companyId); 
      
      state = state.copyWith(isLoading: false, errorMessage: "¡Estructuración financiera completada exitosamente!");
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}



final investmentFinancingProvider = StateNotifierProvider.family<InvestmentFinancingNotifier, InvestmentFinancingState, String>((ref, companyId) {
  final repository = ref.watch(investmentFinancingRepositoryProvider);
  return InvestmentFinancingNotifier(repository, companyId);
});