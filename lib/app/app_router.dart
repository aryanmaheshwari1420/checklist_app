import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/auth/presentation/screens/login_screens/loginscreen.dart';
import 'package:checklist_app/features/auth/presentation/screens/login_screens/sign_up_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/category_selection_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_details_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_items_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_overview_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/create_checklist_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/success_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());

      case AppRoutes.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());

      case AppRoutes.createChecklist:
        return MaterialPageRoute(builder: (_) => const CreateCheckListScreen());

      case AppRoutes.checklistDetails:
        return MaterialPageRoute(builder: (_) => const MoreDetailScreen());

        case AppRoutes.addCategories:
        return MaterialPageRoute(builder: (_) => const AddCategoryScreen());

        case AppRoutes.addItems:
        return MaterialPageRoute(builder: (_) => const AddITemCategoryScreen());
        
        case AppRoutes.viewChecklist:
        final checklistId = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => ChecklistOverviewScreen(checklistId: checklistId),
        );

      case AppRoutes.success:
        final checklistId = settings.arguments as String;

        return MaterialPageRoute(
          builder: (_) => SuccessScreen(checklistId: checklistId),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
