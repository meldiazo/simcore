import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/financial_statement_model.dart';
import '../providers/accounting_providers.dart';

class FinancialStatementViewer extends ConsumerWidget {
  final String companyId;

  const FinancialStatementViewer({super.key, required this.companyId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statementsAsyncValue =
        ref.watch(financialStatementsProvider(companyId));

    return statementsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error al cargar estados financieros: $error',
            style: const TextStyle(color: Colors.red)),
      ),
      data: (statements) {
        if (statements.isEmpty) {
          return const Center(
            child: Text(
                'Aún no hay estados financieros. Presiona "Generar Estados Financieros".'),
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
                    _buildStatementTab(
                        statements, StatementType.incomeStatement),
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

  Widget _buildStatementTab(
      List<FinancialStatementModel> statements, StatementType type) {
    final statement = statements.where((s) => s.type == type).firstOrNull;

    if (statement == null) {
      return const Center(child: Text('Reporte no disponible.'));
    }

    if (statement.entries.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.all(8.0),
        itemCount: statement.entries.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final entry = statement.entries[index];
          final label = entry['lineLabel']?.toString() ??
              entry['lineCode']?.toString() ??
              'Linea financiera';
          final period = entry['periodLabel']?.toString();
          final rawValue = entry['value'];
          final value = rawValue is num
              ? rawValue.toDouble()
              : double.tryParse(rawValue?.toString() ?? '');

          return ListTile(
            title: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: period == null || period.isEmpty ? null : Text(period),
            trailing: Text(
              value == null
                  ? (rawValue?.toString() ?? '')
                  : _formatMoney(value),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: value == null
                    ? null
                    : value < 0
                        ? Colors.red
                        : Colors.green,
              ),
            ),
          );
        },
      );
    }

    final dataMap = statement.data;

    if (dataMap.isEmpty) {
      return const Center(child: Text('Reporte sin lineas disponibles.'));
    }

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
            value is num ? _formatMoney(value.toDouble()) : value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        );
      },
    );
  }

  String _formatMoney(double value) {
    final prefix = value < 0 ? '-\$' : '\$';
    return '$prefix${value.abs().toStringAsFixed(2)}';
  }
}
