import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.listenManual(authNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) {
        final user = next.user;

        final targetRoute = user != null && (user.isAdmin || user.isDocente)
            ? AppRouter.teacher
            : AppRouter.workspace;

        Navigator.of(context).pushReplacementNamed(targetRoute);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).login(
          _usernameController.text.trim(),
          _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: SimcoreColors.bg,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final horizontalPadding = constraints.maxWidth < 480 ? 24.0 : 40.0;

              return Row(
                children: [
                  if (isWide) _LeftPanel(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 24,
                        ),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: _LoginForm(
                            formKey: _formKey,
                            usernameController: _usernameController,
                            passwordController: _passwordController,
                            obscurePassword: _obscurePassword,
                            onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            isLoading: isLoading,
                            errorMessage: authState.status == AuthStatus.error
                                ? authState.errorMessage
                                : null,
                            onSubmit: _submit,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
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
      width: 480,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1D4ED8), Color(0xFF1E40AF), Color(0xFF1E3A8A)],
        ),
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: -80,
            left: -80,
            child: _GlowCircle(size: 320, opacity: 0.08),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: _GlowCircle(size: 280, opacity: 0.06),
          ),
          Positioned(
            top: 200,
            right: -40,
            child: _GlowCircle(size: 160, opacity: 0.05),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                _SimcoreLogo(),
                const SizedBox(height: 48),
                Text(
                  'Toma decisiones\nque mueven\nel mercado.',
                  style: GoogleFonts.inter(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Simulador de Empresas para la Enseñanza Universitaria',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white.withValues(alpha: 0.65),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 56),
                _StatRow(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _SimcoreLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.show_chart_rounded,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          'SIMCORE',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Stat(value: '200+', label: 'Empresas activas'),
        _StatDivider(),
        _Stat(value: '15K', label: 'Decisiones/día'),
        _StatDivider(),
        _Stat(value: '98%', label: 'Uptime'),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: 1,
      height: 36,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }
}

// ── Formulario ────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
    required this.isLoading,
    required this.onSubmit,
    this.errorMessage,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Bienvenido de nuevo',
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: SimcoreColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tus credenciales para continuar',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: SimcoreColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),

          // Error banner
          if (errorMessage != null) ...[
            _ErrorBanner(message: errorMessage!),
            const SizedBox(height: 24),
          ],

          // Username
          _FieldLabel(label: 'Usuario'),
          const SizedBox(height: 8),
          _SimcoreTextField(
            controller: usernameController,
            hint: 'Ingresa tu usuario',
            prefixIcon: Icons.person_outline_rounded,
            enabled: !isLoading,
            textInputAction: TextInputAction.next,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'El usuario es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password
          _FieldLabel(label: 'Contraseña'),
          const SizedBox(height: 8),
          _SimcoreTextField(
            controller: passwordController,
            hint: 'Ingresa tu contraseña',
            prefixIcon: Icons.lock_outline_rounded,
            obscureText: obscurePassword,
            enabled: !isLoading,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: SimcoreColors.textTertiary,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'La contraseña es obligatoria';
              return null;
            },
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 32),

          // Botón
          _LoginButton(isLoading: isLoading, onPressed: onSubmit),
          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              '© 2026 SIMCORE · Todos los derechos reservados',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: SimcoreColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

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
        letterSpacing: 0.1,
      ),
    );
  }
}

class _SimcoreTextField extends StatelessWidget {
  const _SimcoreTextField({
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.textInputAction,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final bool enabled;
  final TextInputAction? textInputAction;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      autocorrect: false,
      enableSuggestions: !obscureText,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: SimcoreColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: SimcoreColors.textTertiary,
        ),
        prefixIcon:
            Icon(prefixIcon, color: SimcoreColors.textTertiary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: SimcoreColors.muted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      ),
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Iniciar sesión',
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
