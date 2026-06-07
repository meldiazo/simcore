import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/simulation/shared/presentation/providers/simulation_context_notifier.dart';

class GroupSetupPage extends ConsumerStatefulWidget {
  const GroupSetupPage({super.key});

  @override
  ConsumerState<GroupSetupPage> createState() => _GroupSetupPageState();
}

class _GroupSetupPageState extends ConsumerState<GroupSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _groupIdController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    final ctxState = ref.watch(simulationContextNotifierProvider);
    final isLoading = ctxState.status == SimulationContextStatus.loading;
    final errorMessage = ctxState.status == SimulationContextStatus.needsGroupId
        ? ctxState.errorMessage
        : null;

    ref.listen(simulationContextNotifierProvider, (prev, next) {
      if (next.status == SimulationContextStatus.ready) {
        Navigator.of(context).pushReplacementNamed(AppRouter.workspace);
      }
    });

    return Scaffold(
      backgroundColor: SimcoreColors.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SimcoreLogoSmall(),
                  const SizedBox(height: 40),
                  Text(
                    'Ingresa a tu empresa',
                    style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ingresa el ID de tu grupo para cargar el contexto de simulación.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.55),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _GroupIdField(
                    controller: _groupIdController,
                    enabled: !isLoading,
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _ErrorBanner(message: errorMessage),
                  ],
                  const SizedBox(height: 24),
                  _SubmitButton(isLoading: isLoading, onPressed: _submit),
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
          child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          'SIMCORE',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _GroupIdField extends StatelessWidget {
  const _GroupIdField({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: 'ID de Grupo',
        hintText: 'Ej: 3',
        prefixIcon: const Icon(Icons.group_outlined),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIconColor: Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFEF4444)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Ingresa el ID de tu grupo';
        }
        final id = int.tryParse(value.trim());
        if (id == null || id <= 0) return 'Ingresa un número válido';
        return null;
      },
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
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No se encontró una empresa para ese grupo. Verifica el ID.',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFFEF4444)),
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
          backgroundColor: const Color(0xFF2563EB),
          disabledBackgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
          color: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
