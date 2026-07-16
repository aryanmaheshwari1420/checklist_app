import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:checklist_app/shared/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddITemCategoryScreen extends ConsumerStatefulWidget {
  final ChecklistMode mode;
  final String? checklistId;

  const AddITemCategoryScreen({
    super.key,
    required this.mode,
    this.checklistId,
  });

  @override
  ConsumerState<AddITemCategoryScreen> createState() =>
      _AddITemCategoryScreenState();
}

class _AddITemCategoryScreenState extends ConsumerState<AddITemCategoryScreen> {
  void editItemDialog(String category, int index) {
    final items = ref.read(checklistControllerProvider).items[category] ?? [];

    final oldItem = items[index];

    final controller = TextEditingController(text: oldItem.title);

    showBlurDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Item"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter item name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();

              if (value.isNotEmpty) {
                ref
                    .read(checklistControllerProvider.notifier)
                    .updateItem(
                      category: category,
                      oldItem: oldItem,
                      newItem: oldItem.copyWith(title: value),
                    );
              }

              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void deleteItem(String category, int index) {
    final items = ref.read(checklistControllerProvider).items[category] ?? [];
    final item = items[index];

    showBlurDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref
                  .read(checklistControllerProvider.notifier)
                  .removeItem(category: category, item: item);

              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void addItemDialog(String category) {
    final TextEditingController controller = TextEditingController();

    showBlurDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add Item to $category"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter item name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  ref
                      .read(checklistControllerProvider.notifier)
                      .addItem(category: category, item: value);
                }

                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(checklistControllerProvider);
    final categories = state.categories;
    final items = state.items;

    return Scaffold(
      // Scaffold and AppBar are now styled by the global theme
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.mode == ChecklistMode.create
          ?"Create Checklist": "Edit Checklist",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Items in Categories",
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              "Add checklist items for each category.",
              style: textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  // Renamed from `items` to avoid shadowing the outer
                  // `items` map (state.items) declared in build().
                  final categoryItemList = items[category] ?? [];

                  // Using a Card which will be styled by the theme's `cardTheme`
                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: ExpansionTile(
                      initiallyExpanded: index == 0,
                      title: Text(
                        "$category (${categoryItemList.length})",
                        style: textTheme.titleMedium
                            ?.copyWith(color: colorScheme.primary),
                      ),
                      children: [
                        if (categoryItemList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Text(
                              "No Items Added",
                              style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ),
                        ...categoryItemList.asMap().entries.map((entry) {
                          int itemIndex = entry.key;
                          final ChecklistItem item = entry.value;

                          return CheckboxListTile(
                              value: item.checked,
                              controlAffinity:ListTileControlAffinity.leading,
                              onChanged: (value) {
                                final updatedItem = item.copyWith(
                                  checked: value,
                                );

                                ref
                                    .read(checklistControllerProvider.notifier)
                                    .updateItem(
                                      category: category,
                                      oldItem: item,
                                      newItem: updatedItem,
                                    );
                              },
                            title: Text(item.title),
                            secondary: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "edit") {
                                  editItemDialog(category, itemIndex);
                                } else {
                                  deleteItem(category, itemIndex);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: "edit",
                                  child: Text("Edit"),
                                ),
                                PopupMenuItem(
                                  value: "delete",
                                  child: Text("Delete"),
                                ),
                              ],
                            ),
                          );
                        }),
                        const Divider(height: 1),
                        InkWell(
                          onTap: () {
                            addItemDialog(category);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  "Add Item",
                                  style: textTheme.labelLarge
                                      ?.copyWith(color: colorScheme.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Back"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final controller = ref.read(
                        checklistControllerProvider.notifier,
                      );

                      String? checklistId;

                      if (widget.mode == ChecklistMode.create) {
                        checklistId = await controller.createChecklist();
                      } else {
                        await controller.updateChecklist();
                        checklistId = widget.checklistId;
                        debugPrint("Checklist updated with ID: $checklistId");
                      }

                      if (!mounted) return;

                      ref.invalidate(dashboardProvider);

                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.success,
                        arguments: {
                          "checklistId": checklistId,
                          "mode": widget.mode,
                        },
                      );
                    },
                    child: Text(
                      widget.mode == ChecklistMode.create
                          ? "Create"
                          : "Save Changes",
                      // Style is inherited from elevatedButtonTheme
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
