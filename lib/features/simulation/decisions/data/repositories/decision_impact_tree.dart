import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/simulation/decisions/data/repositories/decision_providers.dart';

class DecisionImpactTree extends ConsumerWidget {
  const DecisionImpactTree({super.key, required this.decisionId});

  final String decisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impactAsync = ref.watch(decisionImpactProvider(decisionId));

    return impactAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          'Error al cargar impacto: $err',
          style: const TextStyle(color: SimcoreColors.danger),
        ),
      ),
      data: (impacts) {
        if (impacts.isEmpty) {
          return const Center(
            child: Text('Esta decisión no generó impactos registrados.'),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: impacts.length,
          itemBuilder: (context, index) {
            final impact = impacts[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.arrow_forward, color: SimcoreColors.accent),
                title: Text('Módulo Afectado: ${impact.affectedModule}'),
                subtitle: Text(impact.description),
              ),
            );
          },
        );
      },
    );
  }
}