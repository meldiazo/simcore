import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simcore_frontend/core/config/app_config.dart';
import 'package:simcore_frontend/core/network/api_client.dart';
import 'package:simcore_frontend/features/comparison/data/datasources/comparison_remote_datasource.dart';
import 'package:simcore_frontend/features/comparison/presentation/providers/comparison_providers.dart';
import 'package:simcore_frontend/features/modules/accounting/data/models/accounting_entry_model.dart';
import 'package:simcore_frontend/features/modules/accounting/data/models/financial_statement_model.dart';
import 'package:simcore_frontend/features/modules/accounting/data/repositories/accounting_repository_impl.dart';
import 'package:simcore_frontend/features/modules/accounting/presentation/providers/accounting_providers.dart';
import 'package:simcore_frontend/features/modules/analysis/data/datasources/analysis_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/analysis/data/models/consolidated_analysis_model.dart';
import 'package:simcore_frontend/features/modules/analysis/presentation/providers/analysis_providers.dart';
import 'package:simcore_frontend/features/modules/investment_financing/data/models/financing_option_model.dart';
import 'package:simcore_frontend/features/modules/investment_financing/data/models/investment_item_model.dart';
import 'package:simcore_frontend/features/modules/investment_financing/presentation/providers/investment_financing_providers.dart';
import 'package:simcore_frontend/features/modules/market/data/models/market_assumption_model.dart';
import 'package:simcore_frontend/features/modules/market/data/models/sales_projection_model.dart';
import 'package:simcore_frontend/features/modules/market/domain/entities/repositories/market_repository.dart';
import 'package:simcore_frontend/features/modules/market/data/repositories/market_providers.dart';
import 'package:simcore_frontend/features/modules/organization/data/datasources/organization_remote_datasource.dart';
import 'package:simcore_frontend/features/modules/organization/domain/entities/organization_area.dart';
import 'package:simcore_frontend/features/modules/organization/presentation/providers/organization_providers.dart';
import 'package:simcore_frontend/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:simcore_frontend/features/reports/presentation/providers/report_providers.dart'
    as report_providers;
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/scenario_context_provider.dart';

void main() {
  test('cambiar escenario afecta mercado, organizacion, contabilidad, analisis y reporte', () async {
    final market = _FakeMarketRepository();
    final organization = _FakeOrganizationDataSource();
    final accounting = _FakeAccountingRepository();
    final analysis = _FakeAnalysisDataSource(
      analysis: _completeAnalysis(),
    );
    final reports = _FakeReportsDataSource();
    final container = _container(overrides: [
      marketRepositoryProvider.overrideWith((ref) => market),
      organizationRemoteDataSourceProvider.overrideWith((ref) => organization),
      accountingRepositoryProvider.overrideWith((ref) => accounting),
      analysisRemoteDataSourceProvider.overrideWith((ref) => analysis),
      reportsDataSourceProvider.overrideWith((ref) => reports),
    ]);
    addTearDown(container.dispose);

    container.read(scenarioTypeOverrideProvider.notifier).state = 'OPTIMISTIC';

    expect(await container.read(marketNotifierProvider.notifier).generateProjection(), isTrue);
    await container.read(organizationSummaryProvider.future);
    await container.read(accountingActionsProvider).generateEntries('1');
    await container.read(consolidatedAnalysisProvider.future);
    await container.read(report_providers.narrativeReportProvider.future);
    await container
        .read(report_providers.reportExportNotifierProvider.notifier)
        .downloadPdf(1);

    expect(market.generatedScenario, 'OPTIMISTIC');
    expect(organization.summaryScenario, 'OPTIMISTIC');
    expect(accounting.entriesScenario, 'OPTIMISTIC');
    expect(analysis.analysisScenario, 'OPTIMISTIC');
    expect(reports.reportScenario, 'OPTIMISTIC');
    expect(reports.pdfScenario, 'OPTIMISTIC');
  });

  test('comparacion usa el mismo escenario global', () async {
    final comparison = _FakeComparisonDataSource();
    final container = _container(overrides: [
      comparisonDataSourceProvider.overrideWith((ref) => comparison),
    ]);
    addTearDown(container.dispose);

    container.read(scenarioTypeOverrideProvider.notifier).state = 'PESSIMISTIC';

    final result = await container.read(courseComparisonProvider.future);

    expect(result['scenarioType'], 'PESSIMISTIC');
    expect(comparison.scenarioType, 'PESSIMISTIC');
  });

  test('analisis no completa sin narrativa', () async {
    final analysis = _FakeAnalysisDataSource(
      analysis: ConsolidatedAnalysisModel.fromJson({
        'financialIndicators': {'van': 1000},
        'narrativeReport': <String, dynamic>{},
        'incoherences': <Map<String, dynamic>>[],
        'incoherencesReviewed': true,
      }),
    );
    final container = _container(overrides: [
      analysisRemoteDataSourceProvider.overrideWith((ref) => analysis),
    ]);
    addTearDown(container.dispose);

    await container.read(analysisNotifierProvider.notifier).completeModule();

    expect(container.read(analysisNotifierProvider).hasError, isTrue);
    expect(analysis.completeCalled, isFalse);
  });

  test('contabilidad no completa con estados OUTDATED', () async {
    final accounting = _FakeAccountingRepository(
      statements: [
        FinancialStatementModel.fromJson({
          'id': 1,
          'companyId': 1,
          'type': 'INCOME_STATEMENT',
          'data': <String, dynamic>{},
          'status': 'OUTDATED',
        }),
      ],
    );
    final container = _container(overrides: [
      accountingRepositoryProvider.overrideWith((ref) => accounting),
    ]);
    addTearDown(container.dispose);

    await expectLater(
      container.read(accountingActionsProvider).completeModule('1'),
      throwsA(isA<StateError>()),
    );
    expect(accounting.completeCalled, isFalse);
  });

  test('organizacion rechaza headcount y salary invalidos', () async {
    final dataSource = OrganizationRemoteDataSource(ApiClient(baseUrl: 'http://fake.local'));

    await expectLater(
      dataSource.createPosition(
        companyId: 1,
        data: {
          'areaId': 1,
          'title': 'Ventas',
          'headcount': 0,
          'monthlySalary': 0,
          'capacityPerPerson': 10,
        },
      ),
      throwsA(isA<FormatException>()),
    );
  });

  test('flujo mercado inversion organizacion contabilidad analisis conserva las guardas', () async {
    final market = _FakeMarketRepository();
    final organization = _FakeOrganizationDataSource();
    final accounting = _FakeAccountingRepository();
    final analysis = _FakeAnalysisDataSource(analysis: _completeAnalysis());
    final container = _container(overrides: [
      marketRepositoryProvider.overrideWith((ref) => market),
      organizationRemoteDataSourceProvider.overrideWith((ref) => organization),
      accountingRepositoryProvider.overrideWith((ref) => accounting),
      analysisRemoteDataSourceProvider.overrideWith((ref) => analysis),
    ]);
    addTearDown(container.dispose);

    final investment = InvestmentFinancingState(
      isMarketComplete: true,
      investmentItems: const [
        InvestmentItemModel(
          id: 'item-1',
          type: InvestmentType.FIXED_ASSET,
          description: 'Equipos',
          amount: 1000,
        ),
      ],
      financingOptions: const [
        FinancingOptionModel(
          id: 'fin-1',
          type: FinancingType.OWN_CAPITAL,
          amount: 1000,
          interestRate: 0,
          termInMonths: 0,
          isSelected: true,
        ),
      ],
    );

    expect(await container.read(marketNotifierProvider.notifier).generateProjection(), isTrue);
    expect(investment.hasFinancialGap, isFalse);
    expect((await container.read(organizationSummaryProvider.future)).projectedMonthlyDemand, greaterThan(0));
    await container.read(accountingActionsProvider).completeModule('1');
    await container.read(analysisNotifierProvider.notifier).completeModule();

    expect(accounting.completeCalled, isTrue);
    expect(analysis.completeCalled, isTrue);
  });
}

ProviderContainer _container({List<Override> overrides = const []}) {
  return ProviderContainer(
    overrides: [
      appConfigProvider.overrideWith((ref) => AppConfig.devMock()),
      scenarioTypeOverrideProvider.overrideWith((ref) => 'PROBABLE'),
      ...overrides,
    ],
  );
}

ConsolidatedAnalysisModel _completeAnalysis() {
  return ConsolidatedAnalysisModel.fromJson({
    'financialIndicators': {'van': 1000, 'tir': 0.18},
    'narrativeReport': {'summary': 'La empresa mantiene coherencia operativa.'},
    'incoherences': <Map<String, dynamic>>[],
    'incoherencesReviewed': true,
  });
}

class _FakeMarketRepository implements MarketRepository {
  String? generatedScenario;

  @override
  Future<void> completeMarket(String companyId) async {}

  @override
  Future<MarketAssumptionModel?> getAssumption(String companyId) async {
    return MarketAssumptionModel(
      targetSegment: 'Universitarios',
      marketSizeEstimate: 10000,
      demandUnitsPerMonth: 100,
      competitionDescription: 'Competencia moderada',
      estimatedUnitPrice: 25,
      commercialJustification: 'Demanda validada',
    );
  }

  @override
  Future<SalesProjectionModel?> getProjection(String companyId) async {
    return SalesProjectionModel(
      monthlyDemand: 100,
      estimatedPrice: 25,
      projectedRevenue: 2500,
      scenario: generatedScenario ?? 'PROBABLE',
    );
  }

  @override
  Future<SalesProjectionModel> generateProjection(
    String companyId, {
    required String scenarioType,
  }) async {
    generatedScenario = scenarioType;
    return SalesProjectionModel(
      monthlyDemand: 100,
      estimatedPrice: 25,
      projectedRevenue: 2500,
      scenario: scenarioType,
    );
  }

  @override
  Future<MarketAssumptionModel> updateAssumption(
    String companyId,
    MarketAssumptionModel assumption,
  ) async {
    return assumption;
  }
}

class _FakeOrganizationDataSource extends OrganizationRemoteDataSource {
  _FakeOrganizationDataSource() : super(ApiClient(baseUrl: 'http://fake.local'));

  String? summaryScenario;

  @override
  Future<OrganizationSummary> getSummary({
    required int companyId,
    required String scenarioType,
  }) async {
    summaryScenario = scenarioType;
    return OrganizationSummary(
      companyId: companyId,
      areas: const [],
      positions: const [
        OrganizationPosition(
          id: 1,
          areaId: 1,
          title: 'Ventas',
          headcount: 2,
          monthlySalary: 500,
          capacityPerPerson: 60,
        ),
      ],
      monthlyPersonnelCost: 1000,
      estimatedMonthlyCapacity: 120,
      projectedMonthlyDemand: 100,
      warnings: const [],
    );
  }
}

class _FakeAccountingRepository implements AccountingRepository {
  _FakeAccountingRepository({List<FinancialStatementModel>? statements})
      : statements = statements ??
            [
              FinancialStatementModel.fromJson({
                'id': 1,
                'companyId': 1,
                'type': 'INCOME_STATEMENT',
                'data': <String, dynamic>{'revenue': 2500},
                'status': 'CURRENT',
              }),
            ];

  final List<FinancialStatementModel> statements;
  String? entriesScenario;
  bool completeCalled = false;

  @override
  Future<void> completeAccountingModule(String companyId) async {
    completeCalled = true;
  }

  @override
  Future<void> generateAccountingEntries(String companyId, String scenarioType) async {
    entriesScenario = scenarioType;
  }

  @override
  Future<void> generateFinancialStatements(String companyId, String scenarioType) async {}

  @override
  Future<List<AccountingEntryModel>> getAccountingEntries(
    String companyId,
    String scenarioType,
  ) async {
    entriesScenario = scenarioType;
    return const [];
  }

  @override
  Future<List<FinancialStatementModel>> getFinancialStatements(
    String companyId,
    String scenarioType,
  ) async {
    return statements;
  }
}

class _FakeAnalysisDataSource extends AnalysisRemoteDataSource {
  _FakeAnalysisDataSource({required this.analysis})
      : super(ApiClient(baseUrl: 'http://fake.local'));

  final ConsolidatedAnalysisModel analysis;
  String? analysisScenario;
  bool completeCalled = false;

  @override
  Future<ConsolidatedAnalysisModel?> getAnalysis({
    required int companyId,
    required String scenarioType,
  }) async {
    analysisScenario = scenarioType;
    return analysis;
  }

  @override
  Future<void> completeModule({required int companyId}) async {
    completeCalled = true;
  }
}

class _FakeReportsDataSource extends ReportsRemoteDataSource {
  _FakeReportsDataSource() : super(ApiClient(baseUrl: 'http://fake.local'));

  String? reportScenario;
  String? pdfScenario;

  @override
  Future<Map<String, dynamic>> getCompanyReport({
    required int companyId,
    required String scenarioType,
  }) async {
    reportScenario = scenarioType;
    return {
      'companyId': companyId,
      'scenarioType': scenarioType,
      'grossMarginPct': 25,
    };
  }

  @override
  Future<List<int>> exportCompanyPdf({
    required int companyId,
    required String scenarioType,
  }) async {
    pdfScenario = scenarioType;
    return const [1, 2, 3];
  }

  @override
  Future<List<int>> exportCourseCsv({
    required int courseId,
    required String scenarioType,
  }) async {
    return const [1, 2, 3];
  }
}

class _FakeComparisonDataSource extends ComparisonRemoteDataSource {
  _FakeComparisonDataSource() : super(ApiClient(baseUrl: 'http://fake.local'));

  String? scenarioType;

  @override
  Future<Map<String, dynamic>> getCourseComparison({
    required int courseId,
    required String scenarioType,
  }) async {
    this.scenarioType = scenarioType;
    return {
      'courseId': courseId,
      'scenarioType': scenarioType,
      'companies': const [],
    };
  }
}
