import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/comparison/presentation/providers/comparison_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/loading_state.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/api_error_state.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/scenario_context_provider.dart';

class CompanyComparisonPage extends ConsumerWidget {
  const CompanyComparisonPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonAsync = ref.watch(courseComparisonProvider);
    final selectedScenario = ref.watch(selectedScenarioTypeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Comparación Académica',
          subtitle: 'Métricas financieras comparadas entre empresas del curso.',
        ),
        const SizedBox(height: 20),
        _ScenarioSelector(selected: selectedScenario),
        const SizedBox(height: 20),
        comparisonAsync.when(
          loading: () => const LoadingState(message: 'Cargando comparación...'),
          error: (e, _) => ApiErrorState(
            title: 'No se pudo cargar la comparación',
            message: e.toString(),
            onRetry: () => ref.invalidate(courseComparisonProvider),
          ),
          data: (data) {
            final companies = (data['companies'] as List? ?? [])
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
            if (companies.isEmpty) {
              return const _EmptyComparison();
            }
            return _ComparisonTable(companies: companies);
          },
        ),
      ],
    );
  }
}

class _ScenarioSelector extends ConsumerWidget {
  const _ScenarioSelector({required this.selected});

  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ScenarioType.values.map((type) => type.toApi()).toList();
    final labels = {
      for (final type in ScenarioType.values) type.toApi(): type.label,
    };
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final active = opt == selected;
        return ChoiceChip(
          label: Text(labels[opt] ?? opt),
          selected: active,
          selectedColor: SimcoreColors.accent,
          labelStyle: TextStyle(
            color: active ? Colors.white : SimcoreColors.textSecondary,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          ),
          onSelected: (_) {
            ref.read(scenarioTypeOverrideProvider.notifier).state = opt;
          },
        );
      }).toList(),
    );
  }
}

class _EmptyComparison extends StatelessWidget {
  const _EmptyComparison();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No hay empresas para comparar en este curso.',
            style: TextStyle(color: SimcoreColors.textSecondary, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.companies});

  final List<Map<String, dynamic>> companies;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            children: companies.map((c) => _CompanyCard(data: c)).toList(),
          );
        }
        return GlassPanel(
          padding: EdgeInsets.zero,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20,
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: SimcoreColors.textPrimary,
              ),
              columns: const [
                DataColumn(label: Text('Empresa')),
                DataColumn(label: Text('Grupo')),
                DataColumn(label: Text('VAN'), numeric: true),
                DataColumn(label: Text('TIR'), numeric: true),
                DataColumn(label: Text('PRI (m)'), numeric: true),
                DataColumn(label: Text('M. Neto'), numeric: true),
                DataColumn(label: Text('Incoher. Altas'), numeric: true),
                DataColumn(label: Text('Módulos'), numeric: true),
              ],
              rows: companies.map((c) {
                final van = c['van'] as num?;
                final tir = c['tir'] as num?;
                final pri = c['priMonths'] as num?;
                final margin = c['netMarginPct'] as num?;
                final incoherences = c['incoherencesHigh'] as num? ?? 0;
                final completed = c['completedModules'] as num? ?? 0;

                return DataRow(cells: [
                  DataCell(Text(
                    (c['companyName'] ?? '-').toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
                  DataCell(Text((c['groupName'] ?? '-').toString())),
                  DataCell(Text(van != null ? van.toStringAsFixed(0) : '-')),
                  DataCell(Text(tir != null
                      ? '${(tir * 100).toStringAsFixed(1)}%'
                      : '-')),
                  DataCell(Text(pri != null ? pri.toString() : '-')),
                  DataCell(Text(margin != null
                      ? '${(margin * 100).toStringAsFixed(1)}%'
                      : '-')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: incoherences > 0
                            ? SimcoreColors.dangerSoft
                            : SimcoreColors.successSoft,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        incoherences.toString(),
                        style: TextStyle(
                          color: incoherences > 0
                              ? SimcoreColors.danger
                              : SimcoreColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  DataCell(Text(completed.toString())),
                ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final van = data['van'] as num?;
    final tir = data['tir'] as num?;
    final pri = data['priMonths'] as num?;
    final margin = data['netMarginPct'] as num?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (data['companyName'] ?? '-').toString(),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            Text(
              (data['groupName'] ?? '-').toString(),
              style: const TextStyle(color: SimcoreColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                MobileInfoRow(
                  label: 'VAN',
                  value: van != null ? van.toStringAsFixed(0) : '-',
                ),
                MobileInfoRow(
                  label: 'TIR',
                  value: tir != null
                      ? '${(tir * 100).toStringAsFixed(1)}%'
                      : '-',
                ),
                MobileInfoRow(
                  label: 'PRI (meses)',
                  value: pri != null ? pri.toString() : '-',
                ),
                MobileInfoRow(
                  label: 'M. Neto',
                  value: margin != null
                      ? '${(margin * 100).toStringAsFixed(1)}%'
                      : '-',
                ),
                MobileInfoRow(
                  label: 'Incoher. Altas',
                  value: (data['incoherencesHigh'] ?? 0).toString(),
                ),
                MobileInfoRow(
                  label: 'Módulos',
                  value: (data['completedModules'] ?? 0).toString(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
