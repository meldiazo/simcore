import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/modules/accounting/domain/entities/accounting_entry.dart';
import 'package:simcore_frontend/features/modules/accounting/presentation/providers/accounting_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountingPage extends ConsumerWidget {
  const AccountingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(accountingEntriesProvider);
    final statementsAsync = ref.watch(financialStatementsProvider);
    final notifierState = ref.watch(accountingNotifierProvider);
    final isLoading = notifierState is AsyncLoading;

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageIntro(
            title: 'Módulo Contabilidad',
            subtitle: 'Asientos contables y estados financieros automáticos.',
          ),
          const SizedBox(height: 24),
          // Asientos section
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: IconTitle(
                        icon: Icons.receipt_long_rounded,
                        title: 'Asientos contables',
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () =>
                              ref.read(accountingNotifierProvider.notifier).generateEntries(),
                      icon: const Icon(Icons.autorenew_rounded, size: 16),
                      label: const Text('Generar asientos'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                entriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e',
                      style: const TextStyle(color: SimcoreColors.danger)),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return const Text(
                        'Sin asientos generados. Presiona "Generar asientos".',
                        style: TextStyle(color: SimcoreColors.textSecondary),
                      );
                    }
                    return Column(
                      children: entries.map((e) => _EntryTile(entry: e)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Financial statements section
          GlassPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: IconTitle(
                        icon: Icons.bar_chart_rounded,
                        title: 'Estados financieros',
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: isLoading
                          ? null
                          : () => ref
                              .read(accountingNotifierProvider.notifier)
                              .generateStatements(),
                      icon: const Icon(Icons.autorenew_rounded, size: 16),
                      label: const Text('Generar estados'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                statementsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e',
                      style: const TextStyle(color: SimcoreColors.danger)),
                  data: (statements) {
                    if (statements.isEmpty) {
                      return const Text(
                        'Sin estados financieros. Genera los asientos primero.',
                        style: TextStyle(color: SimcoreColors.textSecondary),
                      );
                    }
                    return Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Estado de Resultados'),
                            Tab(text: 'Balance General'),
                            Tab(text: 'Flujo de Caja'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _StatementsTabView(statements: statements),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: !isLoading
                ? () =>
                    ref.read(accountingNotifierProvider.notifier).completeModule()
                : null,
            style: FilledButton.styleFrom(backgroundColor: SimcoreColors.success),
            child: const Text('Completar módulo'),
          ),
        ],
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.entry});

  final AccountingEntry entry;

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusBg) = entry.status.toUpperCase() == 'GENERATED'
        ? (SimcoreColors.success, SimcoreColors.successSoft)
        : (SimcoreColors.warning, SimcoreColors.warningSoft);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SimcoreColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: SimcoreColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.description,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '${entry.sourceModule} · ${entry.entryType} · ${entry.periodLabel}',
                    style: const TextStyle(
                        fontSize: 12, color: SimcoreColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(entry.status,
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementsTabView extends StatelessWidget {
  const _StatementsTabView({required this.statements});

  final List<FinancialStatement> statements;

  @override
  Widget build(BuildContext context) {
    final income = statements
        .where((s) =>
            s.statementType == FinancialStatementType.incomeStatement.apiValue)
        .toList();
    final balance = statements
        .where((s) =>
            s.statementType == FinancialStatementType.balanceSheet.apiValue)
        .toList();
    final cashflow = statements
        .where((s) =>
            s.statementType == FinancialStatementType.cashFlow.apiValue)
        .toList();

    return SizedBox(
      height: 400,
      child: TabBarView(
        children: [
          _StatementList(statements: income),
          _StatementList(statements: balance),
          _StatementList(statements: cashflow),
        ],
      ),
    );
  }
}

class _StatementList extends StatelessWidget {
  const _StatementList({required this.statements});

  final List<FinancialStatement> statements;

  @override
  Widget build(BuildContext context) {
    if (statements.isEmpty) {
      return const Center(
        child: Text('Sin datos para este estado.',
            style: TextStyle(color: SimcoreColors.textSecondary)),
      );
    }

    return ListView(
      children: statements
          .expand((s) => s.lines.map((line) => _LineTile(line: line, periodLabel: s.periodLabel)))
          .toList(),
    );
  }
}

class _LineTile extends StatelessWidget {
  const _LineTile({required this.line, required this.periodLabel});

  final FinancialStatementLine line;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              line.label,
              style: TextStyle(
                fontWeight: line.isTotal ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
          Text(
            '\$${line.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: line.isTotal ? FontWeight.w700 : FontWeight.w400,
              color: line.isTotal ? SimcoreColors.accent : SimcoreColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
