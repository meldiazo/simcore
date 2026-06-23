import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';
import 'package:simcore_frontend/core/error/error_utils.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';

class UserManagerPage extends ConsumerStatefulWidget {
  const UserManagerPage({super.key});

  @override
  ConsumerState<UserManagerPage> createState() => _UserManagerPageState();
}

class _UserManagerPageState extends ConsumerState<UserManagerPage> {
  final _searchController = TextEditingController();
  String _query = '';
  String _selectedRoleFilter = 'TODOS'; // 'TODOS', 'ADMIN', 'DOCENTE', 'ESTUDIANTE'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateUserDialog(),
    );
  }

  Widget _buildRoleFilterItem(String label, String filterValue, IconData icon) {
    final isSelected = _selectedRoleFilter == filterValue;
    return InkWell(
      onTap: () => setState(() => _selectedRoleFilter = filterValue),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? SimcoreColors.accentSoft : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? SimcoreColors.accent : SimcoreColors.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: SimcoreColors.accent.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? SimcoreColors.accent : SimcoreColors.textTertiary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? SimcoreColors.textPrimary : SimcoreColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
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
          trailing: FilledButton.icon(
            onPressed: () => _showCreateUserDialog(context),
            icon: const Icon(Icons.person_add_rounded),
            label: const Text('Crear Nuevo Usuario'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        
        // Search bar
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre, usuario o correo...',
                  prefixIcon: Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: SimcoreColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Role filters list
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildRoleFilterItem('Todos', 'TODOS', Icons.people_rounded),
              const SizedBox(width: 12),
              _buildRoleFilterItem('Administradores', 'ADMIN', Icons.admin_panel_settings_rounded),
              const SizedBox(width: 12),
              _buildRoleFilterItem('Docentes', 'DOCENTE', Icons.school_rounded),
              const SizedBox(width: 12),
              _buildRoleFilterItem('Estudiantes', 'ESTUDIANTE', Icons.person_rounded),
            ],
          ),
        ),
        const SizedBox(height: 24),

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
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No hay usuarios que coincidan con la búsqueda.',
                        style: TextStyle(color: SimcoreColors.textSecondary),
                      ),
                    ),
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
    var result = users;

    // Filter by role
    if (_selectedRoleFilter != 'TODOS') {
      result = result.where((user) {
        final roles = (user['roles'] as List?)
                ?.map((r) => r.toString().toUpperCase().replaceAll('ROLE_', ''))
                .toList() ??
            [];
        return roles.contains(_selectedRoleFilter);
      }).toList();
    }

    // Filter by search query
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return result;
    return result.where((user) {
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

  Future<void> _confirmDeleteUser(
    BuildContext context,
    WidgetRef ref,
    int userId,
    String displayName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar usuario?'),
        content: Text('Esta acción eliminará de forma permanente al usuario "$displayName". ¿Deseas continuar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: SimcoreColors.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(userAdminNotifierProvider.notifier).deleteUser(userId);
      if (!context.mounted) return;
      if (success) {
        showSimcoreSuccessDialog(
          context: context,
          title: '¡Usuario Eliminado!',
          message: 'El usuario ha sido eliminado correctamente del sistema.',
        );
      } else {
        final error = ref.read(userAdminNotifierProvider).error;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error al eliminar usuario'),
            content: Text(toUserFriendlyError(error)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    }
  }

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
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: enabled,
                    onChanged: userId == null || isBusy
                        ? null
                        : (value) => _setEnabled(context, ref, userId, value),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: SimcoreColors.danger),
                    onPressed: userId == null || isBusy
                        ? null
                        : () => _confirmDeleteUser(context, ref, userId, displayName),
                  ),
                ],
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

class _CreateUserDialog extends ConsumerStatefulWidget {
  const _CreateUserDialog();

  @override
  ConsumerState<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  bool _isBusy = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isBusy = true);

    final currentUser = ref.read(authNotifierProvider).user;
    final tenantId = currentUser?.tenantId ?? 1;

    final success = await ref.read(userAdminNotifierProvider.notifier).createUser(
          username: _usernameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text.trim(),
          firstName: _firstNameCtrl.text.trim(),
          lastName: _lastNameCtrl.text.trim(),
          tenantId: tenantId,
        );

    if (mounted) {
      setState(() => _isBusy = false);
      if (success) {
        Navigator.of(context).pop();
        showSimcoreSuccessDialog(
          context: context,
          title: '¡Usuario Creado!',
          message: 'El usuario ha sido registrado exitosamente.',
        );
      } else {
        final error = ref.read(userAdminNotifierProvider).error;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error al crear usuario'),
            content: Text(toUserFriendlyError(error)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: GlassPanel(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registrar Nuevo Usuario',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de Usuario',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña (mínimo 12 caracteres)',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) => v == null || v.length < 12
                        ? 'La contraseña debe tener al menos 12 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _firstNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isBusy ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _isBusy ? null : _submit,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isBusy
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
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
