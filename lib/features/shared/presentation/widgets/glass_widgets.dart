import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/core/domain/simcore_enums.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KpiMetric extends Equatable {
  const KpiMetric({
    required this.title,
    required this.value,
    required this.unit,
    required this.delta,
    required this.trendUp,
    required this.state,
  });

  final String title;
  final double value;
  final String unit;
  final double delta;
  final bool trendUp;
  final String state;

  @override
  List<Object?> get props => [title, value, unit, delta, trendUp, state];
}

enum AlertKind { info, success, warning, danger }

class AlertItem extends Equatable {
  const AlertItem({
    required this.type,
    required this.title,
    required this.message,
    required this.module,
  });

  final AlertKind type;
  final String title;
  final String message;
  final String module;

  @override
  List<Object?> get props => [type, title, message, module];
}

class CurrentCycle extends Equatable {
  const CurrentCycle({
    required this.number,
    required this.name,
    required this.isOpen,
    required this.timeRemaining,
    required this.totalCycles,
  });

  final int number;
  final String name;
  final bool isOpen;
  final String timeRemaining;
  final int totalCycles;

  @override
  List<Object?> get props => [number, name, isOpen, timeRemaining, totalCycles];
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderColor,
    this.backgroundColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: backgroundColor ?? SimcoreColors.glass,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor ?? SimcoreColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x140F172A),
                  blurRadius: 30,
                  offset: Offset(0, 18),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

EdgeInsets responsivePanelPadding(double width) {
  if (width < 360) {
    return const EdgeInsets.all(16);
  }
  if (width < 520) {
    return const EdgeInsets.all(18);
  }
  return const EdgeInsets.all(22);
}

class ResponsiveSectionWrap extends StatelessWidget {
  const ResponsiveSectionWrap({
    super.key,
    required this.children,
    this.spacing = 20,
    this.runSpacing = 20,
  });

  final List<Widget> children;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 1100;

      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: children
            .map((child) => SizedBox(
                  width: isMobile ? constraints.maxWidth : null,
                  child: child,
                ))
            .toList(growable: false),
      );
    });
  }
}

class MobileInfoRow extends StatelessWidget {
  const MobileInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: SimcoreColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class PageIntro extends StatelessWidget {
  const PageIntro({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 560;
      final titleText = Text(
        title,
        softWrap: true,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: isCompact ? 26 : null,
              height: 1.15,
            ),
      );
      final introText = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText,
          const SizedBox(height: 6),
          Text(
            subtitle,
            softWrap: true,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      );

      if (isCompact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            introText,
            if (trailing != null) ...[
              const SizedBox(height: 14),
              trailing!,
            ],
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: introText),
          if (trailing != null) ...[
            const SizedBox(width: 20),
            Flexible(child: trailing!),
          ],
        ],
      );
    });
  }
}

class ResponsiveHeaderAction extends StatelessWidget {
  const ResponsiveHeaderAction({
    super.key,
    required this.title,
    required this.subtitle,
    required this.action,
  });

  final String title;
  final String subtitle;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 620;
      final text = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            softWrap: true,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            softWrap: true,
            style: const TextStyle(height: 1.4),
          ),
        ],
      );

      if (isCompact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            text,
            const SizedBox(height: 14),
            action,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: text),
          const SizedBox(width: 16),
          Flexible(child: action),
        ],
      );
    });
  }
}

class AdaptiveActionRow extends StatelessWidget {
  const AdaptiveActionRow({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 430) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children
              .expand((child) => [child, SizedBox(height: spacing)])
              .take(children.length * 2 - 1)
              .toList(growable: false),
        );
      }

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: children
            .expand(
                (child) => [Flexible(child: child), SizedBox(width: spacing)])
            .take(children.length * 2 - 1)
            .toList(growable: false),
      );
    });
  }
}

class IconTitle extends StatelessWidget {
  const IconTitle({
    super.key,
    required this.icon,
    required this.title,
    this.color = SimcoreColors.accent,
  });

  final IconData icon;
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            softWrap: true,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class ResponsiveMetricRow extends StatelessWidget {
  const ResponsiveMetricRow({
    super.key,
    required this.children,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 520) {
        return Column(
          children: children
              .expand((child) => [
                    SizedBox(width: double.infinity, child: child),
                    SizedBox(height: spacing),
                  ])
              .take(children.length * 2 - 1)
              .toList(growable: false),
        );
      }

      return Row(
        children: children
            .map((child) => Expanded(child: child))
            .expand((child) => [child, SizedBox(width: spacing)])
            .take(children.length * 2 - 1)
            .toList(growable: false),
      );
    });
  }
}

class ResponsiveWrap extends StatelessWidget {
  const ResponsiveWrap({
    super.key,
    required this.children,
    this.itemWidth = 260,
    this.spacing = 20,
    this.runSpacing = 20,
  });

  final List<Widget> children;
  final double itemWidth;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = constraints.maxWidth.isFinite
          ? constraints.maxWidth
          : MediaQuery.of(context).size.width;
      final count =
          (availableWidth / itemWidth).floor().clamp(1, children.length);
      final width = (availableWidth - (spacing * (count - 1))) / count;

      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: children
            .map((child) => SizedBox(width: width, child: child))
            .toList(growable: false),
      );
    });
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 18),
    );
  }
}

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.metric,
  });

  final KpiMetric metric;

  Color get _accent {
    switch (metric.state) {
      case 'success':
        return SimcoreColors.success;
      case 'warning':
        return SimcoreColors.warning;
      case 'danger':
        return SimcoreColors.danger;
      default:
        return SimcoreColors.accent;
    }
  }

  String get _formattedValue {
    if (metric.unit == '\$') {
      return '\$${(metric.value / 1000000).toStringAsFixed(2)}M';
    }
    return metric.value.toStringAsFixed(metric.unit == 'x' ? 1 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(metric.title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formattedValue,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: SimcoreColors.textPrimary,
                ),
              ),
              if (metric.unit != '\$') ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(metric.unit,
                      style:
                          const TextStyle(color: SimcoreColors.textTertiary)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(
                metric.trendUp
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
                size: 14,
                color: _accent,
              ),
              Text(
                '${metric.delta.toStringAsFixed(1)}${metric.unit == '%' ? 'pp' : '%'} vs anterior',
                style: TextStyle(
                    color: _accent, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CycleChip extends StatelessWidget {
  const CycleChip({super.key, this.cycleNumber = 1, this.timeRemaining = ''});

  final int cycleNumber;
  final String timeRemaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: SimcoreColors.glass,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SimcoreColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Ciclo $cycleNumber',
              style: const TextStyle(color: SimcoreColors.textSecondary)),
          const SizedBox(width: 10),
          Container(width: 1, height: 16, color: SimcoreColors.border),
          const SizedBox(width: 10),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
                color: SimcoreColors.success, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          const Text('Abierto',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: SimcoreColors.textPrimary)),
          if (timeRemaining.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(
              timeRemaining,
              style: GoogleFonts.jetBrainsMono(
                  fontSize: 12, color: SimcoreColors.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final ModuleStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
  ModuleStatus.pending => (
      'Pendiente',
      SimcoreColors.muted,
      SimcoreColors.textSecondary,
    ),
  ModuleStatus.inProgress => (
      'En progreso',
      SimcoreColors.accentSoft,
      SimcoreColors.accent,
    ),
  ModuleStatus.complete => (
      'Completo',
      SimcoreColors.successSoft,
      SimcoreColors.success,
    ),
  ModuleStatus.locked => (
      'Bloqueado',
      SimcoreColors.dangerSoft,
      SimcoreColors.danger,
    ),
  ModuleStatus.requiresRevision => (
      'Requiere revisión',
      SimcoreColors.warningSoft,
      SimcoreColors.warning,
    ),
  ModuleStatus.outdated => (
      'Desactualizado',
      SimcoreColors.warningSoft,
      SimcoreColors.warning,
    ),
};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  color: fg, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class AlertRibbon extends StatelessWidget {
  const AlertRibbon({super.key, required this.alert});

  final AlertItem alert;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, icon) = switch (alert.type) {
      AlertKind.info => (
          SimcoreColors.accentSoft,
          SimcoreColors.accent,
          Icons.info_outline_rounded
        ),
      AlertKind.success => (
          SimcoreColors.successSoft,
          SimcoreColors.success,
          Icons.check_circle_outline_rounded
        ),
      AlertKind.warning => (
          SimcoreColors.warningSoft,
          SimcoreColors.warning,
          Icons.warning_amber_rounded
        ),
      AlertKind.danger => (
          SimcoreColors.dangerSoft,
          SimcoreColors.danger,
          Icons.error_outline_rounded
        ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border(left: BorderSide(color: fg, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style:
                            TextStyle(color: fg, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(alert.module,
                          style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(alert.message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MetricBar extends StatelessWidget {
  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    this.color = SimcoreColors.accent,
    this.trailing,
  });

  final String label;
  final double value;
  final double max;
  final Color color;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final widthFactor = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: SimcoreColors.textPrimary,
                        fontWeight: FontWeight.w500))),
            Text(trailing ?? value.toStringAsFixed(1),
                style: const TextStyle(fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: widthFactor,
            minHeight: 8,
            backgroundColor: SimcoreColors.muted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class HoverAnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final Color color;

  const HoverAnimatedButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color = SimcoreColors.success,
  });

  @override
  State<HoverAnimatedButton> createState() => _HoverAnimatedButtonState();
}

class _HoverAnimatedButtonState extends State<HoverAnimatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: _isHovered && isEnabled
            ? (Matrix4.identity()..translate(0, -2)..scale(1.03))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isHovered && isEnabled
              ? [
                  BoxShadow(
                    color: widget.color.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: FilledButton.icon(
          onPressed: widget.onPressed,
          icon: widget.icon,
          label: widget.label,
          style: FilledButton.styleFrom(
            backgroundColor: widget.color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: SimcoreColors.textTertiary.withOpacity(0.2),
            disabledForegroundColor: SimcoreColors.textTertiary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

class ModuleFinalizeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onFinalize;
  final String buttonLabel;
  final bool isCompleted;

  const ModuleFinalizeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onFinalize,
    this.buttonLabel = 'Completar Módulo',
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderColor: isCompleted 
          ? SimcoreColors.success.withOpacity(0.4) 
          : SimcoreColors.accent.withOpacity(0.2),
      backgroundColor: isCompleted
          ? SimcoreColors.successSoft.withOpacity(0.15)
          : null,
      child: LayoutBuilder(builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 620;

        final content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCompleted 
                    ? SimcoreColors.successSoft 
                    : SimcoreColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted 
                    ? Icons.check_circle_rounded 
                    : Icons.lock_open_rounded,
                color: isCompleted 
                    ? SimcoreColors.success 
                    : SimcoreColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w800,
                      color: isCompleted 
                          ? SimcoreColors.success 
                          : SimcoreColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      height: 1.4,
                      fontSize: 14,
                      color: SimcoreColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

        final actionButton = HoverAnimatedButton(
          onPressed: isCompleted ? null : onFinalize,
          color: isCompleted ? SimcoreColors.success : SimcoreColors.accent,
          icon: Icon(
            isCompleted 
                ? Icons.check_circle_outline_rounded 
                : Icons.check_circle_rounded,
            size: 20,
          ),
          label: Text(
            isCompleted ? 'Módulo Completado' : buttonLabel,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        );

        if (isCompact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              const SizedBox(height: 20),
              actionButton,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            const SizedBox(width: 24),
            actionButton,
          ],
        );
      }),
    );
  }
}

Future<void> showSimcoreSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  String buttonLabel = 'Entendido',
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: GlassPanel(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SimcoreColors.successSoft,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SimcoreColors.success.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: SimcoreColors.success,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: SimcoreColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: SimcoreColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: HoverAnimatedButton(
                    color: SimcoreColors.accent,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}