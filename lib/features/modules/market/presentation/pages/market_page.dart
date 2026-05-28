import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/modules/market/domain/entities/market_assumption.dart';
import 'package:simcore_frontend/features/modules/market/domain/entities/sales_projection.dart';
import 'package:simcore_frontend/features/modules/market/presentation/providers/market_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  final _formKey = GlobalKey<FormState>();
  final _segmentCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();
  final _demandCtrl = TextEditingController();
  final _competitionCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _justificationCtrl = TextEditingController();
  bool _populated = false;

  @override
  void dispose() {
    _segmentCtrl.dispose();
    _sizeCtrl.dispose();
    _demandCtrl.dispose();
    _competitionCtrl.dispose();
    _priceCtrl.dispose();
    _justificationCtrl.dispose();
    super.dispose();
  }

  void _populateForm(MarketAssumption assumption) {
    if (_populated) return;
    _populated = true;
    _segmentCtrl.text = assumption.targetSegment ?? '';
    _sizeCtrl.text = assumption.marketSizeEstimate?.toString() ?? '';
    _demandCtrl.text = assumption.demandUnitsPerMonth?.toString() ?? '';
    _competitionCtrl.text = assumption.competitionDescription ?? '';
    _priceCtrl.text = assumption.estimatedUnitPrice?.toString() ?? '';
    _justificationCtrl.text = assumption.commercialJustification ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final assumptionAsync = ref.watch(marketAssumptionProvider);
    final projectionAsync = ref.watch(salesProjectionProvider);
    final marketState = ref.watch(marketNotifierProvider);
    final isLoading = marketState is AsyncLoading;

    assumptionAsync.whenData((a) {
      if (a != null) _populateForm(a);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PageIntro(
          title: 'Módulo Mercado',
          subtitle: 'Supuestos comerciales y proyección de ventas.',
        ),
        const SizedBox(height: 24),
        GlassPanel(
          child: assumptionAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: SimcoreColors.danger)),
            data: (assumption) => Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconTitle(
                    icon: Icons.storefront_outlined,
                    title: 'Supuestos de mercado',
                  ),
                  const SizedBox(height: 16),
                  _buildField('Segmento objetivo', _segmentCtrl),
                  const SizedBox(height: 12),
                  _buildField('Tamaño de mercado estimado (\$)', _sizeCtrl,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildField('Demanda estimada (unidades/mes)', _demandCtrl,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildField('Descripción de la competencia', _competitionCtrl, maxLines: 2),
                  const SizedBox(height: 12),
                  _buildField('Precio unitario estimado (\$)', _priceCtrl,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildField('Justificación comercial', _justificationCtrl,
                      maxLines: 3, required: true, minLength: 30),
                  const SizedBox(height: 20),
                  if (assumption?.hasMinimumData == true)
                    Row(
                      children: const [
                        Icon(Icons.check_circle_rounded, color: SimcoreColors.success, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Datos mínimos completos',
                          style: TextStyle(color: SimcoreColors.success, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: isLoading ? null : _saveAssumption,
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Guardar supuestos'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        GlassPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const IconTitle(
                icon: Icons.show_chart_rounded,
                title: 'Proyección de ventas',
              ),
              const SizedBox(height: 16),
              projectionAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Text('Error: $e', style: const TextStyle(color: SimcoreColors.danger)),
                data: (projection) => _ProjectionSection(projection: projection),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: isLoading
                    ? null
                    : () => ref.read(marketNotifierProvider.notifier).generateProjection(),
                icon: const Icon(Icons.autorenew_rounded),
                label: const Text('Generar proyección'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        assumptionAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (assumption) => projectionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (projection) {
              final canComplete =
                  (assumption?.hasMinimumData ?? false) && projection != null;
              return FilledButton(
                onPressed: canComplete && !isLoading
                    ? () => ref.read(marketNotifierProvider.notifier).completeModule()
                    : null,
                style: FilledButton.styleFrom(backgroundColor: SimcoreColors.success),
                child: const Text('Completar módulo'),
              );
            },
          ),
        ),
      ],
    );
  }

  void _saveAssumption() {
    if (!_formKey.currentState!.validate()) return;
    ref.read(marketNotifierProvider.notifier).saveAssumption({
      'targetSegment': _segmentCtrl.text.trim(),
      'marketSizeEstimate': double.tryParse(_sizeCtrl.text.trim()),
      'demandUnitsPerMonth': int.tryParse(_demandCtrl.text.trim()),
      'competitionDescription': _competitionCtrl.text.trim(),
      'estimatedUnitPrice': double.tryParse(_priceCtrl.text.trim()),
      'commercialJustification': _justificationCtrl.text.trim(),
    });
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
    int? minLength,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) return 'Campo requerido';
        if (minLength != null && (value?.trim().length ?? 0) < minLength) {
          return 'Mínimo $minLength caracteres';
        }
        return null;
      },
    );
  }
}

class _ProjectionSection extends StatelessWidget {
  const _ProjectionSection({this.projection});

  final SalesProjection? projection;

  @override
  Widget build(BuildContext context) {
    if (projection == null) {
      return const Text(
        'Sin proyección generada. Guarda los supuestos y luego genera la proyección.',
        style: TextStyle(color: SimcoreColors.textSecondary),
      );
    }

    if (projection!.periods.isEmpty) {
      return const Text(
        'La proyección no tiene períodos.',
        style: TextStyle(color: SimcoreColors.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (projection!.notes != null) ...[
          Text(projection!.notes!, style: const TextStyle(color: SimcoreColors.textSecondary)),
          const SizedBox(height: 12),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Período')),
              DataColumn(label: Text('Unidades')),
              DataColumn(label: Text('Ingresos')),
            ],
            rows: projection!.periods
                .map((p) => DataRow(cells: [
                      DataCell(Text(p.period)),
                      DataCell(Text('${p.units}')),
                      DataCell(Text('\$${p.revenue.toStringAsFixed(0)}')),
                    ]))
                .toList(),
          ),
        ),
      ],
    );
  }
}
