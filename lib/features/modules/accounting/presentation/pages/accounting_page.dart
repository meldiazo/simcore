import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/accounting_entries_table.dart';
import '../widgets/financial_statement_viewer.dart';
import '../providers/accounting_providers.dart';

class AccountingPage extends ConsumerWidget {
  const AccountingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const companyId = 'COMP-12345'; 

    return DefaultTabController(
      length: 2, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Módulo de Contabilidad'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.table_rows), text: 'Libro Diario (Asientos)'),
              Tab(icon: Icon(Icons.analytics), text: 'Estados Financieros'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EntriesTab(companyId: companyId),
            _StatementsTab(companyId: companyId),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            label: const Text(
              'Finalizar Revisión Contable',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              try {
                await ref.read(accountingActionsProvider).completeModule(companyId);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Revisión contable registrada con éxito. Avanzando...'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

class _EntriesTab extends ConsumerWidget {
  final String companyId;
  const _EntriesTab({required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.autorenew),
            label: const Text('Generar Asientos Automáticos'),
            onPressed: () async {
              await ref.read(accountingActionsProvider).generateEntries(companyId);
            },
          ),
          const SizedBox(height: 16),
          Expanded(child: AccountingEntriesTable(companyId: companyId)),
        ],
      ),
    );
  }
}

class _StatementsTab extends ConsumerWidget {
  final String companyId;
  const _StatementsTab({required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add_chart),
            label: const Text('Generar Estados Financieros'),
            onPressed: () async {
              await ref.read(accountingActionsProvider).generateStatements(companyId);
            },
          ),
          const SizedBox(height: 16),
          Expanded(child: FinancialStatementViewer(companyId: companyId)),
        ],
      ),
    );
  }
}