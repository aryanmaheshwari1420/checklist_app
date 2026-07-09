import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/auth/presentation/screens/login_screens/loginscreen.dart';
import 'package:checklist_app/features/auth/presentation/screens/login_screens/sign_up_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/create_checklist_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/success_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case AppRoutes.signup:
        return MaterialPageRoute(
          builder: (_) => const SignUpScreen(),
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        );

      case AppRoutes.createChecklist:
        return MaterialPageRoute(
          builder: (_) => const CreateCheckListScreen(),
        );

      case AppRoutes.success:
        return MaterialPageRoute(
          builder: (_) => const SuccessScreen(checklistId: ''), 
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text("Route not found"),
            ),
          ),
        );
    }
  }
}