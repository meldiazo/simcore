import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import '../../domain/entities/company.dart';

// CORRECCIÓN DEFINITIVA DE URI: Importación absoluta de paquete para evitar el infierno de los puntos relativos
import 'package:simcore_frontend/features/simulation/company/presentation/providers/company_providers.dart';

class CompanyStatusCard extends ConsumerWidget {
  final Company company;

  const CompanyStatusCard({super.key, required this.company});

  Future<void> _activateCompany(BuildContext context, WidgetRef ref) async {
    try {
      // 1. Llamada al repositorio para activar flujo académico (HU-FE-09)
      await ref.read(companyRepositoryProvider).activateCompany(company.id);
      
      // MANDAMIENTO 18: La integración se valida refrescando el workspace inmediatamente [cite: 145, 630]
      ref.invalidate(companyWorkspaceProvider);

      // CORRECCIÓN DE BUILD_CONTEXT: Verificamos que el widget siga montado tras el 'await'
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Empresa activada exitosamente!')),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al activar: $e'), 
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDraft = company.status == CompanyStatus.draft;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDraft ? SimcoreColors.warningSoft : SimcoreColors.successSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          // Protección contra deprecación en Flutter 3.22+
          color: isDraft 
            ? SimcoreColors.warning.withValues(alpha: 0.4) 
            : SimcoreColors.success.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isDraft ? Icons.edit_document : Icons.play_circle_fill_rounded,
            color: isDraft ? SimcoreColors.warning : SimcoreColors.success,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isDraft ? 'Empresa en Borrador (DRAFT)' : 'Simulación Activa (IN_SIMULATION)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDraft ? SimcoreColors.warning : SimcoreColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isDraft 
                    ? 'Complete la configuración de la empresa para habilitar el entorno de simulación.' 
                    : 'El sistema está recibiendo decisiones para esta empresa.',
                ),
              ],
            ),
          ),
          if (isDraft)
            FilledButton.icon(
              onPressed: () => _activateCompany(context, ref),
              icon: const Icon(Icons.rocket_launch_rounded),
              label: const Text('Activar Empresa'),
            ),
        ],
      ),
    );
  }
}