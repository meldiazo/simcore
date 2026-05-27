import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/shared/data/demo/simcore_demo_data.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageIntro(
                title: 'Perfil del Usuario',
                subtitle: 'Informacion personal y estadisticas de desempeno.',
              ),
              const SizedBox(height: 24),
              GlassPanel(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: SimcoreColors.accent,
                      child: Text(studentUser.avatar,
                          style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 16),
                    Text(studentUser.name,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(studentUser.role),
                    const Divider(height: 32),
                    _ProfileRow(
                        icon: Icons.mail_outline_rounded,
                        value: studentUser.email),
                    _ProfileRow(
                        icon: Icons.apartment_outlined,
                        value: studentUser.institution),
                    _ProfileRow(
                        icon: Icons.groups_rounded, value: studentUser.team),
                    _ProfileRow(
                        icon: Icons.calendar_month_outlined,
                        value: studentUser.cohort),
                  ],
                ),
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            children: [
              const GlassPanel(
                child: ResponsiveMetricRow(
                  children: [
                    _ProfileStat(
                        label: 'Posicion Actual',
                        value: '#2',
                        detail: 'de 5 equipos'),
                    _ProfileStat(
                        label: 'Ciclos Completados',
                        value: '2',
                        detail: 'de 8'),
                    _ProfileStat(
                        label: 'Decisiones Enviadas',
                        value: '12',
                        detail: '100% a tiempo'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Roles en Simulaciones',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    SizedBox(height: 16),
                    _RoleTile(
                      title: 'MBA 2026 - Simulacion Empresarial',
                      subtitle: 'Responsable de Inversión y Financiamiento · Equipo Alpha',
                      badge: 'En progreso',
                      highlighted: true,
                    ),
                    SizedBox(height: 12),
                    _RoleTile(
                      title: 'MBA 2025 - Simulacion Empresarial',
                      subtitle: 'Gerente de Marketing · Equipo Delta',
                      badge: 'Completado',
                      highlighted: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Logros y Badges',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: const [
                        _BadgeCard(
                            icon: '🏆',
                            name: 'Top 3',
                            desc: 'Alcanzar top 3 en una simulacion'),
                        _BadgeCard(
                            icon: '📈',
                            name: 'Crecimiento',
                            desc: 'Aumentar market share +5%'),
                        _BadgeCard(
                            icon: '💎',
                            name: 'Eficiencia',
                            desc: 'Lograr 85%+ eficiencia'),
                        _BadgeCard(
                            icon: '⚡',
                            name: 'Puntual',
                            desc: '100% decisiones a tiempo'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: SimcoreColors.textTertiary, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: SimcoreColors.textTertiary)),
        const SizedBox(height: 8),
        Text(value,
            style: GoogleFonts.jetBrainsMono(
                fontSize: 30, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(detail),
      ],
    );
  }
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.highlighted,
  });

  final String title;
  final String subtitle;
  final String badge;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? SimcoreColors.accentSoft : SimcoreColors.muted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                softWrap: true,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(subtitle, softWrap: true),
          ],
        );
        final badgeWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:
                highlighted ? SimcoreColors.successSoft : SimcoreColors.surface,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(badge,
              style: TextStyle(
                  color: highlighted
                      ? SimcoreColors.success
                      : SimcoreColors.textSecondary)),
        );

        if (constraints.maxWidth < 460) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              content,
              const SizedBox(height: 10),
              badgeWidget,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: content),
            const SizedBox(width: 12),
            Flexible(child: badgeWidget),
          ],
        );
      }),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.icon,
    required this.name,
    required this.desc,
  });

  final String icon;
  final String name;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: SimcoreColors.accentSoft.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: SimcoreColors.accent.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 10),
            Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(desc,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
