import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/financial_statement_model.dart';
import '../providers/accounting_providers.dart';

class FinancialStatementViewer extends ConsumerWidget {
  final String companyId;

  const FinancialStatementViewer({super.key, required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statementsAsyncValue = ref.watch(financialStatementsProvider(companyId));

    return statementsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error al cargar estados financieros: $error', style: const TextStyle(color: Colors.red)),
      ),
      data: (statements) {
        if (statements.isEmpty) {
          return const Center(
            child: Text('Aún no hay estados financieros. Presiona "Generar Estados Financieros".'),
          );
        }

        return DefaultTabController(
          length: 4, // Son 4 reportes
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TabBar(
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blueAccent,
                isScrollable: true, // Por si la pantalla es pequeña
                tabs: [
                  Tab(text: 'Estado de Resultados'),
                  Tab(text: 'Balance General'),
                  Tab(text: 'Flujo de Caja'),
                  Tab(text: 'Ratios'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildStatementTab(statements, StatementType.incomeStatement),
                    _buildStatementTab(statements, StatementType.balanceSheet),
                    _buildStatementTab(statements, StatementType.cashFlow),
                    _buildStatementTab(statements, StatementType.ratios),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatementTab(List<FinancialStatementModel> statements, StatementType type) {
    final statement = statements.where((s) => s.type == type).firstOrNull;

    if (statement == null) {
      return const Center(child: Text('Reporte no disponible.'));
    }

    final dataMap = statement.data;

    return ListView.separated(
      padding: const EdgeInsets.all(8.0),
      itemCount: dataMap.keys.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final key = dataMap.keys.elementAt(index);
        final value = dataMap[key];
        
        return ListTile(
          title: Text(key, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Text(
            value is num ? '\$${value.toStringAsFixed(2)}' : value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      },
    );
  }
}