import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/modules/accounting/presentation/providers/accounting_providers.dart';
import 'package:simcore_frontend/features/modules/accounting/presentation/widgets/accounting_entries_table.dart';
import 'package:simcore_frontend/features/modules/accounting/presentation/widgets/financial_statement_viewer.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

class AccountingPage extends ConsumerWidget {
  const AccountingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyId = ref.watch(currentCompanyIdProvider).toString();

    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageIntro(
            title: 'Módulo de Contabilidad',
            subtitle:
                'Genera asientos automáticos y estados financieros a partir de las decisiones previas.',
          ),
          const SizedBox(height: 20),
          GlassPanel(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                const TabBar(
  labelColor: SimcoreColors.accent,
  unselectedLabelColor: SimcoreColors.textSecondary,
  indicatorColor: SimcoreColors.accent,
  tabs: [
                    Tab(
                      icon: Icon(Icons.table_rows_rounded),
                      text: 'Libro Diario',
                    ),
                    Tab(
                      icon: Icon(Icons.analytics_rounded),
                      text: 'Estados Financieros',
                    ),
                  ],
                ),
                SizedBox(
                  height: 560,
                  child: TabBarView(
                    children: [
                      _EntriesTab(companyId: companyId),
                      _StatementsTab(companyId: companyId),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: SimcoreColors.success,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 16,
                ),
              ),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('Finalizar Revisión Contable'),
              onPressed: () async {
                try {
                  await ref.read(accountingActionsProvider).completeModule(companyId);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Módulo de Contabilidad completado.'),
                        backgroundColor: SimcoreColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al completar contabilidad: $e'),
                        backgroundColor: SimcoreColors.danger,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EntriesTab extends ConsumerWidget {
  const _EntriesTab({required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.autorenew_rounded),
            label: const Text('Generar Asientos Automáticos'),
            onPressed: () async {
              try {
                await ref.read(accountingActionsProvider).generateEntries(companyId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Asientos generados correctamente.'),
                      backgroundColor: SimcoreColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al generar asientos: $e'),
                      backgroundColor: SimcoreColors.danger,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AccountingEntriesTable(companyId: companyId),
          ),
        ],
      ),
    );
  }
}

class _StatementsTab extends ConsumerWidget {
  const _StatementsTab({required this.companyId});

  final String companyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.icon(
            icon: const Icon(Icons.add_chart_rounded),
            label: const Text('Generar Estados Financieros'),
            onPressed: () async {
              try {
                await ref.read(accountingActionsProvider).generateStatements(companyId);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Estados financieros generados correctamente.'),
                      backgroundColor: SimcoreColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al generar estados financieros: $e'),
                      backgroundColor: SimcoreColors.danger,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FinancialStatementViewer(companyId: companyId),
          ),
        ],
      ),
    );
  }
}