import 'package:core_sim_ia/features/shared/presentation/layout/simcore_shell_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  const AppRouter._();

  // Rutas principales SIMCORE
  static const String workspace = '/';
  static const String decisions = '/decisions';
  static const String market = '/market';
  static const String finance = '/finance';
  static const String organization = '/organization';
  static const String accounting = '/accounting';
  static const String analysis = '/analysis';
  static const String ranking = '/ranking';
  static const String profile = '/profile';
  static const String teacher = '/teacher';

  // Rutas antiguas temporales.
  // Se mantienen solo para no romper navegación vieja mientras migramos.
  static const String legacyHr = '/hr';
  static const String legacyOperations = '/operations';
  static const String legacyAdmin = '/admin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? workspace;
    final normalizedRoute = _normalizeRoute(routeName);
    final section = _sectionFromRoute(normalizedRoute);

    return MaterialPageRoute<void>(
      builder: (_) => SimcoreShellPage(section: section),
      settings: RouteSettings(
        name: normalizedRoute,
        arguments: settings.arguments,
      ),
    );
  }

  static String _normalizeRoute(String routeName) {
    return switch (routeName) {
      legacyHr => organization,
      legacyOperations => organization,
      legacyAdmin => teacher,
      workspace => workspace,
      decisions => decisions,
      market => market,
      finance => finance,
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
      finance => SimcoreSection.finance,
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
      SimcoreSection.finance => finance,
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
      workspace ||
      decisions ||
      market ||
      finance ||
      organization ||
      accounting ||
      analysis ||
      ranking ||
      profile ||
      teacher ||
      legacyHr ||
      legacyOperations ||
      legacyAdmin =>
        true,
      _ => false,
    };
  }
}