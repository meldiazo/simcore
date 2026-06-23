import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import '../../data/models/accounting_entry_model.dart';
import '../providers/accounting_providers.dart';

class AccountingEntriesTable extends ConsumerWidget {
  final String companyId;

  const AccountingEntriesTable({super.key, required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsyncValue = ref.watch(accountingEntriesProvider(companyId));

    return entriesAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error al cargar asientos: $error', style: const TextStyle(color: Colors.red)),
      ),
      data: (entries) {
        if (entries.isEmpty) {
          return const Center(
            child: Text('No hay asientos contables generados aún. Presiona "Generar Asientos".'),
          );
        }

        final isOutdated = entries.any((e) => e.status == AccountingStatus.outdated);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isOutdated)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¡Atención! Has tomado nuevas decisiones en otros módulos. Tus asientos actuales están DESACTUALIZADOS (OUTDATED). Vuelve a generarlos.',
                        style: TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(Colors.blueGrey.shade50),
                          columns: const [
                            DataColumn(label: Text('Fecha')),
                            DataColumn(label: Text('Código')),
                            DataColumn(label: Text('Cuenta')),
                            DataColumn(label: Text('Descripción')),
                            DataColumn(label: Text('Debe', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Haber', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: entries.map((entry) {
                            return DataRow(
                              color: entry.status == AccountingStatus.outdated 
                                  ? WidgetStateProperty.all(Colors.grey.shade200) 
                                  : null,
                              cells: [
                                DataCell(Text('${entry.date.day}/${entry.date.month}/${entry.date.year}')),
                                DataCell(Text(entry.accountCode)),
                                DataCell(Text(entry.accountName)),
                                DataCell(
                                  SizedBox(
                                    width: 260,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Tooltip(
                                            message: entry.description,
                                            child: Text(
                                              entry.description,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                        if (entry.description.length > 30) ...[
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => Dialog(
                                                  backgroundColor: Colors.transparent,
                                                  child: ConstrainedBox(
                                                    constraints: const BoxConstraints(maxWidth: 450),
                                                    child: GlassPanel(
                                                      padding: const EdgeInsets.all(24),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              const Icon(Icons.receipt_long_rounded, color: SimcoreColors.accent),
                                                              const SizedBox(width: 8),
                                                              const Text(
                                                                'Descripción de Asiento',
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: SimcoreColors.textPrimary,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(height: 16),
                                                          Text(
                                                            entry.description,
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              height: 1.5,
                                                              color: SimcoreColors.textSecondary,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 24),
                                                          Align(
                                                            alignment: Alignment.centerRight,
                                                            child: TextButton(
                                                              onPressed: () => Navigator.of(context).pop(),
                                                              child: const Text(
                                                                'Cerrar',
                                                                style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  color: SimcoreColors.accent,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Ver más',
                                              style: TextStyle(
                                                color: SimcoreColors.accent,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                                DataCell(Text('\$${entry.debit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green))),
                                DataCell(Text('\$${entry.credit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red))),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}