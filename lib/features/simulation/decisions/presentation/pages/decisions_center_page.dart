import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/decisions/domain/entities/decision.dart';
import 'package:simcore_frontend/features/simulation/decisions/presentation/providers/decision_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DecisionsPage extends ConsumerWidget {
  const DecisionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decisionsAsync = ref.watch(companyDecisionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Centro de Decisiones',
          subtitle: 'Revisión y registro de decisiones estratégicas por módulo.',
        ),
        const SizedBox(height: 28),
        decisionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => GlassPanel(
            child: Text(
              'Error al cargar decisiones: $e',
              style: const TextStyle(color: SimcoreColors.danger),
            ),
          ),
          data: (decisions) {
            if (decisions.isEmpty) {
              return const GlassPanel(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No hay decisiones registradas aún.',
                      style: TextStyle(color: SimcoreColors.textSecondary),
                    ),
                  ),
                ),
              );
            }

            // Group by module
            final grouped = <String, List<Decision>>{};
            for (final d in decisions) {
              grouped.putIfAbsent(d.module, () => []).add(d);
            }

            return Column(
              children: grouped.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.folder_outlined, color: SimcoreColors.accent),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: SimcoreColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...entry.value.map((d) => _DecisionTile(decision: d)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _DecisionTile extends StatelessWidget {
  const _DecisionTile({required this.decision});

  final Decision decision;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBg) = switch (decision.status.toUpperCase()) {
      'SUBMITTED' => (SimcoreColors.success, SimcoreColors.successSoft),
      'SUPERSEDED' => (SimcoreColors.textTertiary, SimcoreColors.surface),
      _ => (SimcoreColors.warning, SimcoreColors.warningSoft),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SimcoreColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SimcoreColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    decision.decisionType,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    decision.status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              decision.justification,
              style: const TextStyle(
                color: SimcoreColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
