import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';

import '../providers/investment_financing_providers.dart';
import '../widgets/investment_items_table.dart';
import '../widgets/financing_options_table.dart';
import '../widgets/add_investment_modal.dart';  
import '../widgets/add_financing_modal.dart'; 


class InvestmentFinancingPage extends ConsumerStatefulWidget {
  final String companyId; 

  const InvestmentFinancingPage({super.key, required this.companyId});

  @override
  ConsumerState<InvestmentFinancingPage> createState() => _InvestmentFinancingPageState();
}

class _InvestmentFinancingPageState extends ConsumerState<InvestmentFinancingPage> {
  
  @override
  Widget build(BuildContext context) {
  
    final state = ref.watch(investmentFinancingProvider(widget.companyId));
    final notifier = ref.read(investmentFinancingProvider(widget.companyId).notifier);

    return LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageIntro(
              title: 'Inversiones y Financiamiento',
              subtitle: 'Estructuración de capital, requerimientos operativos y opciones de fondeo.',
            ),
            const SizedBox(height: 24),
            
            // Mensaje de error del Provider
if (state.errorMessage != null)
  Container(
    margin: const EdgeInsets.only(bottom: 24),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: SimcoreColors.danger.withValues(alpha: 0.1),
      border: Border.all(color: SimcoreColors.danger.withValues(alpha: 0.35)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline, color: SimcoreColors.danger),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            state.errorMessage!,
            style: const TextStyle(
              color: SimcoreColors.danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  ),

// Mensaje de éxito del Provider
if (state.successMessage != null)
  Container(
    margin: const EdgeInsets.only(bottom: 24),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: SimcoreColors.success.withValues(alpha: 0.1),
      border: Border.all(color: SimcoreColors.success.withValues(alpha: 0.35)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline, color: SimcoreColors.success),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            state.successMessage!,
            style: const TextStyle(
              color: SimcoreColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  ),
            
            // 2. BLOQUEO PEDAGÓGICO REAL
            if (!state.isMarketComplete && !state.isLoading)
              _MarketNotReadyWarning()
            else if (state.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              // 3. SECCIÓN DE INVERSIÓN
              const Text(
                '1. Requerimientos de Inversión',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Define el capital necesario basado en tus proyecciones de mercado.',
                style: TextStyle(color: SimcoreColors.textSecondary),
              ),
              const SizedBox(height: 16),
              
              
              InvestmentItemsTable(items: state.investmentItems),
              
              
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AddInvestmentModal(
                        onSave: (type, description, amount) {
                          notifier.addInvestmentItem(type, description, amount);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Agregar Requerimiento'),
                ),
              ),
              
              
              const SizedBox(height: 32),

            
              const Text(
                '2. Estructura de Financiamiento',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Compara y selecciona cómo fondearás la inversión total. Analiza el impacto del costo de capital.',
                style: TextStyle(color: SimcoreColors.textSecondary),
              ),
              const SizedBox(height: 16),
              
              // Aquí inyectamos la tabla de opciones
              FinancingOptionsTable(
                options: state.financingOptions,
                onSelectOption: (optionId) {
                  notifier.selectFinancingOption(optionId);
                },
              ),


              // >>> NUEVO BOTÓN DE FINANCIAMIENTO <<<
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AddFinancingModal(
                        onSave: (type, amount, interestRate, termInMonths) {
                          notifier.addFinancingOption(type, amount, interestRate, termInMonths);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Simular Nueva Opción de Fondeo'),
                ),
              ),
              const SizedBox(height: 32),
              
              
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => notifier.completeModule(),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Completar Estructuración Financiera'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ],
        ),
      );
    });
  }
}


class _MarketNotReadyWarning extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SimcoreColors.warning.withValues(alpha: 0.1),
        border: Border.all(color: SimcoreColors.warning),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: SimcoreColors.warning, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Módulo Bloqueado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: SimcoreColors.warning,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'No puedes estructurar la inversión ni el financiamiento sin antes definir la oportunidad comercial. Completa el Módulo de Mercado para habilitar esta sección.',
                  style: TextStyle(color: SimcoreColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
