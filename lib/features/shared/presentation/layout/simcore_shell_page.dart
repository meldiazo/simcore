import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/simulation/company/presentation/pages/company_workspace_page.dart';
import 'package:simcore_frontend/features/simulation/decisions/presentation/pages/decisions_center_page.dart';
import 'package:simcore_frontend/features/modules/market/presentation/pages/market_page.dart';
import 'package:simcore_frontend/features/modules/finance/presentation/pages/finance_page.dart';
import 'package:simcore_frontend/features/modules/organization/presentation/pages/organization_page.dart';
import 'package:simcore_frontend/features/modules/analysis/presentation/pages/analysis_page.dart';
import 'package:simcore_frontend/features/ranking/presentation/pages/ranking_page.dart';
import 'package:simcore_frontend/features/profile/presentation/pages/profile_page.dart';
import 'package:simcore_frontend/features/teacher/presentation/pages/teacher_dashboard_page.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:simcore_frontend/core/config/app_config.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/demo_mode_banner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SimcoreSection {
  workspace,
  decisions,
  market,
  finance,
  organization,
  accounting,
  analysis,
  ranking,
  profile,
  teacher,
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

const destinations = [
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
    section: SimcoreSection.finance,
    label: 'Módulo Finanzas',
    route: AppRouter.finance,
    icon: Icons.attach_money_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.organization,
    label: 'Módulo Organización',
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
    section: SimcoreSection.ranking,
    label: 'Ranking',
    route: AppRouter.ranking,
    icon: Icons.emoji_events_rounded,
  ),
  SimcoreDestination(
    section: SimcoreSection.teacher,
    label: '[Docente] Panel',
    route: AppRouter.teacher,
    icon: Icons.admin_panel_settings_rounded,
  ),
];

class SimcoreShellPage extends StatelessWidget {
  const SimcoreShellPage({super.key, required this.section});

  final SimcoreSection section;

  Widget _buildContent() {
    return switch (section) {
      SimcoreSection.workspace => const WorkspacePage(),
      SimcoreSection.decisions => const DecisionsPage(),
      SimcoreSection.market => const MarketPage(),
      SimcoreSection.finance => const FinancePage(),

      // Temporalmente usamos la pantalla que antes era RRHH.
      // Más adelante esta pantalla debe quedar renombrada como OrganizationPage.
      SimcoreSection.organization => const OrganizationPage(),

      // Temporalmente usamos AnalysisPage como placeholder visual.
      // Luego debe reemplazarse por AccountingPage cuando creemos esa pantalla.
      SimcoreSection.accounting => const AnalysisPage(),
      SimcoreSection.analysis => const AnalysisPage(),
      SimcoreSection.ranking => const RankingPage(),
      SimcoreSection.profile => const ProfilePage(),

      // Temporalmente usamos la pantalla que antes era Admin.
      // Más adelante esta pantalla debe quedar renombrada como TeacherDashboardPage.
      SimcoreSection.teacher => const TeacherDashboardPage(),
    };
  }

  void _navigate(BuildContext context, SimcoreDestination destination) {
    if (destination.section == section) {
      Navigator.of(context).maybePop();
      return;
    }

    Navigator.of(context).pushReplacementNamed(destination.route);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;

        return Scaffold(
          drawer: isDesktop
              ? null
              : Drawer(
                  child: _Sidebar(
                    section: section,
                    onTap: (d) => _navigate(context, d),
                  ),
                ),
          appBar: isDesktop
              ? null
              : AppBar(
                  title: const Text('SIMCORE'),
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRouter.profile),
                      icon: const Icon(Icons.account_circle_outlined),
                    ),
                  ],
                ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF7FAFF),
                  Color(0xFFF4F7FB),
                  Color(0xFFEFF4FF),
                ],
              ),
            ),
            child: Row(
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
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 24 : 16,
                          vertical: isDesktop ? 0 : 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.72),
                          border: const Border(
                            bottom: BorderSide(color: SimcoreColors.border),
                          ),
                        ),
                        child: Wrap(
                          spacing: 18,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const CycleChip(),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Equipo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: SimcoreColors.textTertiary,
                                  ),
                                ),
                                Text(
                                  studentUser.team,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.of(context)
                                  .pushReplacementNamed(AppRouter.profile),
                              icon: const Icon(Icons.person_outline_rounded),
                              label: Text(
                                studentUser.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SafeArea(
                          top: false,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(isDesktop ? 24 : 14),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 1320),
                                child: _buildContent(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        border: const Border(
          right: BorderSide(color: SimcoreColors.border),
        ),
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
                children: destinations.map((destination) {
                  final active = destination.section == section;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => onTap(destination),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: active
                              ? SimcoreColors.accentSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: active
                              ? Border.all(
                                  color: SimcoreColors.accent
                                      .withValues(alpha: 0.18),
                                )
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              destination.icon,
                              color: active
                                  ? SimcoreColors.accent
                                  : SimcoreColors.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                destination.label,
                                style: TextStyle(
                                  color: active
                                      ? SimcoreColors.accent
                                      : SimcoreColors.textSecondary,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
            if (user != null && user.canManageUsers)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRouter.register),
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
                        studentUser.avatar,
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
                            studentUser.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            studentUser.role,
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
                      onPressed: () => onTap(
                        destinations.firstWhere(
                          (e) => e.section == SimcoreSection.profile,
                        ),
                      ),
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
