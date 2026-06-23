import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/core/error/error_utils.dart';


class UserManagerPage extends ConsumerStatefulWidget {
  const UserManagerPage({super.key});

  @override
  ConsumerState<UserManagerPage> createState() => _UserManagerPageState();
}

class _UserManagerPageState extends ConsumerState<UserManagerPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersProvider);
    final rolesAsync = ref.watch(rolesProvider);
    final actionState = ref.watch(userAdminNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntro(
          title: 'Usuarios y Roles',
          subtitle: 'Administra accesos, roles y estado de cuentas.',
          trailing: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar usuario',
                  prefixIcon: Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: SimcoreColors.surface,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (actionState.hasError)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              toUserFriendlyError(actionState.error),
              style: const TextStyle(color: SimcoreColors.danger),
            ),
          ),
        rolesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => GlassPanel(
            child: Text(
              'Error al cargar roles: $e',
              style: const TextStyle(color: SimcoreColors.danger),
            ),
          ),
          data: (roles) => usersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => GlassPanel(
              child: Text(
                'Error al cargar usuarios: $e',
                style: const TextStyle(color: SimcoreColors.danger),
              ),
            ),
            data: (users) {
              final filtered = _filterUsers(users);
              if (filtered.isEmpty) {
                return const GlassPanel(
                  child: Text(
                    'No hay usuarios para mostrar.',
                    style: TextStyle(color: SimcoreColors.textSecondary),
                  ),
                );
              }
              return Column(
                children: filtered
                    .map(
                      (user) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _UserAdminCard(user: user, roles: roles),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _filterUsers(List<Map<String, dynamic>> users) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return users;
    return users.where((user) {
      final fields = [
        user['username'],
        user['email'],
        user['firstName'],
        user['lastName'],
        (user['roles'] as List?)?.join(' '),
      ].whereType<Object>().join(' ').toLowerCase();
      return fields.contains(normalized);
    }).toList(growable: false);
  }
}

class _UserAdminCard extends ConsumerWidget {
  const _UserAdminCard({
    required this.user,
    required this.roles,
  });

  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> roles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = _readInt(user['id']);
    final enabled = user['enabled'] != false;
    final roleIds = _readRoleIds(user);
    final actionState = ref.watch(userAdminNotifierProvider);
    final isBusy = actionState.isLoading;
    final displayName = _displayName(user);

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    enabled ? SimcoreColors.accent : SimcoreColors.textTertiary,
                child: Text(
                  displayName.isEmpty ? '?' : displayName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user['email']?.toString() ?? 'Sin email',
                      style: const TextStyle(
                        color: SimcoreColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: enabled,
                onChanged: userId == null || isBusy
                    ? null
                    : (value) => _setEnabled(context, ref, userId, value),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: roles.map((role) {
              final id = _readInt(role['id']);
              final selected = id != null && roleIds.contains(id);
              return FilterChip(
                selected: selected,
                label: Text(_roleLabel(role)),
                avatar: Icon(
                  _roleIcon(role),
                  size: 16,
                  color: selected
                      ? SimcoreColors.accent
                      : SimcoreColors.textTertiary,
                ),
                onSelected: userId == null || id == null || isBusy
                    ? null
                    : (value) => _toggleRole(
                          context,
                          ref,
                          userId: userId,
                          currentRoleIds: roleIds,
                          roleId: id,
                          selected: value,
                        ),
              );
            }).toList(growable: false),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleRole(
    BuildContext context,
    WidgetRef ref, {
    required int userId,
    required List<int> currentRoleIds,
    required int roleId,
    required bool selected,
  }) async {
    final nextRoleIds = [...currentRoleIds];
    if (selected && !nextRoleIds.contains(roleId)) {
      nextRoleIds.add(roleId);
    }
    if (!selected) {
      nextRoleIds.remove(roleId);
    }
    if (nextRoleIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El usuario debe tener al menos un rol.'),
          backgroundColor: SimcoreColors.warning,
        ),
      );
      return;
    }

    final success =
        await ref.read(userAdminNotifierProvider.notifier).updateRoles(
              userId: userId,
              roleIds: nextRoleIds,
            );
    if (!context.mounted) return;
    _showResult(context, success, 'Roles actualizados.');
  }

  Future<void> _setEnabled(
    BuildContext context,
    WidgetRef ref,
    int userId,
    bool enabled,
  ) async {
    final success =
        await ref.read(userAdminNotifierProvider.notifier).setEnabled(
              userId: userId,
              enabled: enabled,
            );
    if (!context.mounted) return;
    _showResult(
      context,
      success,
      enabled ? 'Usuario activado.' : 'Usuario desactivado.',
    );
  }

  void _showResult(BuildContext context, bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? message : 'No se pudo completar la acción.'),
        backgroundColor: success ? SimcoreColors.success : SimcoreColors.danger,
      ),
    );
  }
}

String _displayName(Map<String, dynamic> user) {
  final fullName =
      '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
  final username = user['username']?.toString() ?? '';
  if (fullName.isEmpty) return username;
  if (username.isEmpty) return fullName;
  return '$fullName ($username)';
}

String _roleLabel(Map<String, dynamic> role) {
  final name = role['name']?.toString() ?? '';
  final normalized = name.replaceAll('ROLE_', '').toUpperCase();
  return switch (normalized) {
    'ADMIN' => 'Administrador',
    'DOCENTE' => 'Docente',
    'ESTUDIANTE' => 'Estudiante',
    _ => normalized.isEmpty ? 'Rol' : normalized,
  };
}

IconData _roleIcon(Map<String, dynamic> role) {
  final name = role['name']?.toString().toUpperCase() ?? '';
  if (name.contains('ADMIN')) return Icons.admin_panel_settings_rounded;
  if (name.contains('DOCENTE')) return Icons.school_rounded;
  return Icons.person_rounded;
}

List<int> _readRoleIds(Map<String, dynamic> user) {
  final raw = user['roleIds'];
  if (raw is List) {
    return raw.map(_readInt).whereType<int>().toList(growable: false);
  }
  final roleNames = (user['roles'] as List?)
          ?.map((role) => role.toString().toUpperCase().replaceAll('ROLE_', ''))
          .toSet() ??
      const <String>{};
  return roleNames
      .map((name) => switch (name) {
            'ADMIN' => 1,
            'DOCENTE' => 2,
            'ESTUDIANTE' => 3,
            _ => null,
          })
      .whereType<int>()
      .toList(growable: false);
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}
