import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/teacher/data/models/teacher_dashboard_model.dart';
import 'package:simcore_frontend/features/teacher/presentation/providers/teacher_dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherDashboardPage extends ConsumerWidget {
  const TeacherDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(teacherDashboardProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Panel de Control Docente',
          subtitle: 'Seguimiento de grupos, empresas y progreso de módulos.',
        ),
        const SizedBox(height: 24),
        dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => GlassPanel(
            child: Text('Error al cargar dashboard: $e',
                style: const TextStyle(color: SimcoreColors.danger)),
          ),
          data: (dashboard) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary KPIs
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  _StatTile(label: 'Total grupos', value: '${dashboard.totalGroups}'),
                  _StatTile(
                    label: 'Empresas activas',
                    value: '${dashboard.activeCompanies}',
                    color: SimcoreColors.success,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Groups list
              if (dashboard.groups.isEmpty)
                const GlassPanel(
                  child: Center(
                    child: Text(
                      'Sin grupos registrados en este curso.',
                      style: TextStyle(color: SimcoreColors.textSecondary),
                    ),
                  ),
                )
              else
                ...dashboard.groups.map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _GroupCard(group: group),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GroupCard extends StatefulWidget {
  const _GroupCard({required this.group});

  final GroupDashboardItem group;

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final incoherenceTotal = group.incoherences['total'] as int? ?? 0;
    final incoherenceHigh = group.incoherences['high'] as int? ?? 0;

    final companyStatus = group.companyStatus != null
        ? CompanyStatus.fromApi(group.companyStatus!)
        : null;

    final (statusColor, statusBg) = switch (companyStatus) {
      CompanyStatus.inSimulation => (SimcoreColors.success, SimcoreColors.successSoft),
      CompanyStatus.closed => (SimcoreColors.danger, SimcoreColors.dangerSoft),
      CompanyStatus.draft => (SimcoreColors.textTertiary, SimcoreColors.surface),
      _ => (SimcoreColors.textTertiary, SimcoreColors.surface),
    };

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.groupName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (group.companyName != null)
                        Text(
                          group.companyName!,
                          style: const TextStyle(
                            color: SimcoreColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (group.companyStatus != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      companyStatus?.label ?? '',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: SimcoreColors.textTertiary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                icon: Icons.check_circle_outline_rounded,
                label: '${group.completedModules} módulos completos',
                color: SimcoreColors.success,
              ),
              if (incoherenceTotal > 0)
                _Chip(
                  icon: Icons.warning_amber_rounded,
                  label: '$incoherenceTotal incoherencias ($incoherenceHigh alta)',
                  color: incoherenceHigh > 0
                      ? SimcoreColors.danger
                      : SimcoreColors.warning,
                ),
            ],
          ),
          if (_expanded && group.moduleProgress.isNotEmpty) ...[
            const Divider(height: 20),
            const Text(
              'Detalle de módulos',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: SimcoreColors.textSecondary),
            ),
            const SizedBox(height: 10),
            ...group.moduleProgress.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.circle,
                          size: 8, color: SimcoreColors.textTertiary),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(
                        m['module']?.toString() ?? '',
                        style: const TextStyle(fontSize: 13),
                      )),
                      Text(
                        m['status'] != null
                            ? ModuleStatus.fromApi(m['status'].toString()).label
                            : '',
                        style: const TextStyle(
                            fontSize: 12,
                            color: SimcoreColors.textSecondary),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value, this.color = SimcoreColors.accent});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: SimcoreColors.textTertiary)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
