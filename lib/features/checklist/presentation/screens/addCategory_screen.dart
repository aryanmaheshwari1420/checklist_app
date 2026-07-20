import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:checklist_app/shared/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final ChecklistMode mode;
  final String? checklistId;
  final ChecklistModel? checklist;

  const AddCategoryScreen({
    super.key,
    required this.mode,
    this.checklistId,
    this.checklist,
  });

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.checklist != null) {
      Future.microtask(() {
        if (!mounted) return;

        final currentState = ref.read(checklistControllerProvider);

        if (currentState.categories.isEmpty) {
          ref
              .read(checklistControllerProvider.notifier)
              .loadChecklist(widget.checklist!);
        }
      });
    }
  }

  List<String> get categories =>
      ref.read(checklistControllerProvider).categories;

  bool _isDuplicate(String value, {String? ignoreExisting}) {
    return categories.any(
      (c) =>
          c.toLowerCase() == value.toLowerCase() &&
          c.toLowerCase() != (ignoreExisting?.toLowerCase() ?? ''),
    );
  }

  // -------------------- ADD CATEGORY --------------------

  void addCategoryDialog() {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showBlurDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Add Category"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 30,
              decoration: const InputDecoration(hintText: "e.g., Groceries"),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return "Category name can't be empty";
                if (_isDuplicate(trimmed)) {
                  return "This category already exists";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                FocusScope.of(dialogContext).unfocus();
                await Future.delayed(const Duration(milliseconds: 100));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final value = controller.text.trim();

                FocusScope.of(dialogContext).unfocus();
                await Future.delayed(const Duration(milliseconds: 100));

                ref
                    .read(checklistControllerProvider.notifier)
                    .addCategory(value);

                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // -------------------- EDIT CATEGORY --------------------

  void editCategory(int index) {
    // ---- Guard: index out of range (list could've changed) ----
    if (index < 0 || index >= categories.length) return;

    final originalName = categories[index];
    final TextEditingController controller =
        TextEditingController(text: originalName);
    final formKey = GlobalKey<FormState>();

    showBlurDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Edit Category"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 30,
              decoration: const InputDecoration(hintText: "e.g., Work"),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return "Category name can't be empty";
                if (_isDuplicate(trimmed, ignoreExisting: originalName)) {
                  return "This category already exists";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                FocusScope.of(dialogContext).unfocus();
                await Future.delayed(const Duration(milliseconds: 100));
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final value = controller.text.trim();

                FocusScope.of(dialogContext).unfocus();
                await Future.delayed(const Duration(milliseconds: 100));

                // ---- Guard: category might've been deleted while dialog was open ----
                if (categories.contains(originalName)) {
                  ref
                      .read(checklistControllerProvider.notifier)
                      .updateCategory(oldName: originalName, newName: value);
                }

                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // -------------------- DELETE CATEGORY --------------------

  void deleteCategory(int index) {
    // ---- Guard: index out of range ----
    if (index < 0 || index >= categories.length) return;

    final categoryName = categories[index];

    showBlurDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: Text(
            "Delete '$categoryName'? All items inside it will be removed too.",
          ),
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
                // ---- Guard: category might've already been removed ----
                if (categories.contains(categoryName)) {
                  ref
                      .read(checklistControllerProvider.notifier)
                      .removeCategory(categoryName);
                }

                Navigator.pop(dialogContext);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(checklistControllerProvider).categories;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.mode == ChecklistMode.create
              ? "Create Checklist"
              : "Edit Checklist",
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Add Categories", style: textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                "You can add multiple categories\none by one.",
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: categories.isEmpty
                    ? buildEmptyState()
                    : buildCategoryList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Category"),
                  onPressed: () {
                    addCategoryDialog();
                  },
                ),
              ),
              const SizedBox(height: 25),
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
                      onPressed: categories.isEmpty
                          ? null
                          : () {
                              // ---- Guard: create mode requires no checklistId,
                              // edit mode requires one. Only block edit mode
                              // if it's unexpectedly missing. ----
                              if (widget.mode == ChecklistMode.edit &&
                                  (widget.checklistId == null ||
                                      widget.checklistId!.isEmpty)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Something went wrong — checklist ID is missing.",
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              Navigator.pushNamed(
                                context,
                                AppRoutes.addItems,
                                arguments: {
                                  'mode': widget.mode,
                                  'checklistId': widget.checklistId,
                                },
                              );
                            },
                      child: const Text("Next"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 80,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 20),
          Text("No Categories Yet", style: textTheme.headlineSmall),
          const SizedBox(height: 10),
          Text(
            "Create your first category.",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryList() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    categories[index],
                    style: textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => editCategory(index),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined, size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => deleteCategory(index),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline,
                      size: 22,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}