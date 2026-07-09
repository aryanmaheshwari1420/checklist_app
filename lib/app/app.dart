import 'package:checklist_app/app/app_router.dart';
import 'package:checklist_app/app/auth_gate.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Checklist App',

      theme: AppTheme.light,

      home: const AuthGate(),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}