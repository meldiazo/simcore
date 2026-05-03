import 'package:core_sim_ia/app/router.dart';
import 'package:core_sim_ia/app/theme.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stratova',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.workspace,
      theme: buildStratovaTheme(),
    );
  }
}
