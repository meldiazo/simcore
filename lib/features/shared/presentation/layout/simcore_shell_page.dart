import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/academic/presentation/pages/course_manager_page.dart';
import 'package:simcore_frontend/features/academic/presentation/pages/group_manager_page.dart';
import 'package:simcore_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/comparison/presentation/pages/company_comparison_page.dart';
import 'package:simcore_frontend/features/modules/accounting/presentation/pages/accounting_page.dart';
import 'package:simcore_frontend/features/modules/analysis/presentation/pages/analysis_page.dart';
import 'package:simcore_frontend/features/modules/investment_financing/presentation/pages/investment_financing_page.dart';
import 'package:simcore_frontend/features/modules/market/presentation/pages/market_page.dart';
import 'package:simcore_frontend/features/modules/organization/presentation/pages/organization_page.dart';
import 'package:simcore_frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:simcore_frontend/features/reports/presentation/pages/company_report_page.dart';
import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/pages/company_workspace_page.dart';
import 'package:simcore_frontend/features/simulation/decisions/presentation/pages/decisions_center_page.dart';
import 'package:simcore_frontend/features/simulation/scenario/presentation/pages/scenario_manager_page.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_providers.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/teacher/presentation/pages/teacher_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SimcoreSection {
  workspace,
  decisions,
  market,
  investment,
  organization,
  accounting,
  analysis,
  ranking,
  profile,
  teacher,
  courseManager,
  groupManager,
  scenarioManager,
  report,
}

class SimcoreDestination {
  const SimcoreDestination({
    required this.section,
    required this.label,
    required this.route,
    required this.icon,
  });

  final SimcoreSection section;
  final String label;
  final String route;
  final IconData icon;
}

const _studentDestinations = [
  SimcoreDestination(
    section: SimcoreSection.workspace,
    label: 'Workspace Ejecutivo',
    route: AppRouter.workspace,
    icon: Icons.space_dashboard_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.decisions,
    label: 'Centro de Decisiones',
    route: AppRouter.decisions,
    icon: Icons.schedule_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.market,
    label: 'Módulo Mercado',
    route: AppRouter.market,
    icon: Icons.trending_up_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.investment,
    label: 'Inversiones y Financiamiento',
    route: AppRouter.investment,
    icon: Icons.attach_money_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.organization,
    label: 'Estructuras Organizativas',
    route: AppRouter.organization,
    icon: Icons.groups_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.accounting,
    label: 'Módulo Contabilidad',
    route: AppRouter.accounting,
    icon: Icons.receipt_long_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.analysis,
    label: 'Análisis General',
    route: AppRouter.analysis,
    icon: Icons.insert_chart_outlined_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.report,
    label: 'Reporte Final',
    route: AppRouter.report,
    icon: Icons.description_rounded,
  ),
];

const _teacherDestinations = [
  SimcoreDestination(
    section: SimcoreSection.teacher,
    label: 'Panel Docente',
    route: AppRouter.teacher,
    icon: Icons.admin_panel_settings_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.courseManager,
    label: 'Gestión de Cursos',
    route: AppRouter.courseManager,
    icon: Icons.school_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.groupManager,
    label: 'Gestión de Grupos',
    route: AppRouter.groupManager,
    icon: Icons.group_work_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.scenarioManager,
    label: 'Gestión de Escenarios',
    route: AppRouter.scenarioManager,
    icon: Icons.tune_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.ranking,
    label: 'Comparación',
    route: AppRouter.ranking,
    icon: Icons.compare_arrows_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.report,
    label: 'Reporte Final',
    route: AppRouter.report,
    icon: Icons.description_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.workspace,
    label: 'Workspace de Empresa',
    route: AppRouter.workspace,
    icon: Icons.space_dashboard_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.market,
    label: 'Revisar Mercado',
    route: AppRouter.market,
    icon: Icons.trending_up_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.investment,
    label: 'Revisar Inversión',
    route: AppRouter.investment,
    icon: Icons.attach_money_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.organization,
    label: 'Revisar Organización',
    route: AppRouter.organization,
    icon: Icons.groups_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.accounting,
    label: 'Revisar Contabilidad',
    route: AppRouter.accounting,
    icon: Icons.receipt_long_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.analysis,
    label: 'Revisar Análisis',
    route: AppRouter.analysis,
    icon: Icons.insert_chart_outlined_rounded,
  ),
];

const _adminDestinations = [
  SimcoreDestination(
    section: SimcoreSection.teacher,
    label: 'Panel de Control',
    route: AppRouter.teacher,
    icon: Icons.admin_panel_settings_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.courseManager,
    label: 'Gestión de Cursos',
    route: AppRouter.courseManager,
    icon: Icons.school_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.groupManager,
    label: 'Gestión de Grupos',
    route: AppRouter.groupManager,
    icon: Icons.group_work_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.scenarioManager,
    label: 'Gestión de Escenarios',
    route: AppRouter.scenarioManager,
    icon: Icons.tune_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.ranking,
    label: 'Comparación',
    route: AppRouter.ranking,
    icon: Icons.compare_arrows_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.report,
    label: 'Reporte Final',
    route: AppRouter.report,
    icon: Icons.description_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.workspace,
    label: 'Workspace de Empresa',
    route: AppRouter.workspace,
    icon: Icons.space_dashboard_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.market,
    label: 'Revisar Mercado',
    route: AppRouter.market,
    icon: Icons.trending_up_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.investment,
    label: 'Revisar Inversión',
    route: AppRouter.investment,
    icon: Icons.attach_money_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.organization,
    label: 'Revisar Organización',
    route: AppRouter.organization,
    icon: Icons.groups_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.accounting,
    label: 'Revisar Contabilidad',
    route: AppRouter.accounting,
    icon: Icons.receipt_long_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.analysis,
    label: 'Revisar Análisis',
    route: AppRouter.analysis,
    icon: Icons.insert_chart_outlined_rounded,
  ),
];

class SimcoreShellPage extends ConsumerWidget {
  const SimcoreShellPage({super.key, required this.section});

  final SimcoreSection section;

  Widget _buildContent(WidgetRef ref) {
    return switch (section) {
      SimcoreSection.workspace => const WorkspacePage(),
      SimcoreSection.decisions => const DecisionsPage(),
      SimcoreSection.market => const MarketPage(),
      SimcoreSection.investment => _buildInvestmentContent(ref),
      SimcoreSection.organization => const OrganizationPage(),
      SimcoreSection.accounting => const AccountingPage(),
      SimcoreSection.analysis => const AnalysisPage(),
      SimcoreSection.ranking => const CompanyComparisonPage(),
      SimcoreSection.profile => const ProfilePage(),
      SimcoreSection.teacher => const TeacherDashboardPage(),
      SimcoreSection.courseManager => const CourseManagerPage(),
      SimcoreSection.groupManager => const GroupManagerPage(),
      SimcoreSection.scenarioManager => const ScenarioManagerPage(),
      SimcoreSection.report => const CompanyReportPage(),
    };
  }

  Widget _buildInvestmentContent(WidgetRef ref) {
    final contextState = ref.watch(simulationContextNotifierProvider);
    final simulationContext = contextState.context;

    if (simulationContext == null) {
      return _SimulationContextRequiredState(status: contextState.status);
    }

    return InvestmentFinancingPage(
      companyId: simulationContext.companyId.toString(),
    );
  }

  void _navigate(BuildContext context, SimcoreDestination destination) {
    if (destination.section == section) {
      Navigator.of(context).maybePop();
      return;
    }
    Navigator.of(context).pushReplacementNamed(destination.route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;

        return Scaffold(
          appBar: isDesktop
              ? null
              : AppBar(
                  title: const Text(
                    'SIMCORE',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.5,
                      color: SimcoreColors.textPrimary,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: Colors.white.withValues(alpha: 0.88),
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  bottom: const PreferredSize(
                    preferredSize: Size.fromHeight(1),
                    child: Divider(
                      height: 1,
                      color: SimcoreColors.border,
                    ),
                  ),
                ),
          drawer: isDesktop
              ? null
              : Drawer(
                  child: _Sidebar(
                    section: section,
                    onTap: (d) => _navigate(context, d),
                  ),
                ),
          body: Row(
            children: [
              if (isDesktop)
                SizedBox(
                  width: 290,
                  child: _Sidebar(
                    section: section,
                    onTap: (d) => _navigate(context, d),
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildContent(ref),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SimulationContextRequiredState extends StatelessWidget {
  const _SimulationContextRequiredState({required this.status});

  final SimulationContextStatus status;

  @override
  Widget build(BuildContext context) {
    final isLoading = status == SimulationContextStatus.initial ||
        status == SimulationContextStatus.loading;

    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GlassPanel(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contexto de simulación requerido',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: SimcoreColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Para abrir Inversiones y Financiamiento primero debes cargar una empresa o grupo. '
            'Así el módulo usará el companyId real del flujo y no una empresa fija.',
            style: TextStyle(
              color: SimcoreColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(AppRouter.groupSetup);
            },
            icon: const Icon(Icons.business_rounded),
            label: const Text('Seleccionar grupo o empresa'),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends ConsumerWidget {
  const _Sidebar({
    required this.section,
    required this.onTap,
  });

  final SimcoreSection section;
  final ValueChanged<SimcoreDestination> onTap;

    List<SimcoreDestination> _filterDestinations(AuthUser? user) {
    if (user == null) return const [];

    final baseDestinations = user.isAdmin
        ? _adminDestinations
        : user.isDocente
            ? _teacherDestinations
            : _studentDestinations;

    return baseDestinations
        .where((destination) => AppRouter.canAccessRoute(destination.route, user))
        .toList(growable: false);
  }

  // Mapea las secciones de la UI a los módulos de la simulación
  static const Map<SimcoreSection, SimModule> _sectionToModuleMap = {
    SimcoreSection.market: SimModule.market,
    SimcoreSection.investment: SimModule.investment,
    SimcoreSection.organization: SimModule.organization,
    SimcoreSection.accounting: SimModule.accounting,
    SimcoreSection.analysis: SimModule.analysis,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final modulesAsync = ref.watch(moduleProgressProvider);
    final visibleDestinations = _filterDestinations(user);

    // Creamos un mapa para buscar eficientemente el progreso de cada módulo
    final moduleProgressMap = modulesAsync.when(
      data: (modules) => {for (var m in modules) m.module: m},
      loading: () => <SimModule, ModuleProgress>{},
      error: (_, __) => <SimModule, ModuleProgress>{},
    );

    final username = user?.username ?? 'Usuario';
    final roles = user?.roles ?? const <String>[];
    final roleText = roles.isEmpty ? 'Sin rol' : roles.join(', ');
    final avatarText = username.isNotEmpty ? username.substring(0, 1).toUpperCase() : '?';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        border: const Border(right: BorderSide(color: SimcoreColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SIMCORE',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: SimcoreColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Simulación Empresarial',
                    style: TextStyle(
                      fontSize: 12,
                      color: SimcoreColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                children: visibleDestinations.map((destination) {
                  final active = destination.section == section;

                  // Buscamos el progreso del módulo correspondiente a esta sección del menú
                  final simModule = _sectionToModuleMap[destination.section];
                  final progress = simModule != null ? moduleProgressMap[simModule] : null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onTap(destination),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: active ? SimcoreColors.accentSoft : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: active
                              ? Border.all(color: SimcoreColors.accent.withValues(alpha: 0.18))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              destination.icon,
                              color: active ? SimcoreColors.accent : SimcoreColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                destination.label,
                                style: TextStyle(
                                  color: active ? SimcoreColors.accent : SimcoreColors.textSecondary,
                                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                            _ModuleStatusIndicator(status: progress?.status),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
                        if (user != null && user.isAdmin)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRouter.register),
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('Crear usuario'),
                  style: FilledButton.styleFrom(
                    backgroundColor: SimcoreColors.accent,
                    minimumSize: const Size(double.infinity, 42),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: SimcoreColors.accent,
                      child: Text(
                        avatarText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            roleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: SimcoreColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Cerrar sesión',
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).logout();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRouter.login,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout_rounded, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleStatusIndicator extends StatelessWidget {
  const _ModuleStatusIndicator({this.status});

  final ModuleStatus? status;

  @override
  Widget build(BuildContext context) {
    final Widget icon;
    switch (status) {
      case ModuleStatus.complete:
        icon = const Icon(Icons.check_circle_outline_rounded, color: SimcoreColors.success, size: 18);
        break;
      case ModuleStatus.inProgress:
        icon = const Icon(Icons.data_usage_rounded, color: SimcoreColors.accent, size: 18);
        break;
      case ModuleStatus.locked:
        icon = const Icon(Icons.lock_outline_rounded, color: SimcoreColors.danger, size: 18); // Un módulo bloqueado no se puede editar.
        break;
      case ModuleStatus.pending:
        icon = const Icon(Icons.circle_outlined, color: SimcoreColors.textTertiary, size: 14);
        break;
      default:
        return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: icon,
    );
  }
}
