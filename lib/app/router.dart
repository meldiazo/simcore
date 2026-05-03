import 'package:core_sim_ia/features/stratova/presentation/stratova_shell_page.dart';
import 'package:flutter/material.dart';

class AppRouter {
  const AppRouter._();

  static const workspace = '/';
  static const decisions = '/decisions';
  static const market = '/market';
  static const finance = '/finance';
  static const hr = '/hr';
  static const operations = '/operations';
  static const analysis = '/analysis';
  static const ranking = '/ranking';
  static const profile = '/profile';
  static const admin = '/admin';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final section = switch (settings.name) {
      decisions => StratovaSection.decisions,
      market => StratovaSection.market,
      finance => StratovaSection.finance,
      hr => StratovaSection.hr,
      operations => StratovaSection.operations,
      analysis => StratovaSection.analysis,
      ranking => StratovaSection.ranking,
      profile => StratovaSection.profile,
      admin => StratovaSection.admin,
      _ => StratovaSection.workspace,
    };

    return MaterialPageRoute<void>(
      builder: (_) => StratovaShellPage(section: section),
      settings: settings,
    );
  }
}
