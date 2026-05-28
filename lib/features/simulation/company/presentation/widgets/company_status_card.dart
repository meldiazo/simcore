import 'package:flutter/material.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/company.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';

class CompanyStatusCard extends StatelessWidget {
  const CompanyStatusCard({
    super.key,
    required this.company,
    this.onActivate,
  });

  final Company company;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  company.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusBadge(status: company.status),
            ],
          ),
          if (company.status == CompanyStatus.draft) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onActivate,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Activar'),
                style: FilledButton.styleFrom(
                  backgroundColor: SimcoreColors.success,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CompanyStatus status;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      CompanyStatus.draft => (SimcoreColors.textTertiary, SimcoreColors.surface),
      CompanyStatus.inSimulation => (SimcoreColors.success, SimcoreColors.successSoft),
      CompanyStatus.closed => (SimcoreColors.danger, SimcoreColors.dangerSoft),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
