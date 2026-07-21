import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_overview_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SuccessScreen extends ConsumerWidget {
  final ChecklistMode mode;
  final String checklistId;
  const SuccessScreen({
    super.key,
    required this.checklistId,
    required this.mode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        ref.invalidate(dashboardProvider);

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      },
      child: Scaffold(
        // The background color is now handled by the theme
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 110,
                  width: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary, width: 3),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 60,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  mode == ChecklistMode.create
                      ? "Checklist Created!"
                      : "Checklist Updated!",
                  style: textTheme.headlineMedium,
                ),

                const SizedBox(height: 12),

                Text(
                  mode == ChecklistMode.create
                      ? "Your checklist has been created successfully."
                      : "Your checklist has been updated successfully.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  // This button is now styled by the theme's `elevatedButtonTheme`
                  child: ElevatedButton(
                    onPressed: () {
                      ref.invalidate(checklistByIdProvider(checklistId));
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.viewChecklist,
                        arguments: {'checklistId': checklistId},
                      );
                    },
                    child: const Text("View Checklist"),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  // This button is now styled by the theme's `outlinedButtonTheme`
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.createChecklist,
                        (route) => false,
                        arguments: {"mode": ChecklistMode.create},
                      );
                    },
                    child: const Text("Add Another"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
