import 'package:checklist_app/features/auth/presentation/screens/login_screens/loginscreen.dart';
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Checklist App',

      theme: AppTheme.light,

      home: const LoginScreen(),
    );
  }
}