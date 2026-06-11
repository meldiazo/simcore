import 'package:flutter/material.dart';
import '../../data/models/financing_option_model.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart'; 

class FinancingOptionsTable extends StatelessWidget {
  final List<FinancingOptionModel> options;
  final Function(String optionId) onSelectOption;

  const FinancingOptionsTable({
    super.key,
    required this.options,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            'Generando opciones de financiamiento basadas en tu requerimiento de capital...',
            style: TextStyle(color: SimcoreColors.textSecondary),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final bool isSelected = option.isSelected;

        return Card(
          elevation: isSelected ? 2 : 0,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: isSelected ? SimcoreColors.accent : SimcoreColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Radio<String>(
              value: option.id,
              groupValue: options.firstWhere((o) => o.isSelected, orElse: () => options.first).id, // Manejo seguro del estado actual
              activeColor: SimcoreColors.accent,
              onChanged: (value) {
                if (value != null) onSelectOption(value);
              },
            ),
            title: Text(
              option.type.displayName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.attach_money,
                    label: 'Monto: \$${option.amount.toStringAsFixed(2)}',
                  ),
                  _InfoChip(
                    icon: Icons.percent,
                    label: 'Costo (TEA): ${option.interestRate.toStringAsFixed(1)}%',
                    isWarning: option.interestRate > 15.0, // Alerta pedagógica visual
                  ),
                  _InfoChip(
                    icon: Icons.calendar_month,
                    label: 'Plazo: ${option.termInMonths} meses',
                  ),
                ],
              ),
            ),
            onTap: () => onSelectOption(option.id),
          ),
        );
      },
    );
  }
}

// Widget auxiliar para mostrar las métricas de forma limpia
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isWarning;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isWarning ? SimcoreColors.warning.withOpacity(0.1) : SimcoreColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isWarning ? SimcoreColors.warning : SimcoreColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isWarning ? SimcoreColors.warning : SimcoreColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isWarning ? SimcoreColors.warning : SimcoreColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}