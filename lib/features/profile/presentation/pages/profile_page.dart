import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final username = user?.username ?? 'Usuario';
    final roles = user?.roles.join(', ') ?? 'Sin rol';
    final avatarText = username.isNotEmpty ? username[0].toUpperCase() : '?';

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
                subtitle: 'Información personal y rol en la simulación.',
              ),
              const SizedBox(height: 24),
              GlassPanel(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: SimcoreColors.accent,
                      child: Text(avatarText,
                          style: const TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(height: 16),
                    Text(username,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(roles),
                    const Divider(height: 32),
                    _ProfileRow(
                        icon: Icons.person_outline_rounded,
                        value: 'ID: ${user?.id ?? '-'}'),
                    _ProfileRow(
                        icon: Icons.business_rounded,
                        value: 'Tenant: ${user?.tenantId ?? '-'}'),
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
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Información de sesión',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    const SizedBox(height: 16),
                    _ProfileRow(icon: Icons.badge_rounded, value: 'Usuario: $username'),
                    _ProfileRow(icon: Icons.lock_outline_rounded, value: 'Roles: $roles'),
                    _ProfileRow(icon: Icons.numbers_rounded, value: 'ID: ${user?.id ?? '-'}'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Logros y Badges (próximamente)',
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
