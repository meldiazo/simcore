import 'package:flutter/material.dart';
import 'package:simcore_frontend/app/router/app_router.dart';
import 'package:simcore_frontend/app/theme/app_theme.dart';

class ForbiddenPage extends StatelessWidget {
  const ForbiddenPage({
    super.key,
    this.routeName,
  });

  final String? routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SimcoreColors.bg,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: SimcoreColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 56,
                    color: SimcoreColors.warning,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Acceso no permitido',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: SimcoreColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    routeName == null
                        ? 'Tu rol no tiene permiso para acceder a esta sección.'
                        : 'Tu rol no tiene permiso para acceder a: $routeName',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: SimcoreColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRouter.workspace,
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.space_dashboard_rounded),
                    label: const Text('Volver al workspace'),
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