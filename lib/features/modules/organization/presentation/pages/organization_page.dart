import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/modules/organization/domain/entities/organization_area.dart';
import 'package:simcore_frontend/features/modules/organization/presentation/providers/organization_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationPage extends ConsumerWidget {
  const OrganizationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(organizationSummaryProvider);
    final notifierState = ref.watch(organizationNotifierProvider);
    final isLoading = notifierState is AsyncLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Estructuras Organizativas',
          subtitle: 'Áreas, cargos y análisis de capacidad operativa.',
        ),
        const SizedBox(height: 24),
        summaryAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => GlassPanel(
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Icon(
        Icons.error_outline_rounded,
        color: SimcoreColors.danger,
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          'No se pudo cargar Organización.\n$e',
          style: const TextStyle(color: SimcoreColors.danger),
        ),
      ),
    ],
  ),
),
          data: (summary) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Capacity vs Demand panel
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IconTitle(
                      icon: Icons.speed_outlined,
                      title: 'Capacidad vs Demanda',
                    ),
                    const SizedBox(height: 16),
                    _MetricRow(
                      label: 'Capacidad mensual estimada',
                      value: summary.estimatedMonthlyCapacity,
                    ),
                    _MetricRow(
                      label: 'Demanda mensual proyectada',
                      value: summary.projectedMonthlyDemand,
                    ),
                    _MetricRow(
                      label: 'Costo de personal mensual',
                      value: summary.monthlyPersonnelCost,
                      prefix: '\$',
                    ),
                    if (summary.warnings.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: SimcoreColors.warningSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded,
                                    color: SimcoreColors.warning, size: 16),
                                SizedBox(width: 6),
                                Text('Advertencias',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: SimcoreColors.warning)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...summary.warnings.map((w) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(w,
                                      style: const TextStyle(
                                          color: SimcoreColors.warning)),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Areas
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: IconTitle(
                            icon: Icons.account_tree_outlined,
                            title: 'Áreas organizativas',
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _showAddAreaDialog(context, ref),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Nueva área'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (summary.areas.isEmpty)
                      const Text(
                        'No hay áreas creadas.',
                        style: TextStyle(color: SimcoreColors.textSecondary),
                      )
                    else
                      ...summary.areas.map((area) => _AreaTile(
                            area: area,
                            positions: summary.positions
                                .where((p) => p.areaId == area.id)
                                .toList(),
                            onAddPosition: () =>
                                _showAddPositionDialog(context, ref, area.id),
                            onDeletePosition: (posId) => ref
                                .read(organizationNotifierProvider.notifier)
                                .deletePosition(posId),
                          )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: summary.areas.isNotEmpty && !isLoading
                    ? () => ref
                        .read(organizationNotifierProvider.notifier)
                        .completeModule()
                    : null,
                style: FilledButton.styleFrom(backgroundColor: SimcoreColors.success),
                child: const Text('Completar módulo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddAreaDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva área'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              await ref.read(organizationNotifierProvider.notifier).createArea({
                'name': nameCtrl.text.trim(),
                'description': descCtrl.text.trim(),
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showAddPositionDialog(BuildContext context, WidgetRef ref, int areaId) {
  final titleCtrl = TextEditingController();
  final responsibilitiesCtrl = TextEditingController();
  final headcountCtrl = TextEditingController(text: '1');
  final salaryCtrl = TextEditingController();
  final capacityCtrl = TextEditingController(text: '0');

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Nuevo cargo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Título del cargo',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: responsibilitiesCtrl,
              decoration: const InputDecoration(
                labelText: 'Responsabilidades',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: headcountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cantidad de personas',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: salaryCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Salario mensual',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: capacityCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Capacidad por persona al mes',
                helperText: 'Puede ser 0 si todavía no aplica.',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            final title = titleCtrl.text.trim();
            final headcount = int.tryParse(headcountCtrl.text.trim()) ?? 1;
            final monthlySalary =
                double.tryParse(salaryCtrl.text.trim()) ?? 0;
            final capacityPerPerson =
                double.tryParse(capacityCtrl.text.trim()) ?? 0;

            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El título del cargo es obligatorio.'),
                  backgroundColor: SimcoreColors.danger,
                ),
              );
              return;
            }

            if (headcount <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('La cantidad de personas debe ser mayor a 0.'),
                  backgroundColor: SimcoreColors.danger,
                ),
              );
              return;
            }

            if (monthlySalary <= 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('El salario mensual debe ser mayor a 0.'),
                  backgroundColor: SimcoreColors.danger,
                ),
              );
              return;
            }

            await ref.read(organizationNotifierProvider.notifier).createPosition({
              'areaId': areaId,
              'title': title,
              'responsibilities': responsibilitiesCtrl.text.trim(),
              'headcount': headcount,
              'monthlySalary': monthlySalary,
              'capacityPerPerson': capacityPerPerson,
            });

            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Crear'),
        ),
      ],
    ),
  );
}
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value, this.prefix = ''});

  final String label;
  final double value;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            '$prefix${value.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _AreaTile extends StatelessWidget {
  const _AreaTile({
    required this.area,
    required this.positions,
    required this.onAddPosition,
    required this.onDeletePosition,
  });

  final OrganizationArea area;
  final List<OrganizationPosition> positions;
  final VoidCallback onAddPosition;
  final void Function(int posId) onDeletePosition;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SimcoreColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SimcoreColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(area.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
                TextButton.icon(
                  onPressed: onAddPosition,
                  icon: const Icon(Icons.person_add_rounded, size: 14),
                  label: const Text('Cargo'),
                ),
              ],
            ),
            if (area.description != null)
              Text(area.description!,
                  style: const TextStyle(color: SimcoreColors.textSecondary, fontSize: 12)),
            if (positions.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...positions.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 14, color: SimcoreColors.textTertiary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${p.title} · ${p.headcount} pax · \$${p.monthlySalary.toStringAsFixed(0)}/mes',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              size: 14, color: SimcoreColors.danger),
                          onPressed: () => onDeletePosition(p.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}
