import 'package:equatable/equatable.dart';

enum DecisionStatus { pending, draft, submitted, locked }

enum AlertKind { info, success, warning, danger }

class StudentUser extends Equatable {
  const StudentUser({
    required this.name,
    required this.email,
    required this.institution,
    required this.role,
    required this.avatar,
    required this.team,
    required this.cohort,
  });

  final String name;
  final String email;
  final String institution;
  final String role;
  final String avatar;
  final String team;
  final String cohort;

  @override
  List<Object?> get props =>
      [name, email, institution, role, avatar, team, cohort];
}

class CurrentCycle extends Equatable {
  const CurrentCycle({
    required this.number,
    required this.name,
    required this.isOpen,
    required this.timeRemaining,
    required this.totalCycles,
  });

  final int number;
  final String name;
  final bool isOpen;
  final String timeRemaining;
  final int totalCycles;

  @override
  List<Object?> get props => [number, name, isOpen, timeRemaining, totalCycles];
}

class KpiMetric extends Equatable {
  const KpiMetric({
    required this.title,
    required this.value,
    required this.unit,
    required this.delta,
    required this.trendUp,
    required this.state,
  });

  final String title;
  final double value;
  final String unit;
  final double delta;
  final bool trendUp;
  final String state;

  @override
  List<Object?> get props => [title, value, unit, delta, trendUp, state];
}

class AlertItem extends Equatable {
  const AlertItem({
    required this.type,
    required this.title,
    required this.message,
    required this.module,
  });

  final AlertKind type;
  final String title;
  final String message;
  final String module;

  @override
  List<Object?> get props => [type, title, message, module];
}

class TeamMember extends Equatable {
  const TeamMember({
    required this.name,
    required this.role,
    required this.status,
  });

  final String name;
  final String role;
  final String status;

  @override
  List<Object?> get props => [name, role, status];
}

class DecisionModule extends Equatable {
  const DecisionModule({
    required this.id,
    required this.name,
    required this.status,
    required this.progress,
    required this.summary,
  });

  final String id;
  final String name;
  final DecisionStatus status;
  final int progress;
  final List<String> summary;

  @override
  List<Object?> get props => [id, name, status, progress, summary];
}

class RankingTeam extends Equatable {
  const RankingTeam({
    required this.rank,
    required this.team,
    required this.score,
    required this.profitability,
    required this.marketShare,
    required this.efficiency,
    required this.change,
  });

  final int rank;
  final String team;
  final double score;
  final double profitability;
  final double marketShare;
  final double efficiency;
  final int change;

  @override
  List<Object?> get props =>
      [rank, team, score, profitability, marketShare, efficiency, change];
}

class MarketSegment extends Equatable {
  const MarketSegment({
    required this.name,
    required this.size,
    required this.growth,
    required this.competition,
  });

  final String name;
  final int size;
  final double growth;
  final String competition;

  @override
  List<Object?> get props => [name, size, growth, competition];
}

class Competitor extends Equatable {
  const Competitor({
    required this.name,
    required this.share,
    required this.strategy,
  });

  final String name;
  final double share;
  final String strategy;

  @override
  List<Object?> get props => [name, share, strategy];
}

class ScenarioData extends Equatable {
  const ScenarioData({
    required this.name,
    required this.revenue,
    required this.profit,
    required this.probability,
  });

  final String name;
  final int revenue;
  final int profit;
  final double probability;

  @override
  List<Object?> get props => [name, revenue, profit, probability];
}

class CashFlowEntry extends Equatable {
  const CashFlowEntry({
    required this.month,
    required this.operational,
    required this.investment,
    required this.financing,
  });

  final String month;
  final int operational;
  final int investment;
  final int financing;

  @override
  List<Object?> get props => [month, operational, investment, financing];
}

class Inefficiency extends Equatable {
  const Inefficiency({
    required this.area,
    required this.issue,
    required this.impact,
    required this.severity,
  });

  final String area;
  final String issue;
  final String impact;
  final String severity;

  @override
  List<Object?> get props => [area, issue, impact, severity];
}

class AdminTeamStatus extends Equatable {
  const AdminTeamStatus({
    required this.name,
    required this.users,
    required this.isReady,
    required this.lastLogin,
  });

  final String name;
  final int users;
  final bool isReady;
  final String lastLogin;

  @override
  List<Object?> get props => [name, users, isReady, lastLogin];
}

const studentUser = StudentUser(
  name: 'Sofia Garcia',
  email: 'sofia.garcia@universidad.edu',
  institution: 'Universidad Empresarial de Buenos Aires',
  role: 'Gerente de Finanzas',
  avatar: 'SG',
  team: 'Equipo Alpha',
  cohort: 'MBA 2026 - Simulacion Empresarial',
);

const currentCycle = CurrentCycle(
  number: 3,
  name: 'Trimestre 3',
  isOpen: true,
  timeRemaining: '2d 14h 32m',
  totalCycles: 8,
);

const teamMembers = [
  TeamMember(
      name: 'Sofia Garcia',
      role: 'Gerente de Finanzas',
      status: 'Decisiones enviadas'),
  TeamMember(
      name: 'Martin Rodriguez',
      role: 'Gerente General',
      status: 'Decisiones enviadas'),
  TeamMember(
      name: 'Carolina Mendez',
      role: 'Gerente de Marketing',
      status: 'En borrador'),
  TeamMember(
      name: 'Diego Fernandez',
      role: 'Responsable de estructura organizativa',
      status: 'Pendiente'),
  TeamMember(
      name: 'Ana Lopez',
      role: 'Gerente de Operaciones',
      status: 'Decisiones enviadas'),
];

const kpiData = [
  KpiMetric(
      title: 'Rentabilidad',
      value: 18.5,
      unit: '%',
      delta: 2.3,
      trendUp: true,
      state: 'success'),
  KpiMetric(
      title: 'Liquidez',
      value: 2.4,
      unit: 'x',
      delta: 0.3,
      trendUp: false,
      state: 'warning'),
  KpiMetric(
      title: 'Endeudamiento',
      value: 45.2,
      unit: '%',
      delta: 4.1,
      trendUp: false,
      state: 'success'),
  KpiMetric(
      title: 'Eficiencia Operacional',
      value: 87.3,
      unit: '%',
      delta: 3.8,
      trendUp: true,
      state: 'success'),
  KpiMetric(
      title: 'Participacion de Mercado',
      value: 14.8,
      unit: '%',
      delta: 1.2,
      trendUp: true,
      state: 'success'),
  KpiMetric(
      title: 'Caja Disponible',
      value: 1245000,
      unit: '\$',
      delta: 8.5,
      trendUp: true,
      state: 'success'),
];

const alerts = [
  AlertItem(
    type: AlertKind.warning,
    title: 'Liquidez por debajo del objetivo',
    message:
        'El ratio actual de liquidez esta por debajo del objetivo estrategico. Ajusta inversiones o capital de trabajo.',
    module: 'Finanzas',
  ),
  AlertItem(
    type: AlertKind.info,
    title: 'Nueva regulacion aplicada',
    message:
        'La nueva regulacion laboral incrementa costos de personal en 8%. Revisa el modulo organizacional.',
    module: 'Organizacional',
  ),
  AlertItem(
    type: AlertKind.success,
    title: 'Objetivo de market share alcanzado',
    message:
        'El equipo supero el objetivo de participacion de mercado del trimestre.',
    module: 'Mercado',
  ),
];

const decisionModules = [
  DecisionModule(
    id: 'market',
    name: 'Modulo Mercado',
    status: DecisionStatus.draft,
    progress: 60,
    summary: [
      'Precio promedio: \$1,250',
      'Marketing: \$450,000',
      'Canales: Online, Retail, B2B'
    ],
  ),
  DecisionModule(
    id: 'finance',
    name: 'Modulo Finanzas',
    status: DecisionStatus.submitted,
    progress: 100,
    summary: [
      'Inversion en activos: \$500,000',
      'Financiamiento: \$250,000',
      'Dividendos: \$100,000'
    ],
  ),
  DecisionModule(
    id: 'hr',
    name: 'Módulo Organización',
    status: DecisionStatus.pending,
    progress: 0,
    summary: [
      'Contrataciones: 8',
      'Capacitacion: \$75,000',
      'Ajuste salarial: 5%'
    ],
  ),
  DecisionModule(
    id: 'operations',
    name: 'Modulo Operaciones',
    status: DecisionStatus.draft,
    progress: 40,
    summary: ['Produccion: 98,000', 'Inventario: 15,000', 'Calidad: \$120,000'],
  ),
];

const rankingData = [
  RankingTeam(
      rank: 1,
      team: 'Equipo Omega',
      score: 94.2,
      profitability: 22.1,
      marketShare: 18.3,
      efficiency: 91.5,
      change: 0),
  RankingTeam(
      rank: 2,
      team: 'Equipo Alpha',
      score: 89.7,
      profitability: 18.5,
      marketShare: 14.8,
      efficiency: 87.3,
      change: 1),
  RankingTeam(
      rank: 3,
      team: 'Equipo Beta',
      score: 87.3,
      profitability: 17.2,
      marketShare: 16.1,
      efficiency: 85.9,
      change: -1),
  RankingTeam(
      rank: 4,
      team: 'Equipo Gamma',
      score: 84.1,
      profitability: 15.8,
      marketShare: 13.2,
      efficiency: 82.4,
      change: 0),
  RankingTeam(
      rank: 5,
      team: 'Equipo Delta',
      score: 79.5,
      profitability: 12.3,
      marketShare: 11.5,
      efficiency: 78.2,
      change: 0),
];

const marketSegments = [
  MarketSegment(name: 'Premium', size: 35, growth: 8.2, competition: 'Alta'),
  MarketSegment(name: 'Media', size: 45, growth: 6.1, competition: 'Media'),
  MarketSegment(
      name: 'Economica', size: 20, growth: 4.5, competition: 'Muy Alta'),
];

const competitors = [
  Competitor(name: 'TechCorp', share: 22.3, strategy: 'Diferenciacion premium'),
  Competitor(
      name: 'ValueElectro', share: 19.1, strategy: 'Liderazgo en costos'),
  Competitor(name: 'MegaStore', share: 18.5, strategy: 'Segmento medio'),
];

const financialScenarios = [
  ScenarioData(
      name: 'Optimista', revenue: 9200000, profit: 1850000, probability: 0.25),
  ScenarioData(
      name: 'Base', revenue: 8450000, profit: 1560000, probability: 0.50),
  ScenarioData(
      name: 'Pesimista', revenue: 7600000, profit: 1140000, probability: 0.25),
];

const cashFlowEntries = [
  CashFlowEntry(
      month: 'Mes 1',
      operational: 450000,
      investment: -250000,
      financing: 100000),
  CashFlowEntry(
      month: 'Mes 2', operational: 520000, investment: -100000, financing: 0),
  CashFlowEntry(
      month: 'Mes 3',
      operational: 580000,
      investment: -150000,
      financing: -50000),
];

const organizationalInefficiencies = [
  Inefficiency(
    area: 'Area de Produccion',
    issue: 'Sobrecarga de personal administrativo',
    impact: 'Costos +12%, Productividad -5%',
    severity: 'media',
  ),
  Inefficiency(
    area: 'Logistica',
    issue: 'Estructura duplicada entre almacen y distribucion',
    impact: 'Costos +8%',
    severity: 'baja',
  ),
];

const adminTeams = [
  AdminTeamStatus(
      name: 'Equipo Alpha', users: 4, isReady: true, lastLogin: 'Hace 2 min'),
  AdminTeamStatus(
      name: 'Innovadores X', users: 5, isReady: true, lastLogin: 'Hace 14 min'),
  AdminTeamStatus(
      name: 'Data Driven', users: 3, isReady: false, lastLogin: 'Hace 1 hora'),
  AdminTeamStatus(
      name: 'Strat Masters', users: 4, isReady: false, lastLogin: 'Ayer'),
  AdminTeamStatus(
      name: 'Futuristics', users: 5, isReady: true, lastLogin: 'Hace 5 min'),
];
