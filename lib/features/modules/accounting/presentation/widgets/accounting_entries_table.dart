import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                          DataCell(Text(entry.description)),
                          DataCell(Text('\$${entry.debit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green))),
                          DataCell(Text('\$${entry.credit.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}