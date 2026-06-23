import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/modules/market/data/models/market_assumption_model.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';

class MarketAssumptionForm extends ConsumerStatefulWidget {
  const MarketAssumptionForm({
    super.key,
    this.initialAssumption,
    required this.onSave,
    required this.isLoading,
  });

  final MarketAssumptionModel? initialAssumption;
  final Future<void> Function(MarketAssumptionModel) onSave;
  final bool isLoading;

  @override
  ConsumerState<MarketAssumptionForm> createState() => _MarketAssumptionFormState();
}

class _MarketAssumptionFormState extends ConsumerState<MarketAssumptionForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _targetSegmentController;
  late final TextEditingController _marketSizeController;
  late final TextEditingController _demandUnitsController;
  late final TextEditingController _competitionController;
  late final TextEditingController _unitPriceController;
  late final TextEditingController _justificationController;

  @override
  void initState() {
    super.initState();
    _targetSegmentController = TextEditingController();
    _marketSizeController = TextEditingController();
    _demandUnitsController = TextEditingController();
    _competitionController = TextEditingController();
    _unitPriceController = TextEditingController();
    _justificationController = TextEditingController();
    _updateFormControllers(widget.initialAssumption);
  }

  @override
  void didUpdateWidget(covariant MarketAssumptionForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialAssumption != oldWidget.initialAssumption) {
      _updateFormControllers(widget.initialAssumption);
    }
  }

  @override
  void dispose() {
    _targetSegmentController.dispose();
    _marketSizeController.dispose();
    _demandUnitsController.dispose();
    _competitionController.dispose();
    _unitPriceController.dispose();
    _justificationController.dispose();
    super.dispose();
  }

  void _updateFormControllers(MarketAssumptionModel? assumption) {
    if (assumption != null) {
      _targetSegmentController.text = assumption.targetSegment;
      _marketSizeController.text = assumption.marketSizeEstimate.toString();
      _demandUnitsController.text = assumption.demandUnitsPerMonth.toString();
      _competitionController.text = assumption.competitionDescription;
      _unitPriceController.text = assumption.estimatedUnitPrice.toString();
      _justificationController.text = assumption.commercialJustification;
    }
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final assumption = MarketAssumptionModel(
      targetSegment: _targetSegmentController.text,
      marketSizeEstimate: double.tryParse(_marketSizeController.text) ?? 0.0,
      demandUnitsPerMonth: int.tryParse(_demandUnitsController.text) ?? 0,
      competitionDescription: _competitionController.text,
      estimatedUnitPrice: double.tryParse(_unitPriceController.text) ?? 0.0,
      commercialJustification: _justificationController.text,
    );
    widget.onSave(assumption);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('1. Supuestos de Mercado'),
          const SizedBox(height: 20),
          TextFormField(
            controller: _targetSegmentController,
            decoration: const InputDecoration(
              labelText: 'Segmento Objetivo',
              prefixIcon: Icon(Icons.track_changes_rounded),
            ),
            validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _competitionController,
            decoration: const InputDecoration(
              labelText: 'Descripción de la Competencia',
              prefixIcon: Icon(Icons.store_rounded),
            ),
            maxLines: 2,
            validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 16),
          ResponsiveMetricRow(
            children: [
              TextFormField(
                controller: _marketSizeController,
                decoration: const InputDecoration(
                  labelText: 'Tamaño de Mercado (USD)',
                  prefixIcon: Icon(Icons.monetization_on_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _demandUnitsController,
                decoration: const InputDecoration(
                  labelText: 'Demanda (Unidades/Mes)',
                  prefixIcon: Icon(Icons.analytics_rounded),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: _unitPriceController,
                decoration: const InputDecoration(
                  labelText: 'Precio Unitario (USD)',
                  prefixIcon: Icon(Icons.sell_rounded),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _justificationController,
            decoration: const InputDecoration(
              labelText: 'Justificación Comercial',
              prefixIcon: Icon(Icons.description_rounded),
            ),
            maxLines: 3,
            validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: widget.isLoading ? null : _handleSave,
              icon: widget.isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
              label: const Text('Guardar Supuestos'),
            ),
          ),
        ],
      ),
    );
  }
}