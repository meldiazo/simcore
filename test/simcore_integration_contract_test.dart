import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:simcore_frontend/features/modules/accounting/data/models/financial_statement_model.dart';
import 'package:simcore_frontend/features/modules/investment_financing/data/models/financing_option_model.dart';
import 'package:simcore_frontend/features/modules/investment_financing/data/models/investment_item_model.dart';
import 'package:simcore_frontend/features/modules/investment_financing/presentation/providers/investment_financing_providers.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  test('escenario activo viaja a modulos principales', () {
    final files = [
      'lib/features/modules/market/data/repositories/market_providers.dart',
      'lib/features/modules/organization/presentation/providers/organization_providers.dart',
      'lib/features/modules/accounting/presentation/providers/accounting_providers.dart',
      'lib/features/modules/analysis/presentation/providers/analysis_providers.dart',
      'lib/features/reports/presentation/providers/report_providers.dart',
      'lib/features/teacher/presentation/providers/teacher_dashboard_providers.dart',
    ];

    for (final file in files) {
      final content = _read(file);
      expect(content, contains('selectedScenarioTypeProvider'), reason: file);
    }
  });

  test('analisis usa endpoint consolidado como fuente principal', () {
    final provider = _read(
      'lib/features/modules/analysis/presentation/providers/analysis_providers.dart',
    );
    final dataSource = _read(
      'lib/features/modules/analysis/data/datasources/analysis_remote_datasource.dart',
    );

    expect(provider, contains('consolidatedAnalysisProvider'));
    expect(provider, contains('getAnalysis(companyId: ctx.companyId'));
    expect(dataSource,
        contains('/api/v1/simulation/companies/\$companyId/analysis'));
  });

  test('reporte exporta el escenario seleccionado', () {
    final provider = _read(
        'lib/features/reports/presentation/providers/report_providers.dart');

    expect(provider, contains('selectedScenarioTypeProvider'));
    expect(provider, contains('exportCompanyPdf('));
    expect(provider, contains('scenarioType: scenarioType'));
    expect(provider, contains('exportCourseCsv('));
  });

  test(
      'mercado usa MarketAssumption como fuente funcional y Decision como auditoria',
      () {
    final page = _read(
        'lib/features/modules/market/presentation/pages/market_page.dart');
    final providers = _read(
        'lib/features/modules/market/data/repositories/market_providers.dart');

    expect(page, contains('updateAssumption(assumption)'));
    expect(page, contains('unawaited('));
    expect(page, contains('createDecision(decision)'));
    expect(providers, contains('_ref.invalidate(marketAssumptionProvider)'));
    expect(providers,
        isNot(contains('_ref.invalidate(companyDecisionsProvider)')));
  });

  test('inversion no completa si hay brecha financiera', () {
    final state = InvestmentFinancingState(
      isMarketComplete: true,
      investmentItems: const [
        InvestmentItemModel(
          id: '1',
          type: InvestmentType.FIXED_ASSET,
          description: 'Equipo',
          amount: 1000,
        ),
      ],
      financingOptions: const [
        FinancingOptionModel(
          id: 'f1',
          type: FinancingType.OWN_CAPITAL,
          amount: 400,
          interestRate: 0,
          termInMonths: 0,
          isSelected: true,
        ),
      ],
    );

    expect(state.hasFinancialGap, isTrue);
  });

  test('contabilidad no completa si estados estan OUTDATED', () {
    final statement = FinancialStatementModel.fromJson({
      'id': 1,
      'companyId': 10,
      'type': 'INCOME_STATEMENT',
      'data': <String, dynamic>{},
      'status': 'OUTDATED',
    });
    final providers = _read(
      'lib/features/modules/accounting/presentation/providers/accounting_providers.dart',
    );

    expect(statement.status, 'OUTDATED');
    expect(providers, contains("== 'OUTDATED'"));
    expect(providers, contains('No se puede completar Contabilidad'));
  });

  test(
      'flujo mercado inversion organizacion contabilidad analisis esta trazado',
      () {
    final market = _read(
        'lib/features/modules/market/presentation/pages/market_page.dart');
    final investment = _read(
      'lib/features/modules/investment_financing/presentation/providers/investment_financing_providers.dart',
    );
    final organization = _read(
      'lib/features/modules/organization/presentation/providers/organization_providers.dart',
    );
    final accounting = _read(
      'lib/features/modules/accounting/presentation/providers/accounting_providers.dart',
    );
    final analysis = _read(
      'lib/features/modules/analysis/presentation/providers/analysis_providers.dart',
    );

    expect(market, contains('investmentFinancingProvider(companyId)'));
    expect(investment, contains('SimModule.market'));
    expect(organization, contains('projectedMonthlyDemand'));
    expect(accounting, contains('financialStatementsProvider'));
    expect(analysis, contains('consolidatedAnalysisProvider'));
  });
}
