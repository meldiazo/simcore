import 'package:flutter_test/flutter_test.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';

void main() {
  group('SimModule', () {
    test('mapea valores backend hacia enum frontend', () {
      expect(SimModule.fromApi('MARKET'), SimModule.market);
      expect(SimModule.fromApi('INVESTMENT'), SimModule.investment);
      expect(SimModule.fromApi('ORGANIZATION'), SimModule.organization);
      expect(SimModule.fromApi('ACCOUNTING'), SimModule.accounting);
      expect(SimModule.fromApi('ANALYSIS'), SimModule.analysis);
    });

    test('serializa valores hacia API backend', () {
      expect(SimModule.market.toApi(), 'MARKET');
      expect(SimModule.investment.toApi(), 'INVESTMENT');
      expect(SimModule.organization.toApi(), 'ORGANIZATION');
      expect(SimModule.accounting.toApi(), 'ACCOUNTING');
      expect(SimModule.analysis.toApi(), 'ANALYSIS');
    });
  });

  group('ScenarioType', () {
    test('mapea valores backend', () {
      expect(ScenarioType.fromApi('OPTIMISTIC'), ScenarioType.optimistic);
      expect(ScenarioType.fromApi('PROBABLE'), ScenarioType.probable);
      expect(ScenarioType.fromApi('PESSIMISTIC'), ScenarioType.pessimistic);
    });

    test('serializa valores hacia API', () {
      expect(ScenarioType.optimistic.toApi(), 'OPTIMISTIC');
      expect(ScenarioType.probable.toApi(), 'PROBABLE');
      expect(ScenarioType.pessimistic.toApi(), 'PESSIMISTIC');
    });
  });

  group('ModuleStatus', () {
    test('mapea estados reales del backend', () {
      expect(ModuleStatus.fromApi('PENDING'), ModuleStatus.pending);
      expect(ModuleStatus.fromApi('IN_PROGRESS'), ModuleStatus.inProgress);
      expect(ModuleStatus.fromApi('COMPLETE'), ModuleStatus.complete);
      expect(
        ModuleStatus.fromApi('REQUIRES_REVISION'),
        ModuleStatus.requiresRevision,
      );
      expect(ModuleStatus.fromApi('OUTDATED'), ModuleStatus.outdated);
    });
  });

  group('Domain enums', () {
    test('mapean valores principales del backend', () {
      expect(CompanyStatus.fromApi('IN_SIMULATION'), CompanyStatus.inSimulation);
      expect(DecisionStatus.fromApi('SUPERSEDED'), DecisionStatus.superseded);
      expect(InvestmentItemType.fromApi('FIXED_ASSET'), InvestmentItemType.fixedAsset);
      expect(FinancingSourceType.fromApi('BANK_LOAN'), FinancingSourceType.bankLoan);
      expect(
        FinancialStatementType.fromApi('INCOME_STATEMENT'),
        FinancialStatementType.incomeStatement,
      );
      expect(IncoherenceLevel.fromApi('HIGH'), IncoherenceLevel.high);
      expect(CommentVisibility.fromApi('PRIVATE'), CommentVisibility.private);
    });
  });
}