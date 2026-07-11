import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:flutter/material.dart';

class EmptyDashboard extends StatelessWidget {
  const EmptyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 150,
            color: colorScheme.onSurface.withOpacity(0.25),
          ),

          const SizedBox(height: 30),

          Text(
            "No Checklists Yet!",
            style: textTheme.headlineSmall,
          ),

          const SizedBox(height: 12),

          Text(
            "Create your first checklist to start tracking your tasks and progress.",
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant),
          ),

          const SizedBox(height: 35),

          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.7,
            height: 55,
            // This button is now styled by the theme's `elevatedButtonTheme`
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.createChecklist,
                  arguments: {
                    "mode": ChecklistMode.create,
                    "showSkip": false
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Create New Checklist"),
            ),
          ),
        ],
      ),
    );
  }
}