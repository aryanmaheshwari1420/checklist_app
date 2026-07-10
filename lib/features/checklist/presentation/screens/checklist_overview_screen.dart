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
            backgroundColor: const Color(0xffF7F7F7),

            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,

              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  ref.invalidate(dashboardProvider);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.dashboard,
                    (route) => false,
                  );
                },
              ),

              centerTitle: true,

              title: Text(
                checklist.title,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
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
                  icon: const Icon(Icons.edit_outlined, color: Colors.black),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case "delete":
                        showDeleteDialog(ref, context);
                        break;
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 10),
                          Text(
                            "Delete Checklist",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            floatingActionButton: FloatingActionButton.extended(
              backgroundColor: const Color(0xff5B3DF5),

              onPressed: () {},

              icon: const Icon(Icons.add, color: Colors.white),

              label: const Text(
                "Add Item",
                style: TextStyle(color: Colors.white),
              ),
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
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),

                  const SizedBox(height: 30),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        "Categories",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),

                      Text(
                        "Edit Order",
                        style: TextStyle(
                          color: Color(0xff5B3DF5),
                          fontWeight: FontWeight.w600,
                        ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Delete Checklist"),
          content: const Text(
            "Are you sure you want to delete this checklist?\n\nThis action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
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
