import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/auth/presentation/screens/login_screens/loginscreen.dart';
import 'package:checklist_app/features/auth/presentation/screens/login_screens/sign_up_screen.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/screens/addCategory_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_details_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/addItemCategory_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_overview_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/create_checklist_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/success_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/screens/search_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/screens/viewall_checklist_screen.dart';
import 'package:checklist_app/features/templates/presentation/screens/template_overview_screen.dart';
import 'package:checklist_app/features/templates/presentation/screens/template_search_screen.dart';
import 'package:checklist_app/features/templates/presentation/screens/templates_list_screen.dart';
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

      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());

      case AppRoutes.templatesList:
        return MaterialPageRoute(builder: (_) => const TemplatesListScreen());

      case AppRoutes.searchTemplates:
        return MaterialPageRoute(builder: (_) => const TemplateSearchScreen());  

      case AppRoutes.viewAllChecklist:
        return MaterialPageRoute(builder: (_) => const AllChecklistsScreen());    

      case AppRoutes.addCategories:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => AddCategoryScreen(
            mode: args?["mode"] ?? ChecklistMode.create,
            checklistId: args?["checklistId"],
            checklist: args?["checklist"],
          ),
        );

      // case AppRoutes.templateDetails:
      //   final args = settings.arguments as Map<String, dynamic>;
      //   return MaterialPageRoute(
      //     builder: (_) =>
      //         TemplateOverviewScreen(templateId: args['templateId'] as String),
      //   );

      case AppRoutes.checklistDetails:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => ChecklistDetailScreen(
            mode: args?["mode"] ?? ChecklistMode.create,
            checklistId: args?["checklistId"],
          ),
        );

      case AppRoutes.addItems:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => AddITemCategoryScreen(
            mode: args?["mode"] ?? ChecklistMode.create,
            checklistId: args?["checklistId"],
          ),
        );

      case AppRoutes.viewChecklist:
      final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => ChecklistOverviewScreen(
            checklistId: args?["checklistId"],
            camefromViewAll  : args?["camefromViewAll"] ?? false
          )
        );

      case AppRoutes.createChecklist:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => CreateCheckListScreen(
            mode: args?["mode"] ?? ChecklistMode.create,
            checklistId: args?["checklistId"],
            showSkip: args?["showSkip"] ?? false,
            checklist: args?["checklist"],
          ),
        );

      case AppRoutes.success:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (_) => SuccessScreen(
            mode: args?["mode"] ?? ChecklistMode.create,
            checklistId: args?["checklistId"],
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Route not found"))),
        );
    }
  }
}
