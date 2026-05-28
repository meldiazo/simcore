import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/modules/market/data/repositories/market_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';

class SalesProjectionPanel extends ConsumerWidget {
  const SalesProjectionPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectionAsync = ref.watch(salesProjectionProvider);

    return projectionAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error al cargar proyección: $err')),
      data: (projection) {
        if (projection == null) {
          return const Center(child: Text('Aún no se ha generado una proyección.'));
        }
        return ResponsiveMetricRow(
          children: [
            _StatCard(label: 'Demanda Mensual', value: '${projection.monthlyDemand} Unidades'),
            _StatCard(label: 'Precio Estimado', value: '\$${projection.estimatedPrice.toStringAsFixed(2)}'),
            _StatCard(label: 'Ingresos Proyectados', value: '\$${projection.projectedRevenue.toStringAsFixed(2)}'),
            _StatCard(label: 'Escenario', value: projection.scenario),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: SimcoreColors.textTertiary)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
      ],
    );
  }
}