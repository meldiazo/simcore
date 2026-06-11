String _normalizeApiEnum(String value) {
  return value.trim().toUpperCase().replaceAll('-', '_').replaceAll(' ', '_');
}

enum SimModule {
  market('MARKET', 'Módulo Mercado'),
  investment('INVESTMENT', 'Inversiones y Financiamiento'),
  organization('ORGANIZATION', 'Estructuras Organizativas'),
  accounting('ACCOUNTING', 'Módulo Contabilidad'),
  analysis('ANALYSIS', 'Análisis General');

  const SimModule(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static SimModule fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'MARKET' => SimModule.market,
      'INVESTMENT' => SimModule.investment,
      'ORGANIZATION' => SimModule.organization,
      'ACCOUNTING' => SimModule.accounting,
      'ANALYSIS' => SimModule.analysis,
      _ => throw ArgumentError.value(value, 'value', 'SimModule no soportado'),
    };
  }
}

enum ScenarioType {
  optimistic('OPTIMISTIC', 'Optimista'),
  probable('PROBABLE', 'Probable'),
  pessimistic('PESSIMISTIC', 'Pesimista');

  const ScenarioType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static ScenarioType fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'OPTIMISTIC' => ScenarioType.optimistic,
      'PROBABLE' => ScenarioType.probable,
      'PESSIMISTIC' => ScenarioType.pessimistic,
      _ => throw ArgumentError.value(value, 'value', 'ScenarioType no soportado'),
    };
  }
}

enum ModuleStatus {
  pending('PENDING', 'Pendiente', 0),
  inProgress('IN_PROGRESS', 'En progreso', 50),
  complete('COMPLETE', 'Completo', 100),
  locked('LOCKED', 'Bloqueado', 100),
  requiresRevision('REQUIRES_REVISION', 'Requiere revisión', 25),
  outdated('OUTDATED', 'Desactualizado', 25);

  const ModuleStatus(this.apiValue, this.label, this.progressHint);

  final String apiValue;
  final String label;
  final int progressHint;

  String toApi() => apiValue;

  bool get isComplete => this == ModuleStatus.complete;

  static ModuleStatus fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'PENDING' => ModuleStatus.pending,
      'IN_PROGRESS' => ModuleStatus.inProgress,
      'COMPLETE' => ModuleStatus.complete,
      'LOCKED' => ModuleStatus.locked,
      'REQUIRES_REVISION' => ModuleStatus.requiresRevision,
      'OUTDATED' => ModuleStatus.outdated,
      _ => throw ArgumentError.value(value, 'value', 'ModuleStatus no soportado'),
    };
  }
}

enum CompanyStatus {
  draft('DRAFT', 'Borrador'),
  inSimulation('IN_SIMULATION', 'Simulando'),
  closed('CLOSED', 'Cerrada');

  const CompanyStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static CompanyStatus fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'DRAFT' => CompanyStatus.draft,
      'IN_SIMULATION' => CompanyStatus.inSimulation,
      'CLOSED' => CompanyStatus.closed,
      _ => throw ArgumentError.value(value, 'value', 'CompanyStatus no soportado'),
    };
  }
}

enum DecisionStatus {
  draft('DRAFT', 'Borrador'),
  submitted('SUBMITTED', 'Enviada'),
  superseded('SUPERSEDED', 'Reemplazada');

  const DecisionStatus(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static DecisionStatus fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'DRAFT' => DecisionStatus.draft,
      'SUBMITTED' => DecisionStatus.submitted,
      'SUPERSEDED' => DecisionStatus.superseded,
      _ => throw ArgumentError.value(value, 'value', 'DecisionStatus no soportado'),
    };
  }
}

enum InvestmentItemType {
  fixedAsset('FIXED_ASSET', 'Activo fijo'),
  workingCapital('WORKING_CAPITAL', 'Capital de trabajo'),
  preOperative('PRE_OPERATIVE', 'Preoperativo');

  const InvestmentItemType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static InvestmentItemType fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'FIXED_ASSET' => InvestmentItemType.fixedAsset,
      'WORKING_CAPITAL' => InvestmentItemType.workingCapital,
      'PRE_OPERATIVE' => InvestmentItemType.preOperative,
      _ => throw ArgumentError.value(value, 'value', 'InvestmentItemType no soportado'),
    };
  }
}

enum FinancingSourceType {
  ownCapital('OWN_CAPITAL', 'Capital propio'),
  bankLoan('BANK_LOAN', 'Préstamo bancario'),
  angelInvestment('ANGEL_INVESTMENT', 'Inversión ángel'),
  governmentGrant('GOVERNMENT_GRANT', 'Subvención pública'),
  crowdfunding('CROWDFUNDING', 'Crowdfunding'),
  other('OTHER', 'Otro');

  const FinancingSourceType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static FinancingSourceType fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'OWN_CAPITAL' => FinancingSourceType.ownCapital,
      'BANK_LOAN' => FinancingSourceType.bankLoan,
      'ANGEL_INVESTMENT' => FinancingSourceType.angelInvestment,
      'GOVERNMENT_GRANT' => FinancingSourceType.governmentGrant,
      'CROWDFUNDING' => FinancingSourceType.crowdfunding,
      'OTHER' => FinancingSourceType.other,
      _ => throw ArgumentError.value(value, 'value', 'FinancingSourceType no soportado'),
    };
  }
}

enum FinancialStatementType {
  incomeStatement('INCOME_STATEMENT', 'Estado de resultados'),
  balanceSheet('BALANCE_SHEET', 'Balance general'),
  cashFlow('CASH_FLOW', 'Flujo de caja'),
  ratios('RATIOS', 'Ratios');

  const FinancialStatementType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static FinancialStatementType fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'INCOME_STATEMENT' => FinancialStatementType.incomeStatement,
      'BALANCE_SHEET' => FinancialStatementType.balanceSheet,
      'CASH_FLOW' => FinancialStatementType.cashFlow,
      'RATIOS' => FinancialStatementType.ratios,
      _ => throw ArgumentError.value(value, 'value', 'FinancialStatementType no soportado'),
    };
  }
}

enum IncoherenceLevel {
  low('LOW', 'Baja'),
  medium('MEDIUM', 'Media'),
  high('HIGH', 'Alta');

  const IncoherenceLevel(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static IncoherenceLevel fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'LOW' => IncoherenceLevel.low,
      'MEDIUM' => IncoherenceLevel.medium,
      'HIGH' => IncoherenceLevel.high,
      _ => throw ArgumentError.value(value, 'value', 'IncoherenceLevel no soportado'),
    };
  }
}

enum CompanySector {
  commerce('COMERCIO', 'Comercio'),
  services('SERVICIOS', 'Servicios'),
  manufacturing('MANUFACTURA', 'Manufactura'),
  technology('TECNOLOGIA', 'Tecnología'),
  agriculture('AGRO', 'Agro'),
  other('OTRO', 'Otro');

  const CompanySector(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static CompanySector fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'COMERCIO' || 'COMMERCE' => CompanySector.commerce,
      'SERVICIOS' || 'SERVICES' => CompanySector.services,
      'MANUFACTURA' || 'MANUFACTURING' => CompanySector.manufacturing,
      'TECNOLOGIA' || 'TECHNOLOGY' => CompanySector.technology,
      'AGRO' || 'AGRICULTURE' => CompanySector.agriculture,
      'OTRO' || 'OTHER' => CompanySector.other,
      _ => CompanySector.other,
    };
  }
}

enum CommentVisibility {
  private('PRIVATE', 'Privado'),
  shared('SHARED', 'Compartido');

  const CommentVisibility(this.apiValue, this.label);

  final String apiValue;
  final String label;

  String toApi() => apiValue;

  static CommentVisibility fromApi(String value) {
    return switch (_normalizeApiEnum(value)) {
      'PRIVATE' => CommentVisibility.private,
      'SHARED' => CommentVisibility.shared,
      _ => throw ArgumentError.value(value, 'value', 'CommentVisibility no soportado'),
    };
  }
}