import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/modules/investment_financing/domain/entities/financing_option.dart';
import 'package:simcore_frontend/features/modules/investment_financing/presentation/providers/investment_financing_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinancePage extends ConsumerWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageIntro(
            title: 'Inversiones y Financiamiento',
            subtitle: 'Registro de ítems de inversión y fuentes de financiamiento.',
          ),
          const SizedBox(height: 24),
          const TabBar(
            tabs: [
              Tab(text: 'Inversión'),
              Tab(text: 'Financiamiento'),
            ],
          ),
          const SizedBox(height: 16),
          const _InvestmentTab(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _InvestmentTab extends ConsumerWidget {
  const _InvestmentTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(investmentSummaryProvider);
    final notifierState = ref.watch(investmentFinancingNotifierProvider);
    final isLoading = notifierState is AsyncLoading;

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => GlassPanel(
        child: Text('Error: $e', style: const TextStyle(color: SimcoreColors.danger)),
      ),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconTitle(
                  icon: Icons.inventory_2_outlined,
                  title: 'Ítems de inversión',
                ),
                const SizedBox(height: 16),
                if (summary.items.isEmpty)
                  const Text(
                    'Sin ítems registrados. Agrega el primero.',
                    style: TextStyle(color: SimcoreColors.textSecondary),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Nombre')),
                        DataColumn(label: Text('Tipo')),
                        DataColumn(label: Text('Cant.')),
                        DataColumn(label: Text('C. Unit.')),
                        DataColumn(label: Text('Total')),
                        DataColumn(label: Text('')),
                      ],
                      rows: summary.items
                          .map((item) => DataRow(cells: [
                                DataCell(Text(item.name)),
                                DataCell(Text(item.itemType.label)),
                                DataCell(Text('${item.quantity}')),
                                DataCell(Text('\$${item.unitCost.toStringAsFixed(0)}')),
                                DataCell(Text('\$${item.totalCost.toStringAsFixed(0)}')),
                                DataCell(IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded,
                                      color: SimcoreColors.danger, size: 18),
                                  onPressed: () => ref
                                      .read(investmentFinancingNotifierProvider.notifier)
                                      .deleteInvestmentItem(item.id),
                                )),
                              ]))
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showAddItemDialog(context, ref),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Agregar ítem'),
                    ),
                  ],
                ),
                if (summary.items.isNotEmpty) ...[
                  const Divider(height: 24),
                  summaryRow('Activos fijos', summary.totalFixedAssets),
                  summaryRow('Capital de trabajo', summary.totalWorkingCapital),
                  summaryRow('Preoperativo', summary.totalPreOperative),
                  summaryRow('Total', summary.grandTotal, bold: true),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: summary.hasMinimumData && !isLoading
                ? () => ref
                    .read(investmentFinancingNotifierProvider.notifier)
                    .completeInvestment()
                : null,
            style: FilledButton.styleFrom(backgroundColor: SimcoreColors.success),
            child: const Text('Completar módulo Inversión'),
          ),
          const SizedBox(height: 24),
          _FinancingSection(ref: ref, isLoading: isLoading),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddInvestmentItemDialog(
        onSave: (data) =>
            ref.read(investmentFinancingNotifierProvider.notifier).createInvestmentItem(data),
      ),
    );
  }
}

Widget summaryRow(String label, double value, {bool bold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          '\$${value.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? SimcoreColors.accent : SimcoreColors.textPrimary,
          ),
        ),
      ],
    ),
  );
}

class _FinancingSection extends ConsumerWidget {
  const _FinancingSection({required this.ref, required this.isLoading});

  final WidgetRef ref;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final summaryAsync = widgetRef.watch(financingSummaryProvider);

    return summaryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => GlassPanel(
        child: Text('Error: $e', style: const TextStyle(color: SimcoreColors.danger)),
      ),
      data: (summary) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const IconTitle(
                  icon: Icons.account_balance_outlined,
                  title: 'Fuentes de financiamiento',
                ),
                const SizedBox(height: 16),
                if (summary.options.isEmpty)
                  const Text(
                    'Sin opciones registradas.',
                    style: TextStyle(color: SimcoreColors.textSecondary),
                  )
                else
                  ...summary.options.map((opt) => _FinancingOptionTile(
                        option: opt,
                        onSelect: () => widgetRef
                            .read(investmentFinancingNotifierProvider.notifier)
                            .selectFinancingOption(opt.id),
                        onDelete: () => widgetRef
                            .read(investmentFinancingNotifierProvider.notifier)
                            .deleteFinancingOption(opt.id),
                      )),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showAddOptionDialog(context, widgetRef),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Agregar opción'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: summary.hasMinimumData && summary.hasSelectedOption && !isLoading
                ? () => widgetRef
                    .read(investmentFinancingNotifierProvider.notifier)
                    .completeFinancing()
                : null,
            style: FilledButton.styleFrom(backgroundColor: SimcoreColors.success),
            child: const Text('Completar módulo Financiamiento'),
          ),
        ],
      ),
    );
  }

  void _showAddOptionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddFinancingOptionDialog(
        onSave: (data) =>
            ref.read(investmentFinancingNotifierProvider.notifier).createFinancingOption(data),
      ),
    );
  }
}

class _FinancingOptionTile extends StatelessWidget {
  const _FinancingOptionTile({
    required this.option,
    required this.onSelect,
    required this.onDelete,
  });

  final FinancingOption option;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: option.isSelected
              ? SimcoreColors.successSoft
              : SimcoreColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: option.isSelected
                ? SimcoreColors.success.withValues(alpha: 0.4)
                : SimcoreColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(option.sourceName,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    '${option.sourceType.label} · \$${option.principalAmount.toStringAsFixed(0)} · ${option.annualInterestRate}% · ${option.termMonths} meses',
                    style: const TextStyle(
                        fontSize: 12, color: SimcoreColors.textSecondary),
                  ),
                ],
              ),
            ),
            if (!option.isSelected)
              TextButton(onPressed: onSelect, child: const Text('Seleccionar')),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: SimcoreColors.danger, size: 18),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddInvestmentItemDialog extends StatefulWidget {
  const _AddInvestmentItemDialog({required this.onSave});

  final Future<void> Function(Map<String, dynamic>) onSave;

  @override
  State<_AddInvestmentItemDialog> createState() => _AddInvestmentItemDialogState();
}

class _AddInvestmentItemDialogState extends State<_AddInvestmentItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _unitCostCtrl = TextEditingController();
  InvestmentItemType _type = InvestmentItemType.fixedAsset;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _unitCostCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar ítem de inversión'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<InvestmentItemType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: InvestmentItemType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _type = v);
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _qtyCtrl,
              decoration: const InputDecoration(labelText: 'Cantidad'),
              keyboardType: TextInputType.number,
              validator: (v) => (v == null || int.tryParse(v.trim()) == null) ? 'Número válido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _unitCostCtrl,
              decoration: const InputDecoration(labelText: 'Costo unitario'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || double.tryParse(v.trim()) == null) ? 'Número válido' : null,
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
          onPressed: _saving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _saving = true);
                  await widget.onSave({
                    'name': _nameCtrl.text.trim(),
                    'itemType': _type.toApi(),
                    'quantity': int.parse(_qtyCtrl.text.trim()),
                    'unitCost': double.parse(_unitCostCtrl.text.trim()),
                  });
                  if (context.mounted) Navigator.pop(context);
                },
          child: _saving
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}

class _AddFinancingOptionDialog extends StatefulWidget {
  const _AddFinancingOptionDialog({required this.onSave});

  final Future<void> Function(Map<String, dynamic>) onSave;

  @override
  State<_AddFinancingOptionDialog> createState() => _AddFinancingOptionDialogState();
}

class _AddFinancingOptionDialogState extends State<_AddFinancingOptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _termCtrl = TextEditingController();
  FinancingSourceType _sourceType = FinancingSourceType.bankLoan;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _rateCtrl.dispose();
    _termCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar opción de financiamiento'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nombre de la fuente'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<FinancingSourceType>(
              initialValue: _sourceType,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: FinancingSourceType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _sourceType = v);
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(labelText: 'Monto principal (\$)'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || double.tryParse(v.trim()) == null) ? 'Número válido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _rateCtrl,
              decoration: const InputDecoration(labelText: 'Tasa anual (%)'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || double.tryParse(v.trim()) == null) ? 'Número válido' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _termCtrl,
              decoration: const InputDecoration(labelText: 'Plazo (meses)'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  (v == null || int.tryParse(v.trim()) == null) ? 'Número válido' : null,
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
          onPressed: _saving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _saving = true);
                  await widget.onSave({
                    'sourceName': _nameCtrl.text.trim(),
                    'sourceType': _sourceType.toApi(),
                    'principalAmount': double.parse(_amountCtrl.text.trim()),
                    'annualInterestRate': double.parse(_rateCtrl.text.trim()),
                    'termMonths': int.parse(_termCtrl.text.trim()),
                  });
                  if (context.mounted) Navigator.pop(context);
                },
          child: _saving
              ? const SizedBox(
                  width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
