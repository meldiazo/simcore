import 'package:core_sim_ia/app/theme.dart';
import 'package:core_sim_ia/features/stratova/data/stratova_mock_data.dart';
import 'package:core_sim_ia/features/stratova/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';

class OperationsPage extends StatelessWidget {
  const OperationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Modulo Operaciones y Logistica',
          subtitle:
              'Gestion de capacidad instalada, inventarios y cadena de suministro.',
        ),
        const SizedBox(height: 24),
        const ResponsiveWrap(
          children: [
            KpiCard(
                metric: KpiMetric(
                    title: 'Capacidad de Produccion',
                    value: 85000,
                    unit: 'uds',
                    delta: 2.5,
                    trendUp: true,
                    state: 'success')),
            KpiCard(
                metric: KpiMetric(
                    title: 'Ocupacion de Planta',
                    value: 92.4,
                    unit: '%',
                    delta: 4.1,
                    trendUp: true,
                    state: 'warning')),
            KpiCard(
                metric: KpiMetric(
                    title: 'Inventario Terminado',
                    value: 12400,
                    unit: 'uds',
                    delta: 15.2,
                    trendUp: false,
                    state: 'danger')),
            KpiCard(
                metric: KpiMetric(
                    title: 'Costo Unitario Prod.',
                    value: 45.2,
                    unit: '\$',
                    delta: 1.5,
                    trendUp: false,
                    state: 'success')),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveHeaderAction(
                      title: 'Control de Linea de Ensamblaje',
                      subtitle:
                          'Asignacion de turnos y mantenimiento preventivo.',
                      action: FilledButton(
                        onPressed: () {},
                        child: const Text('Anadir Turno Extra'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _LineCard(
                      name: 'Linea Automatizada A',
                      efficiency: 98,
                      color: StratovaColors.success,
                      detail:
                          'Produccion: 45,000 uds/m · Mantenimiento en 14 dias',
                    ),
                    const SizedBox(height: 16),
                    const _LineCard(
                      name: 'Linea Manual B',
                      efficiency: 76,
                      color: StratovaColors.warning,
                      detail:
                          'Produccion: 22,000 uds/m · Requiere ajustes ergonomicos',
                    ),
                  ],
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  GlassPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Materia Prima',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 16)),
                        SizedBox(height: 16),
                        MetricBar(
                            label: 'Silicio y Semiconductores',
                            value: 15,
                            max: 100,
                            trailing: '14 Ton',
                            color: StratovaColors.danger),
                        SizedBox(height: 14),
                        MetricBar(
                            label: 'Materiales de Ensamblaje',
                            value: 65,
                            max: 100,
                            trailing: '42 Ton',
                            color: StratovaColors.success),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  GlassPanel(
                    backgroundColor:
                        StratovaColors.warningSoft.withValues(alpha: 0.45),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: StratovaColors.warning),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Cuello de botella detectado: la Linea A excede la capacidad de empacado. Se recomienda invertir \$45,000 en el modulo de empaquetado automatico.',
                            style: TextStyle(
                                color: StratovaColors.textSecondary,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LineCard extends StatelessWidget {
  const _LineCard({
    required this.name,
    required this.efficiency,
    required this.color,
    required this.detail,
  });

  final String name;
  final double efficiency;
  final Color color;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StratovaColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: StratovaColors.border),
      ),
      child: Column(
        children: [
          LayoutBuilder(builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 430;
            final header = [
              Expanded(
                  child: Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w700))),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999)),
                child: Text('${efficiency.toStringAsFixed(0)}% eficiencia',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ];

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      softWrap: true,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  header.last,
                ],
              );
            }

            return Row(children: header);
          }),
          const SizedBox(height: 14),
          LinearProgressIndicator(
              value: efficiency / 100,
              minHeight: 10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: StratovaColors.muted),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerLeft, child: Text(detail)),
        ],
      ),
    );
  }
}
