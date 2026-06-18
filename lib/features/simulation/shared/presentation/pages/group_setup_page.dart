import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';
import 'package:simcore_frontend/features/academic/presentation/providers/academic_providers.dart';
import 'package:simcore_frontend/features/shared/presentation/widgets/glass_widgets.dart';

class GroupSetupPage extends ConsumerStatefulWidget {
  const GroupSetupPage({super.key});

  @override
  ConsumerState<GroupSetupPage> createState() => _GroupSetupPageState();
}

class _GroupSetupPageState extends ConsumerState<GroupSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupIdController = TextEditingController();
  Map<String, dynamic>? _selectedGroup;
  bool _showSearch = false;

  @override
  void dispose() {
    _groupIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final groupId = int.parse(_groupIdController.text.trim());
    await ref
        .read(simulationContextNotifierProvider.notifier)
        .loadByGroupId(groupId: groupId);
  }

  Future<void> _submitGroupId(int groupId) async {
    _groupIdController.text = groupId.toString();
    await ref
        .read(simulationContextNotifierProvider.notifier)
        .loadByGroupId(groupId: groupId);
  }

  void _goBack(AuthUser? user) {
    ref.read(simulationContextNotifierProvider.notifier).reset();

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    final fallbackRoute = user != null && (user.isAdmin || user.isDocente)
        ? AppRouter.teacher
        : AppRouter.login;
    Navigator.of(context).pushReplacementNamed(fallbackRoute);
  }

  @override
  Widget build(BuildContext context) {
    final ctxState = ref.watch(simulationContextNotifierProvider);
    final isLoading = ctxState.status == SimulationContextStatus.loading;
    final errorMessage = ctxState.status == SimulationContextStatus.needsGroupId
        ? ctxState.errorMessage
        : null;

    final currentUser = ref.watch(authNotifierProvider).user;
    final groupsAsync = ref.watch(allGroupsProvider);

    ref.listen(simulationContextNotifierProvider, (prev, next) {
      if (next.status == SimulationContextStatus.ready) {
        Navigator.of(context).pushReplacementNamed(AppRouter.workspace);
      }
    });

    return Scaffold(
      backgroundColor: SimcoreColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(child: _SimcoreLogoSmall()),
                      IconButton.filledTonal(
                        tooltip: 'Volver',
                        onPressed:
                            isLoading ? null : () => _goBack(currentUser),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Ingresa a tu empresa',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: SimcoreColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toca un grupo disponible o busca por nombre. No necesitas escribirlo exacto.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: SimcoreColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Loader de grupos
                  groupsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Cargando grupos disponibles...',
                              style:
                                  TextStyle(color: SimcoreColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: _HelpPanel(
                        icon: Icons.cloud_off_rounded,
                        title: 'No se pudieron cargar los grupos',
                        message:
                            'Revisa que el backend este encendido y vuelve a intentar.',
                        actionLabel: 'Reintentar',
                        onAction: () => ref.invalidate(allGroupsProvider),
                      ),
                    ),
                    data: (groups) {
                      // Buscar si el estudiante pertenece a algún grupo
                      Map<String, dynamic>? myGroup;
                      if (currentUser != null) {
                        for (final g in groups) {
                          final memberIds = g['memberIds'] as List?;
                          if (memberIds?.contains(currentUser.id) == true) {
                            myGroup = g;
                            break;
                          }
                        }
                      }

                      if (myGroup != null && !_showSearch) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GlassPanel(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: SimcoreColors.accentSoft,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.business_rounded,
                                          color: SimcoreColors.accent,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Grupo Asignado',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: SimcoreColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    myGroup['name']?.toString() ?? 'Sin Nombre',
                                    style: GoogleFonts.inter(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: SimcoreColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Tu docente te ha matriculado en este grupo para la simulación académica.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: SimcoreColors.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _SubmitButton(
                              isLoading: isLoading,
                              onPressed: () =>
                                  _submitGroupId(myGroup!['id'] as int),
                            ),
                            const SizedBox(height: 16),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showSearch = true;
                                  });
                                },
                                child: Text(
                                  'Buscar otro grupo...',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: SimcoreColors.accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      if (groups.isEmpty) {
                        return _HelpPanel(
                          icon: Icons.group_off_rounded,
                          title: 'No hay grupos disponibles',
                          message:
                              'Primero crea un grupo y asignale una empresa desde Gestion de Grupos.',
                          actionLabel: currentUser != null &&
                                  (currentUser.isAdmin || currentUser.isDocente)
                              ? 'Ir a Gestion de Grupos'
                              : null,
                          onAction: currentUser != null &&
                                  (currentUser.isAdmin || currentUser.isDocente)
                              ? () => Navigator.of(context)
                                  .pushReplacementNamed(AppRouter.groupManager)
                              : null,
                        );
                      }

                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _GroupSuggestionList(
                              groups: groups,
                              selectedGroupId: _selectedGroup?['id'] as int?,
                              isLoading: isLoading,
                              onSelected: (group) {
                                setState(() {
                                  _selectedGroup = group;
                                  _groupIdController.text =
                                      group['id'].toString();
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            Autocomplete<Map<String, dynamic>>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<
                                      Map<String, dynamic>>.empty();
                                }
                                return groups.where((g) {
                                  final name =
                                      g['name']?.toString().toLowerCase() ?? '';
                                  return name.contains(
                                      textEditingValue.text.toLowerCase());
                                });
                              },
                              displayStringForOption: (option) =>
                                  option['name']?.toString() ?? '',
                              onSelected: (option) {
                                setState(() {
                                  _selectedGroup = option;
                                  _groupIdController.text =
                                      option['id'].toString();
                                });
                              },
                              fieldViewBuilder: (context, textController,
                                  focusNode, onFieldSubmitted) {
                                // Asegurar que si el controller de búsqueda está vacío limpiemos la selección
                                textController.addListener(() {
                                  if (textController.text.isEmpty &&
                                      _selectedGroup != null) {
                                    setState(() {
                                      _selectedGroup = null;
                                      _groupIdController.clear();
                                    });
                                  }
                                });

                                return TextFormField(
                                  controller: textController,
                                  focusNode: focusNode,
                                  enabled: !isLoading,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: SimcoreColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Nombre del grupo o empresa',
                                    hintText:
                                        'Busca por nombre si no lo ves arriba...',
                                    prefixIcon:
                                        const Icon(Icons.group_outlined),
                                    filled: true,
                                    fillColor: SimcoreColors.surface,
                                    labelStyle: const TextStyle(
                                        color: SimcoreColors.textSecondary),
                                    hintStyle: const TextStyle(
                                        color: SimcoreColors.textTertiary),
                                    prefixIconColor: SimcoreColors.textTertiary,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: SimcoreColors.border),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: SimcoreColors.border),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: SimcoreColors.accent,
                                          width: 1.5),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: SimcoreColors.danger),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                          color: SimcoreColors.danger,
                                          width: 1.5),
                                    ),
                                    errorStyle: const TextStyle(
                                        color: SimcoreColors.danger),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Toca un grupo de la lista o busca uno';
                                    }
                                    if (_selectedGroup == null ||
                                        _selectedGroup!['name'] != value) {
                                      return 'Selecciona una opcion sugerida de la lista';
                                    }
                                    return null;
                                  },
                                );
                              },
                              optionsViewBuilder:
                                  (context, onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 8,
                                    color: SimcoreColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width:
                                          340, // Se ajusta al ancho del campo
                                      constraints:
                                          const BoxConstraints(maxHeight: 200),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: SimcoreColors.border),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          final option =
                                              options.elementAt(index);
                                          return InkWell(
                                            onTap: () => onSelected(option),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.business_rounded,
                                                      color:
                                                          SimcoreColors.accent,
                                                      size: 18),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      option['name']
                                                              ?.toString() ??
                                                          '',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: SimcoreColors
                                                            .textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (errorMessage != null) ...[
                              const SizedBox(height: 12),
                              _ErrorBanner(message: errorMessage),
                            ],
                            const SizedBox(height: 24),
                            _SubmitButton(
                                isLoading: isLoading, onPressed: _submit),
                            if (myGroup != null) ...[
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _showSearch = false;
                                    });
                                  },
                                  child: Text(
                                    'Volver a mi grupo asignado',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: SimcoreColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _LogoutLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SimcoreLogoSmall extends StatelessWidget {
  const _SimcoreLogoSmall();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: const LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            ),
          ),
          child: const Icon(Icons.bar_chart_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'SIMCORE',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: SimcoreColors.textPrimary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _GroupSuggestionList extends StatelessWidget {
  const _GroupSuggestionList({
    required this.groups,
    required this.selectedGroupId,
    required this.isLoading,
    required this.onSelected,
  });

  final List<Map<String, dynamic>> groups;
  final int? selectedGroupId;
  final bool isLoading;
  final ValueChanged<Map<String, dynamic>> onSelected;

  @override
  Widget build(BuildContext context) {
    final visibleGroups = groups.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Grupos disponibles',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: SimcoreColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona uno para continuar. Si no aparece el tuyo, usa el buscador.',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: SimcoreColors.textSecondary,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        ...visibleGroups.map((group) {
          final groupId = group['id'] as int?;
          final selected = groupId != null && groupId == selectedGroupId;
          final memberCount = group['memberCount'] ?? 0;
          final companyCount = group['companyCount'] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: isLoading ? null : () => onSelected(group),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? SimcoreColors.accentSoft
                      : SimcoreColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        selected ? SimcoreColors.accent : SimcoreColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.business_rounded,
                      color: selected
                          ? SimcoreColors.accent
                          : SimcoreColors.textTertiary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group['name']?.toString() ?? 'Grupo sin nombre',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: SimcoreColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '$memberCount estudiantes · $companyCount empresa',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: SimcoreColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (groups.length > visibleGroups.length)
          Text(
            '${groups.length - visibleGroups.length} grupos mas disponibles en el buscador.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: SimcoreColors.textSecondary,
            ),
          ),
      ],
    );
  }
}

class _HelpPanel extends StatelessWidget {
  const _HelpPanel({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SimcoreColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SimcoreColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: SimcoreColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SimcoreColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: SimcoreColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SimcoreColors.dangerSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SimcoreColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: SimcoreColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No se pudo ingresar al grupo. Verifica tu conexión.',
              style:
                  GoogleFonts.inter(fontSize: 13, color: SimcoreColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: SimcoreColors.accent,
          disabledBackgroundColor: SimcoreColors.accent.withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Ingresar',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

class _LogoutLink extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () => ref.read(authNotifierProvider.notifier).logout(),
      child: Text(
        'Cerrar sesión',
        style: GoogleFonts.inter(
          fontSize: 13,
          color: SimcoreColors.textSecondary,
        ),
      ),
    );
  }
}
