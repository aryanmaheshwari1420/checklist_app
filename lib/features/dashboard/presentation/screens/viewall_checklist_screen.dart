import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_overview_screen.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:checklist_app/features/dashboard/presentation/widgets/recent_checklist_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AllChecklistsScreen extends ConsumerWidget {
  const AllChecklistsScreen({super.key});

  String _imageForType(String type) {
    switch (type) {
      case "Travel":
        return "assets/images/Traveli.png";
      case "Finance":
        return "assets/images/financei.png";
      case "Vehicle":
        return "assets/images/vehiclei.png";
      case "Event":
        return "assets/images/Eventi.png";
      case "Personal":
        return "assets/images/personali.png";
      case "Charity":
        return "assets/images/Charityi.png";
      case "Split":
        return "assets/images/Spliti.png";
      case "Vendor":
        return "assets/images/Vendori.png";
      case "Other":
        return "assets/images/other_twoi.png";
      default:
        return "assets/images/other_twoi.png";
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("All Checklists")),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (checklists) {
          if (checklists.isEmpty) {
            return const Center(child: Text("No checklists created yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: checklists.length,
            itemBuilder: (context, index) {
              final checklist = checklists[index];

              int totalItems = 0;
              int completedItems = 0;

              for (final items in checklist.items.values) {
                totalItems += items.length;
                completedItems += items.where((e) => e.checked).length;
              }

              String status;
              if (completedItems == totalItems && totalItems > 0) {
                status = "Completed";
              } else if (completedItems == 0) {
                status = "Pending";
              } else {
                status = "In Progress";
              }

              return RecentChecklistCard(
                title: checklist.title,
                completed: completedItems,
                total: totalItems,
                status: status,
                imagePath: _imageForType(checklist.type),
                dueDate: checklist.dueDate,
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.viewChecklist,
                    arguments: checklist.id,
                  );
                },
                onDelete: () async {
                  await ref
                      .read(checklistControllerProvider.notifier)
                      .deleteChecklist(checklist.id);

                  ref.invalidate(dashboardProvider);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Checklist deleted successfully."),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
