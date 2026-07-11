import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/checklist_header.dart';
import '../widgets/checklist_progress_bar.dart';
import '../widgets/category_progress_tile.dart';

class ChecklistOverviewScreen extends ConsumerStatefulWidget {
  final String checklistId;

  const ChecklistOverviewScreen({super.key, required this.checklistId});

  @override
  ConsumerState<ChecklistOverviewScreen> createState() => _ChecklistOverviewScreenState();
}

class _ChecklistOverviewScreenState extends ConsumerState<ChecklistOverviewScreen> {
  double calculateChecklistProgress(ChecklistModel checklist) {
    int total = 0;
    int completed = 0;

    for (final items in checklist.items.values) {
      total += items.length;

      completed += items.where((item) => item.checked).length;
    }

    return total == 0 ? 0.0 : completed / total;
  }

  @override
  void initState() {
    super.initState();
     Future.microtask(() {
      ref.invalidate(checklistControllerProvider);
    });

  }

  @override
  Widget build(BuildContext context) {
    final checklistAsync = ref.watch(checklistByIdProvider(widget.checklistId));
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return checklistAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),

      error: (error, _) =>
          Scaffold(body: Center(child: Text(error.toString()))),

      data: (checklist) {
        if (checklist == null) {
          return const Scaffold(
            body: Center(child: Text("Checklist not found.")),
          );
        }
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            ref.invalidate(dashboardProvider);
            ref.invalidate(checklistByIdProvider(widget.checklistId));
            ref.invalidate(checklistControllerProvider);

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboard,
              (route) => false,
            );
          },
          child: Scaffold(
            // Scaffold and AppBar are now styled by the global theme
            appBar: AppBar(
              // The back button's pop behavior is handled by the PopScope below
              centerTitle: true,
              title: Text(
                checklist.title,
                // Style is inherited from appBarTheme.titleTextStyle
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.createChecklist,
                      arguments: {
                        "mode": ChecklistMode.edit,
                        "showSkip": false,
                        "checklistId": widget.checklistId,
                      },
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case "delete":
                        showDeleteDialog(ref, context);
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.delete_outline, color: colorScheme.error),
                          const SizedBox(width: 10),
                           Text(
                            "Delete Checklist",
                            style: TextStyle(color: colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // The FAB is now styled by the theme's `floatingActionButtonTheme`
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.addItems,
                  arguments: {
                    "mode": ChecklistMode.edit,
                    "checklistId": widget.checklistId,
                  },
                );
              },
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
            ),

            body: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  ChecklistHeader(checklist: checklist),

                  const SizedBox(height: 25),

                  ChecklistProgressBar(
                    progress: calculateChecklistProgress(checklist),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    "Checklist for our ${checklist.title} preparation.",
                    style: textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Categories",
                        style: textTheme.titleLarge,
                      ),
                      Text(
                        "Edit Order",
                        style: textTheme.labelLarge
                            ?.copyWith(color: colorScheme.primary),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: checklist.categories.length,
                            itemBuilder: (context, index) {
                              final category = checklist.categories[index];

                              final items = checklist.items[category] ?? [];

                              final completed = items
                                  .where((item) => item.checked)
                                  .length;

                              return CategoryProgressTile(
                                icon: Icons.folder_outlined,
                                title: category,
                                completed: completed,
                                total: items.length,
                                onTap: () {
                                  // next screen
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showDeleteDialog(WidgetRef ref, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          // Shape is now handled by the theme's `dialogTheme`
          title: const Text("Delete Checklist"),
          content: const Text(
            "Are you sure you want to delete this checklist?\n\nThis action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await deleteChecklist(ref, context);
  }

  Future<void> deleteChecklist(WidgetRef ref, BuildContext context) async {
    await ref
        .read(checklistControllerProvider.notifier)
        .deleteChecklist(widget.checklistId);

    if (!context.mounted) return;
    ref.invalidate(dashboardProvider);

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.dashboard,
      (_) => false,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Checklist deleted successfully.")),
    );
  }
}
