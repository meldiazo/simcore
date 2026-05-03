import 'package:core_sim_ia/app/router.dart';
import 'package:core_sim_ia/app/theme.dart';
import 'package:core_sim_ia/features/stratova/data/stratova_mock_data.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/admin_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/analysis_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/decisions_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/finance_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/hr_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/market_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/operations_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/profile_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/ranking_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/pages/workspace_page.dart';
import 'package:core_sim_ia/features/stratova/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';

enum StratovaSection {
  workspace,
  decisions,
  market,
  finance,
  hr,
  operations,
  analysis,
  ranking,
  profile,
  admin,
}

class StratovaDestination {
  const StratovaDestination({
    required this.section,
    required this.label,
    required this.route,
    required this.icon,
  });

  final StratovaSection section;
  final String label;
  final String route;
  final IconData icon;
}

const destinations = [
  StratovaDestination(
      section: StratovaSection.workspace,
      label: 'Workspace Ejecutivo',
      route: AppRouter.workspace,
      icon: Icons.space_dashboard_rounded),
  StratovaDestination(
      section: StratovaSection.decisions,
      label: 'Centro de Decisiones',
      route: AppRouter.decisions,
      icon: Icons.schedule_rounded),
  StratovaDestination(
      section: StratovaSection.market,
      label: 'Modulo Mercado',
      route: AppRouter.market,
      icon: Icons.trending_up_rounded),
  StratovaDestination(
      section: StratovaSection.finance,
      label: 'Modulo Finanzas',
      route: AppRouter.finance,
      icon: Icons.attach_money_rounded),
  StratovaDestination(
      section: StratovaSection.hr,
      label: 'Modulo RRHH',
      route: AppRouter.hr,
      icon: Icons.groups_rounded),
  StratovaDestination(
      section: StratovaSection.operations,
      label: 'Modulo Operaciones',
      route: AppRouter.operations,
      icon: Icons.settings_rounded),
  StratovaDestination(
      section: StratovaSection.analysis,
      label: 'Analisis General',
      route: AppRouter.analysis,
      icon: Icons.insert_chart_outlined_rounded),
  StratovaDestination(
      section: StratovaSection.ranking,
      label: 'Ranking',
      route: AppRouter.ranking,
      icon: Icons.emoji_events_rounded),
  StratovaDestination(
      section: StratovaSection.admin,
      label: '[Docente] Admin',
      route: AppRouter.admin,
      icon: Icons.admin_panel_settings_rounded),
];

class StratovaShellPage extends StatelessWidget {
  const StratovaShellPage({super.key, required this.section});

  final StratovaSection section;

  Widget _buildContent() {
    return switch (section) {
      StratovaSection.workspace => const WorkspacePage(),
      StratovaSection.decisions => const DecisionsPage(),
      StratovaSection.market => const MarketPage(),
      StratovaSection.finance => const FinancePage(),
      StratovaSection.hr => const HrPage(),
      StratovaSection.operations => const OperationsPage(),
      StratovaSection.analysis => const AnalysisPage(),
      StratovaSection.ranking => const RankingPage(),
      StratovaSection.profile => const ProfilePage(),
      StratovaSection.admin => const AdminPage(),
    };
  }

  void _navigate(BuildContext context, StratovaDestination destination) {
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
                      section: section, onTap: (d) => _navigate(context, d))),
          appBar: isDesktop
              ? null
              : AppBar(
                  title: const Text('Stratova'),
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
                  Color(0xFFEFF4FF)
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
                          onTap: (d) => _navigate(context, d))),
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
                              bottom: BorderSide(color: StratovaColors.border)),
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
                                    color: StratovaColors.textTertiary,
                                  ),
                                ),
                                Text(studentUser.team,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
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

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.section, required this.onTap});

  final StratovaSection section;
  final ValueChanged<StratovaDestination> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        border: const Border(right: BorderSide(color: StratovaColors.border)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Stratova',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: StratovaColors.textPrimary)),
                  SizedBox(height: 6),
                  Text('Simulacion Empresarial',
                      style: TextStyle(
                          fontSize: 12, color: StratovaColors.textTertiary)),
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
                            horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: active
                              ? StratovaColors.accentSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          border: active
                              ? Border.all(
                                  color: StratovaColors.accent
                                      .withValues(alpha: 0.18))
                              : null,
                        ),
                        child: Row(
                          children: [
                            Icon(destination.icon,
                                color: active
                                    ? StratovaColors.accent
                                    : StratovaColors.textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                destination.label,
                                style: TextStyle(
                                  color: active
                                      ? StratovaColors.accent
                                      : StratovaColors.textSecondary,
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassPanel(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: StratovaColors.accent,
                      child: Text(studentUser.avatar,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(studentUser.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(studentUser.role,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: StratovaColors.textTertiary)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onTap(destinations.firstWhere(
                          (e) => e.section == StratovaSection.profile)),
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
