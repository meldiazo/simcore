import 'package:flutter/material.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:simcore_frontend/features/simulation/company/domain/entities/module_progress.dart';

/// Displays the 6 simulation modules as a horizontal (mobile) or
/// vertical (desktop) step indicator with coloured status icons.
class ModuleFlowStepper extends StatelessWidget {
  const ModuleFlowStepper({super.key, required this.modules});

  final List<CompanyModuleProgress> modules;

  static const _order = [
    SimModule.market,
    SimModule.investment,
    SimModule.organization,
    SimModule.accounting,
    SimModule.analysis,
  ];

  @override
  Widget build(BuildContext context) {
    final ordered = _order.map((m) {
      try {
        return modules.firstWhere((p) => p.module == m);
      } catch (_) {
        return CompanyModuleProgress(
          module: m,
          status: ModuleStatus.pending,
          progress: 0,
        );
      }
    }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 700;
        if (isDesktop) {
          return _VerticalStepper(modules: ordered);
        }
        return _HorizontalStepper(modules: ordered);
      },
    );
  }
}

// ── Horizontal (mobile) ───────────────────────────────────────────────────────

class _HorizontalStepper extends StatelessWidget {
  const _HorizontalStepper({required this.modules});

  final List<CompanyModuleProgress> modules;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < modules.length; i++) ...[
            _StepDot(module: modules[i], compact: true),
            if (i < modules.length - 1)
              _ConnectorLine(
                done: modules[i].status == ModuleStatus.complete,
                horizontal: true,
              ),
          ],
        ],
      ),
    );
  }
}

// ── Vertical (desktop) ────────────────────────────────────────────────────────

class _VerticalStepper extends StatelessWidget {
  const _VerticalStepper({required this.modules});

  final List<CompanyModuleProgress> modules;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < modules.length; i++) ...[
          _StepDot(module: modules[i], compact: false),
          if (i < modules.length - 1)
            _ConnectorLine(
              done: modules[i].status == ModuleStatus.complete,
              horizontal: false,
            ),
        ],
      ],
    );
  }
}

// ── Step dot ──────────────────────────────────────────────────────────────────

class _StepDot extends StatelessWidget {
  const _StepDot({required this.module, required this.compact});

  final CompanyModuleProgress module;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(module.status);
    final icon = _statusIcon(module.status);

    if (compact) {
      return Tooltip(
        message: '${module.name} — ${module.status.label} (${module.progress}%)',
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      );
    }

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(module.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13)),
            Text('${module.status.label} · ${module.progress}%',
                style:
                    TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ],
    );
  }
}

// ── Connector line ────────────────────────────────────────────────────────────

class _ConnectorLine extends StatelessWidget {
  const _ConnectorLine({required this.done, required this.horizontal});

  final bool done;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final color = done ? SimcoreColors.success : SimcoreColors.border;
    if (horizontal) {
      return Container(width: 24, height: 2, color: color);
    }
    return Container(
      width: 2,
      height: 20,
      margin: const EdgeInsets.only(left: 17),
      color: color,
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Color _statusColor(ModuleStatus status) {
  return switch (status) {
    ModuleStatus.complete => SimcoreColors.success,
    ModuleStatus.inProgress => SimcoreColors.accent,
    ModuleStatus.requiresRevision => SimcoreColors.warning,
    ModuleStatus.outdated => const Color(0xFFEAB308),
    ModuleStatus.locked => SimcoreColors.danger,
    ModuleStatus.pending => SimcoreColors.textTertiary,
  };
}

IconData _statusIcon(ModuleStatus status) {
  return switch (status) {
    ModuleStatus.complete => Icons.check_circle_rounded,
    ModuleStatus.inProgress => Icons.timelapse_rounded,
    ModuleStatus.requiresRevision => Icons.edit_note_rounded,
    ModuleStatus.outdated => Icons.history_rounded,
    ModuleStatus.locked => Icons.lock_outline_rounded,
    ModuleStatus.pending => Icons.radio_button_unchecked_rounded,
  };
}
