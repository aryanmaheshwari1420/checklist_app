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
  bool _isSubmitting = false;

  /// Returns true if the checklist has at least one category with at least
  /// one item — prevents submitting a completely empty checklist.
  bool _hasAnyItems(Map<String, List<ChecklistItem>> items) {
    return items.values.any((list) => list.isNotEmpty);
  }

  Future<void> _handleSubmit() async {
    final state = ref.read(checklistControllerProvider);

    // ---- Validation: don't allow submitting an empty checklist ----
    if (state.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one category before continuing."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!_hasAnyItems(state.items)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one item before continuing."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ---- Guard: edit mode requires a checklistId ----
    if (widget.mode == ChecklistMode.edit &&
        (widget.checklistId == null || widget.checklistId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Something went wrong — checklist ID is missing."),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isSubmitting) return; // prevent double taps just in case
    setState(() => _isSubmitting = true);

    try {
      final controller = ref.read(checklistControllerProvider.notifier);
      String? checklistId;

      if (widget.mode == ChecklistMode.create) {
        checklistId = await controller.createChecklist();
      } else {
        await controller.updateChecklist();
        checklistId = widget.checklistId;
      }

      if (!mounted) return;

      // ---- Guard: createChecklist() failed and returned null ----
      if (checklistId == null || checklistId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to create checklist. Please try again."),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ref.invalidate(dashboardProvider);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.success,
        arguments: {"checklistId": checklistId, "mode": widget.mode},
      );
    } catch (e) {
      debugPrint("CREATE/UPDATE CHECKLIST ERROR: $e");
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.mode == ChecklistMode.create
                ? "Failed to create checklist. Please try again."
                : "Failed to save changes. Please try again.",
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void editItemDialog(String category, int index) {
    final items = ref.read(checklistControllerProvider).items[category] ?? [];

    // ---- Guard: index out of range (item might've been removed already) ----
    if (index < 0 || index >= items.length) return;

    final oldItem = items[index];
    final controller = TextEditingController(text: oldItem.title);
    final formKey = GlobalKey<FormState>();

    showBlurDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Edit Item"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 60,
            decoration: const InputDecoration(hintText: "Enter item name"),
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (trimmed.isEmpty) return "Item name can't be empty";

              final currentItems =
                  ref.read(checklistControllerProvider).items[category] ?? [];

              final isDuplicate = currentItems.asMap().entries.any(
                    (e) =>
                        e.key != index &&
                        e.value.title.toLowerCase() == trimmed.toLowerCase(),
                  );

              if (isDuplicate) return "An item with this name already exists";

              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              final value = controller.text.trim();

              ref
                  .read(checklistControllerProvider.notifier)
                  .updateItem(
                    category: category,
                    oldItem: oldItem,
                    newItem: oldItem.copyWith(title: value),
                  );

              Navigator.pop(dialogContext);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void deleteItem(String category, int index) {
    final items = ref.read(checklistControllerProvider).items[category] ?? [];

    // ---- Guard: index out of range ----
    if (index < 0 || index >= items.length) return;

    final item = items[index];

    showBlurDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Item"),
        content: const Text("Are you sure you want to delete this item?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
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

              Navigator.pop(dialogContext);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void addItemDialog(String category) {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showBlurDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Add Item to $category"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 60,
              decoration: const InputDecoration(hintText: "Enter item name"),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return "Item name can't be empty";

                final currentItems =
                    ref.read(checklistControllerProvider).items[category] ?? [];

                final isDuplicate = currentItems.any(
                  (e) => e.title.toLowerCase() == trimmed.toLowerCase(),
                );

                if (isDuplicate) return "An item with this name already exists";

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final value = controller.text.trim();

                ref
                    .read(checklistControllerProvider.notifier)
                    .addItem(category: category, item: value);

                Navigator.pop(dialogContext);
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.mode == ChecklistMode.create
              ? "Create Checklist"
              : "Edit Checklist",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Add Items in Categories", style: textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              "Add checklist items for each category.",
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // ---- Guard: no categories at all (shouldn't normally happen,
            // since the previous screen requires at least one, but this
            // avoids a blank/broken screen if state gets cleared). ----
            Expanded(
              child: categories.isEmpty
                  ? Center(
                      child: Text(
                        "No categories found. Please go back and add one.",
                        textAlign: TextAlign.center,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final categoryItemList = items[category] ?? [];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: ExpansionTile(
                            initiallyExpanded: index == 0,
                            title: Text(
                              "$category (${categoryItemList.length})",
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                              ),
                            ),
                            children: [
                              if (categoryItemList.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 15),
                                  child: Text(
                                    "No Items Added",
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ...categoryItemList.asMap().entries.map((entry) {
                                int itemIndex = entry.key;
                                final ChecklistItem item = entry.value;

                                return CheckboxListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                  ),
                                  value: item.checked,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (value) {
                                    final updatedItem =
                                        item.copyWith(checked: value);

                                    ref
                                        .read(
                                          checklistControllerProvider.notifier,
                                        )
                                        .updateItem(
                                          category: category,
                                          oldItem: item,
                                          newItem: updatedItem,
                                        );
                                  },
                                  title: Text(item.title),
                                  secondary: PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    iconSize: 22,
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add,
                                          color: colorScheme.primary),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Add Item",
                                        style: textTheme.labelLarge?.copyWith(
                                          color: colorScheme.primary,
                                        ),
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
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    child: const Text("Back"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(
                            widget.mode == ChecklistMode.create
                                ? "Create"
                                : "Save Changes",
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