import 'package:simcore_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:simcore_frontend/features/auth/presentation/pages/register_page.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_notifier.dart';
import 'package:simcore_frontend/features/auth/presentation/providers/auth_state.dart';
import 'package:simcore_frontend/features/shared/presentation/layout/simcore_shell_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simcore_frontend/features/auth/domain/entities/auth_user.dart';
import 'package:simcore_frontend/features/shared/presentation/pages/forbidden_page.dart';

class AppRouter {
  const AppRouter._();

  static const String login = '/login';
  static const String register = '/register';
  static const String workspace = '/';
  static const String decisions = '/decisions';
  static const String market = '/market';
  static const String investment = '/investment';
  static const String legacyFinance = '/finance';
  static const String organization = '/organization';
  static const String accounting = '/accounting';
  static const String analysis = '/analysis';
  static const String ranking = '/ranking';
  static const String profile = '/profile';
  static const String teacher = '/teacher';

  static const String legacyHr = '/hr';
  static const String legacyAdmin = '/admin';

  static const Set<String> _studentRoutes = <String>{
    workspace,
    decisions,
    market,
    investment,
    organization,
    accounting,
    analysis,
    profile,
  };

  static const Set<String> _teacherRoutes = <String>{
    workspace,
    decisions,
    market,
    investment,
    organization,
    accounting,
    analysis,
    ranking,
    profile,
    teacher,
  };

  static bool canAccessRoute(String routeName, AuthUser user) {
    if (!isKnownRoute(routeName)) return false;

    if (routeName == login) return true;

    if (routeName == register) {
      return user.canManageUsers;
    }

    final normalizedRoute = _normalizeRoute(routeName);

    if (user.isAdmin) return true;

    if (user.isDocente) {
      return _teacherRoutes.contains(normalizedRoute);
    }

    if (user.isEstudiante) {
      return _studentRoutes.contains(normalizedRoute);
    }

    return false;
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? workspace;

    if (routeName == login) {
      return MaterialPageRoute<void>(
        builder: (_) => const LoginPage(),
        settings: settings,
      );
    }

    final normalizedRoute = _normalizeRoute(routeName);
    final section = _sectionFromRoute(normalizedRoute);

    if (routeName == register) {
      return MaterialPageRoute<void>(
        builder: (_) => _AuthGuard(
          routeName: register,
          child: const RegisterPage(),
        ),
        settings: settings,
      );
    }

    return MaterialPageRoute<void>(
      builder: (_) => _AuthGuard(
        routeName: normalizedRoute,
        child: SimcoreShellPage(section: section),
      ),
      settings: RouteSettings(name: normalizedRoute, arguments: settings.arguments),
    );
  }

  static String _normalizeRoute(String routeName) {
    return switch (routeName) {
      legacyHr => organization,
      legacyAdmin => teacher,
      workspace => workspace,
      decisions => decisions,
      market => market,
      legacyFinance => investment,
      investment => investment,
      organization => organization,
      accounting => accounting,
      analysis => analysis,
      ranking => ranking,
      profile => profile,
      teacher => teacher,
      _ => workspace,
    };
  }

  static SimcoreSection _sectionFromRoute(String routeName) {
    return switch (routeName) {
      decisions => SimcoreSection.decisions,
      market => SimcoreSection.market,
      investment => SimcoreSection.investment,
      organization => SimcoreSection.organization,
      accounting => SimcoreSection.accounting,
      analysis => SimcoreSection.analysis,
      ranking => SimcoreSection.ranking,
      profile => SimcoreSection.profile,
      teacher => SimcoreSection.teacher,
      _ => SimcoreSection.workspace,
    };
  }

  static String routeFromSection(SimcoreSection section) {
    return switch (section) {
      SimcoreSection.workspace => workspace,
      SimcoreSection.decisions => decisions,
      SimcoreSection.market => market,
      SimcoreSection.investment => investment,
      SimcoreSection.organization => organization,
      SimcoreSection.accounting => accounting,
      SimcoreSection.analysis => analysis,
      SimcoreSection.ranking => ranking,
      SimcoreSection.profile => profile,
      SimcoreSection.teacher => teacher,
    };
  }

  static bool isKnownRoute(String? routeName) {
    if (routeName == null) return false;
    return switch (routeName) {
      login ||
      register ||
      workspace ||
      decisions ||
      market ||
      investment ||
      legacyFinance ||
      organization ||
      accounting ||
      analysis ||
      ranking ||
      profile ||
      teacher ||
      legacyAdmin ||
      legacyHr =>
        true,
      _ => false,
    };
  }
}

// ── Guard que protege rutas autenticadas ──────────────────────────────────────

class _AuthGuard extends ConsumerWidget {
  const _AuthGuard({required this.routeName, required this.child});

  final String routeName;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );

      case AuthStatus.authenticated:
        final user = authState.user;

        if (user == null) {
          return const LoginPage();
        }

        if (!AppRouter.canAccessRoute(routeName, user)) {
          return ForbiddenPage(routeName: routeName);
        }

        return child;

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginPage();
    }
  }
}