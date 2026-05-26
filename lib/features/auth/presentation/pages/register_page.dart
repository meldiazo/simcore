import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/auth/domain/usecases/register_user_usecase.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/register_notifier.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/register_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// IDs de roles según el backend
const _roles = [
  _RoleOption(
      id: 1, label: 'Administrador', icon: Icons.admin_panel_settings_rounded),
  _RoleOption(id: 2, label: 'Docente', icon: Icons.school_rounded),
  _RoleOption(id: 3, label: 'Estudiante', icon: Icons.person_rounded),
];

class _RoleOption {
  const _RoleOption(
      {required this.id, required this.label, required this.icon});
  final int id;
  final String label;
  final IconData icon;
}

// ── Page ──────────────────────────────────────────────────────────────────────

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();

  bool _obscurePassword = true;
  int _selectedRoleId = 3;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(registerNotifierProvider.notifier).register(
          RegisterUserParams(
            username: _usernameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            firstName: _firstNameCtrl.text.trim(),
            lastName: _lastNameCtrl.text.trim(),
            roleId: _selectedRoleId,
          ),
        );
  }

  void _handleSuccess() {
    ref.read(registerNotifierProvider.notifier).reset();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(
              'Usuario creado exitosamente',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: SimcoreColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerNotifierProvider);

    ref.listen(registerNotifierProvider, (_, next) {
      if (next.isSuccess) _handleSuccess();
    });

    return Scaffold(
      backgroundColor: SimcoreColors.bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Row(
          children: [
            _LeftPanel(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(onBack: () => Navigator.of(context).pop()),
                        const SizedBox(height: 32),
                        if (state.status == RegisterStatus.error &&
                            state.fieldErrors.isEmpty &&
                            state.errorMessage != null) ...[
                          _ErrorBanner(message: state.errorMessage!),
                          const SizedBox(height: 24),
                        ],
                        _RegisterForm(
                          formKey: _formKey,
                          usernameCtrl: _usernameCtrl,
                          emailCtrl: _emailCtrl,
                          passwordCtrl: _passwordCtrl,
                          firstNameCtrl: _firstNameCtrl,
                          lastNameCtrl: _lastNameCtrl,
                          obscurePassword: _obscurePassword,
                          onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          selectedRoleId: _selectedRoleId,
                          onRoleChanged: (id) =>
                              setState(() => _selectedRoleId = id),
                          fieldErrors: state.fieldErrors,
                          isLoading: state.isLoading,
                          onSubmit: _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Panel izquierdo ───────────────────────────────────────────────────────────

class _LeftPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width > 900;
    if (!isWide) return const SizedBox.shrink();

    return Container(
      width: 420,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF), Color(0xFF1E3A8A)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: _Circle(size: 280, alpha: 0.07),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: _Circle(size: 320, alpha: 0.05),
          ),
          Padding(
            padding: const EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                _Logo(),
                const SizedBox(height: 48),
                Text(
                  'Gestión de\nusuarios\nSimplificada.',
                  style: GoogleFonts.inter(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Crea y asigna roles a estudiantes,\ndocentes y administradores desde\nun solo lugar.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.7,
                  ),
                ),
                const SizedBox(height: 48),
                _RoleCards(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.alpha});
  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: alpha),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.show_chart_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'SIMCORE',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _RoleCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: _roles
          .map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(r.icon,
                        color: Colors.white.withValues(alpha: 0.8), size: 18),
                    const SizedBox(width: 12),
                    Text(
                      r.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Header con botón back ─────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onBack,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back_rounded,
                  size: 16, color: SimcoreColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Volver',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: SimcoreColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Crear usuario',
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: SimcoreColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Completa los datos y asigna un rol al nuevo usuario',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: SimcoreColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ── Formulario ────────────────────────────────────────────────────────────────

class _RegisterForm extends StatelessWidget {
  const _RegisterForm({
    required this.formKey,
    required this.usernameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.firstNameCtrl,
    required this.lastNameCtrl,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.selectedRoleId,
    required this.onRoleChanged,
    required this.fieldErrors,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController firstNameCtrl;
  final TextEditingController lastNameCtrl;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final int selectedRoleId;
  final void Function(int) onRoleChanged;
  final Map<String, String> fieldErrors;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nombre y Apellido en fila
          Row(
            children: [
              Expanded(
                child: _Field(
                  label: 'Nombre',
                  controller: firstNameCtrl,
                  hint: 'Juan',
                  icon: Icons.badge_outlined,
                  enabled: !isLoading,
                  backendError: fieldErrors['firstName'],
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _Field(
                  label: 'Apellido',
                  controller: lastNameCtrl,
                  hint: 'Pérez',
                  icon: Icons.badge_outlined,
                  enabled: !isLoading,
                  backendError: fieldErrors['lastName'],
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Obligatorio' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _Field(
            label: 'Usuario',
            controller: usernameCtrl,
            hint: 'juanperez',
            icon: Icons.person_outline_rounded,
            enabled: !isLoading,
            backendError: fieldErrors['username'],
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return 'El usuario es obligatorio';
              if (v.trim().length < 3) return 'Mínimo 3 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 18),

          _Field(
            label: 'Correo electrónico',
            controller: emailCtrl,
            hint: 'juan@ejemplo.com',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            enabled: !isLoading,
            backendError: fieldErrors['email'],
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return 'El correo es obligatorio';
              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
              if (!emailRegex.hasMatch(v.trim())) return 'Correo inválido';
              return null;
            },
          ),
          const SizedBox(height: 18),

          _PasswordField(
            controller: passwordCtrl,
            obscure: obscurePassword,
            onToggle: onToggleObscure,
            enabled: !isLoading,
            backendError: fieldErrors['password'],
          ),
          const SizedBox(height: 24),

          // Selector de rol
          _FieldLabel(label: 'Rol del usuario'),
          const SizedBox(height: 10),
          _RoleSelector(
            selectedId: selectedRoleId,
            onChanged: onRoleChanged,
            enabled: !isLoading,
          ),
          const SizedBox(height: 32),

          _SubmitButton(isLoading: isLoading, onPressed: onSubmit),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Widgets reutilizables ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: SimcoreColors.textPrimary,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.enabled,
    this.keyboardType,
    this.backendError,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? backendError;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label: label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style:
              GoogleFonts.inter(fontSize: 14, color: SimcoreColors.textPrimary),
          validator: (v) => backendError ?? validator?.call(v),
          decoration: _inputDeco(hint, icon),
        ),
        if (backendError != null) ...[
          const SizedBox(height: 4),
          _InlineError(message: backendError!),
        ],
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.obscure,
    required this.onToggle,
    required this.enabled,
    this.backendError,
  });

  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final bool enabled;
  final String? backendError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel(label: 'Contraseña'),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          enabled: enabled,
          style:
              GoogleFonts.inter(fontSize: 14, color: SimcoreColors.textPrimary),
          validator: (v) {
            if (backendError != null) return backendError;
            if (v == null || v.isEmpty) return 'La contraseña es obligatoria';
            if (v.length < 12) return 'Mínimo 12 caracteres';
            return null;
          },
          decoration:
              _inputDeco('Mínimo 12 caracteres', Icons.lock_outline_rounded)
                  .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: SimcoreColors.textTertiary,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
        if (backendError != null) ...[
          const SizedBox(height: 4),
          _InlineError(message: backendError!),
        ],
      ],
    );
  }
}

InputDecoration _inputDeco(String hint, IconData icon) {
  return InputDecoration(
    hintText: hint,
    hintStyle:
        GoogleFonts.inter(fontSize: 14, color: SimcoreColors.textTertiary),
    prefixIcon: Icon(icon, color: SimcoreColors.textTertiary, size: 20),
    filled: true,
    fillColor: SimcoreColors.muted,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: SimcoreColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: SimcoreColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: SimcoreColors.accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: SimcoreColors.danger),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: SimcoreColors.danger, width: 1.5),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: SimcoreColors.border),
    ),
    errorStyle: const TextStyle(height: 0, fontSize: 0),
  );
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded,
            size: 13, color: SimcoreColors.danger),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            message,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: SimcoreColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Selector de rol ───────────────────────────────────────────────────────────

class _RoleSelector extends StatelessWidget {
  const _RoleSelector({
    required this.selectedId,
    required this.onChanged,
    required this.enabled,
  });

  final int selectedId;
  final void Function(int) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _roles.map((role) {
        final isSelected = role.id == selectedId;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: role.id != _roles.last.id ? 10 : 0,
            ),
            child: GestureDetector(
              onTap: enabled ? () => onChanged(role.id) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? SimcoreColors.accentSoft
                      : SimcoreColors.muted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? SimcoreColors.accent
                        : SimcoreColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      role.icon,
                      size: 22,
                      color: isSelected
                          ? SimcoreColors.accent
                          : SimcoreColors.textTertiary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? SimcoreColors.accent
                            : SimcoreColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Botón submit ──────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: SimcoreColors.accent,
          disabledBackgroundColor: SimcoreColors.accentMuted,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : Text(
                'Crear usuario',
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

// ── Error banner global ───────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: SimcoreColors.dangerSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SimcoreColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: SimcoreColors.danger, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: SimcoreColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
