import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/domain/enums/edit_flow.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:checklist_app/shared/models/checklist_category_model.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:checklist_app/shared/utils/dialog_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  final ChecklistMode mode;
  final String? checklistId;
  final ChecklistModel? checklist;
  final EditFlow editFlow;

  const AddCategoryScreen({
    super.key,
    required this.mode,
    this.checklistId,
    this.checklist,
    required this.editFlow,
  });

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {
  bool get _isEditMode => widget.mode == ChecklistMode.edit;

  @override
  void initState() {
    super.initState();

    // Only relevant for create mode — edit mode reads live from
    // checklistByIdProvider instead of the draft state.
    if (!_isEditMode && widget.checklist != null) {
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

  bool _isDuplicate(
    List<ChecklistCategory> categories,
    String value, {
    String? ignoreCategoryId,
  }) {
    return categories.any(
      (c) =>
          c.name.toLowerCase() == value.toLowerCase() &&
          c.id != (ignoreCategoryId ?? ''),
    );
  }

  // -------------------- ADD CATEGORY --------------------

  void addCategoryDialog(List<ChecklistCategory> categories, ChecklistModel? liveChecklist) {
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
                if (_isDuplicate(categories, trimmed)) {
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
                final notifier = ref.read(checklistControllerProvider.notifier);

                FocusScope.of(dialogContext).unfocus();
                await Future.delayed(const Duration(milliseconds: 100));

                if (_isEditMode && liveChecklist != null) {
                  // Edit mode: updates ONLY the categories array field on
                  // the existing checklist doc — no full-document rewrite.
                  await notifier.addCategoryToChecklist(
                    checklist: liveChecklist,
                    name: value,
                  );
                } else {
                  // Create mode: still local draft, written once at the end.
                  notifier.addCategory(value);
                }

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

  void editCategoryDialog(
    List<ChecklistCategory> categories,
    ChecklistCategory category,
    ChecklistModel? liveChecklist,
  ) {
    final TextEditingController controller =
        TextEditingController(text: category.name);
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
                if (_isDuplicate(categories, trimmed, ignoreCategoryId: category.id)) {
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
                final notifier = ref.read(checklistControllerProvider.notifier);

                FocusScope.of(dialogContext).unfocus();
                await Future.delayed(const Duration(milliseconds: 100));

                if (_isEditMode && liveChecklist != null) {
                  // Rename = ONE field update on the categories array —
                  // items reference categoryId, so they're never touched.
                  await notifier.renameCategoryInChecklist(
                    checklist: liveChecklist,
                    categoryId: category.id,
                    newName: value,
                  );
                } else {
                  notifier.updateCategory(categoryId: category.id, newName: value);
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

  void deleteCategoryDialog(ChecklistCategory category, ChecklistModel? liveChecklist) {
    showBlurDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: Text(
            "Delete '${category.name}'? All items inside it will be removed too.",
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
              onPressed: () async {
                final notifier = ref.read(checklistControllerProvider.notifier);

                if (_isEditMode && liveChecklist != null) {
                  await notifier.removeCategoryFromChecklist(
                    checklist: liveChecklist,
                    categoryId: category.id,
                  );
                } else {
                  notifier.removeCategory(category.id);
                }

                if (dialogContext.mounted) Navigator.pop(dialogContext);
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (_isEditMode) {
      // ---- Guard: edit mode requires a checklistId ----
      if (widget.checklistId == null || widget.checklistId!.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text("Edit Checklist")),
          body: const Center(
            child: Text("Something went wrong — checklist ID is missing."),
          ),
        );
      }

      final checklistAsync =
          ref.watch(checklistByIdProvider(widget.checklistId!));

      return checklistAsync.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) =>
            Scaffold(body: Center(child: Text(error.toString()))),
        data: (checklist) => _buildScaffold(
          context,
          categories: checklist.categories,
          liveChecklist: checklist,
        ),
      );
    }

    final categories = ref.watch(checklistControllerProvider).categories;
    return _buildScaffold(context, categories: categories, liveChecklist: null);
  }

  Widget _buildScaffold(
    BuildContext context, {
    required List<ChecklistCategory> categories,
    required ChecklistModel? liveChecklist,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isEditMode ? "Edit Checklist" : "Create Checklist"),
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
                    : buildCategoryList(categories, liveChecklist),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Category"),
                  onPressed: () => addCategoryDialog(categories, liveChecklist),
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
                              if (_isEditMode &&
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
                                  'editFlow': widget.editFlow,
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

  Widget buildCategoryList(
    List<ChecklistCategory> categories,
    ChecklistModel? liveChecklist,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () =>
                      editCategoryDialog(categories, category, liveChecklist),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.edit_outlined, size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => deleteCategoryDialog(category, liveChecklist),
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