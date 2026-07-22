import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/domain/enums/edit_flow.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_items_provider.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:checklist_app/shared/models/ChecklistItemModel%20.dart';
import 'package:checklist_app/shared/models/checklist_category_model.dart';
import 'package:checklist_app/shared/utils/dialog_utils.dart';
import 'package:checklist_app/shared/widgets/error_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddItemCategoryScreen extends ConsumerStatefulWidget {
  final ChecklistMode mode;
  final String? checklistId;
  final EditFlow editFlow;

  const AddItemCategoryScreen({
    super.key,
    required this.mode,
    this.checklistId,
    required this.editFlow,
  });

  @override
  ConsumerState<AddItemCategoryScreen> createState() =>
      _AddItemCategoryScreenState();
}

class _AddItemCategoryScreenState extends ConsumerState<AddItemCategoryScreen> {
  bool _isSubmitting = false;

  bool get _isEditMode => widget.mode == ChecklistMode.edit;

  // =================================================================
  // CREATE MODE — draft state, single batch write at the end
  // =================================================================

  Future<void> _handleCreateSubmit() async {
    if (_isSubmitting) return;

    final state = ref.read(checklistControllerProvider);

    if (state.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one category before continuing."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    String? checklistId;

    await ErrorHandler.run(
      context: context,
      action: () async {
        final controller = ref.read(checklistControllerProvider.notifier);
        checklistId = await controller.createChecklist();
      },
      onSuccess: () {
        if (!mounted) return;

        if (checklistId == null || checklistId!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                "Failed to create checklist. Please try again.",
              ),
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
      },
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  // Draft (create-mode) item operations are pure local state mutations on
  // the controller — no async/Firestore call, so no try/catch is needed
  // here. They're intentionally NOT wrapped in ErrorHandler.run.

  void _addDraftItemDialog(String categoryId, String categoryName) {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showBlurDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Add Item to $categoryName"),
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
                    ref.read(checklistControllerProvider).items[categoryId] ??
                    [];
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
                    .addItem(categoryId: categoryId, title: value);

                Navigator.pop(dialogContext);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _editDraftItemDialog(String categoryId, ChecklistItemModel oldItem) {
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
                  ref.read(checklistControllerProvider).items[categoryId] ?? [];
              final isDuplicate = currentItems.any(
                (e) =>
                    e.id != oldItem.id &&
                    e.title.toLowerCase() == trimmed.toLowerCase(),
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

              ref.read(checklistControllerProvider.notifier).updateItem(
                categoryId: categoryId,
                oldItem: oldItem,
                newItem: oldItem.copyWith(
                  title: controller.text.trim(),
                ),
              );

              Navigator.pop(dialogContext);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _deleteDraftItemDialog(String categoryId, ChecklistItemModel item) {
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
                  .removeItem(categoryId: categoryId, item: item);
              Navigator.pop(dialogContext);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // =================================================================
  // EDIT MODE — each op writes directly to Firestore (per-item),
  // no draft batching involved.
  // =================================================================

  void _addLiveItemDialog(
    String checklistId,
    String categoryId,
    String categoryName,
    int nextOrder,
  ) {
    final TextEditingController controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showBlurDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Text("Add Item to $categoryName"),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                autofocus: true,
                maxLength: 60,
                enabled: !isSubmitting,
                decoration: const InputDecoration(hintText: "Enter item name"),
                validator: (value) {
                  final trimmed = value?.trim() ?? '';
                  if (trimmed.isEmpty) return "Item name can't be empty";
                  return null;
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.pop(dialogContext),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => isSubmitting = true);

                        await ErrorHandler.run(
                          context: dialogContext,
                          action: () => ref
                              .read(checklistControllerProvider.notifier)
                              .addItemToChecklist(
                                checklistId: checklistId,
                                categoryId: categoryId,
                                title: controller.text.trim(),
                                order: nextOrder,
                              ),
                          onSuccess: () {
                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                            }
                          },
                        );

                        if (dialogContext.mounted) {
                          setDialogState(() => isSubmitting = false);
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _editLiveItemDialog(
    String checklistId,
    ChecklistItemModel item,
    List<ChecklistItemModel> categoryItems,
  ) {
    final controller = TextEditingController(text: item.title);
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showBlurDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text("Edit Item"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              maxLength: 60,
              enabled: !isSubmitting,
              decoration: const InputDecoration(hintText: "Enter item name"),
              validator: (value) {
                final trimmed = value?.trim() ?? '';

                if (trimmed.isEmpty) {
                  return "Item name can't be empty";
                }

                final normalized =
                    trimmed.replaceAll(RegExp(r'\s+'), ' ').trim();

                final isDuplicate = categoryItems.any(
                  (e) =>
                      e.id != item.id &&
                      e.title
                              .replaceAll(RegExp(r'\s+'), ' ')
                              .trim()
                              .toLowerCase() ==
                          normalized.toLowerCase(),
                );

                if (isDuplicate) {
                  return "An item with this name already exists";
                }

                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (!formKey.currentState!.validate()) return;
                      setDialogState(() => isSubmitting = true);

                      await ErrorHandler.run(
                        context: dialogContext,
                        action: () => ref
                            .read(checklistControllerProvider.notifier)
                            .updateItemTitle(
                              checklistId: checklistId,
                              itemId: item.id,
                              title: controller.text.trim(),
                            ),
                        onSuccess: () {
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                      );

                      if (dialogContext.mounted) {
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteLiveItemDialog(String checklistId, ChecklistItemModel item) {
    bool isSubmitting = false;

    showBlurDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text("Delete Item"),
          content: const Text("Are you sure you want to delete this item?"),
          actions: [
            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      setDialogState(() => isSubmitting = true);

                      await ErrorHandler.run(
                        context: dialogContext,
                        action: () => ref
                            .read(checklistControllerProvider.notifier)
                            .deleteItemFromChecklist(
                              checklistId: checklistId,
                              itemId: item.id,
                              wasChecked: item.checked,
                            ),
                        onSuccess: () {
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                      );

                      if (dialogContext.mounted) {
                        setDialogState(() => isSubmitting = false);
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Delete"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEditSubmit() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    await ErrorHandler.run(
      context: context,
      action: () async {
        // Items were already saved live as the user interacted with them.
        // This only needs to persist any metadata changes made earlier in
        // the wizard (title/description/type/priority/notes) — still a
        // single lightweight metadata-only write, no items touched.
        if (widget.editFlow == EditFlow.full) {
          await ref
              .read(checklistControllerProvider.notifier)
              .updateChecklist();
        }
      },
      onSuccess: () {
        if (!mounted) return;

        ref.invalidate(dashboardProvider);

        Navigator.pushReplacementNamed(
          context,
          AppRoutes.success,
          arguments: {"checklistId": widget.checklistId, "mode": widget.mode},
        );
      },
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope now wraps the entire screen — the missing-ID error state,
    // the loading/error states of the async providers, and the main
    // scaffold — so a back-swipe/press is blocked consistently by
    // _isSubmitting no matter which branch is currently showing.
    return PopScope(
      canPop: !_isSubmitting,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please wait while your changes are being saved."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isEditMode) {
      if (widget.checklistId == null || widget.checklistId!.isEmpty) {
        return Scaffold(
          appBar: AppBar(title: const Text("Edit Checklist")),
          body: const Center(
            child: Text("Something went wrong — checklist ID is missing."),
          ),
        );
      }

      final checklistAsync = ref.watch(
        checklistByIdProvider(widget.checklistId!),
      );
      final itemsAsync = ref.watch(checklistItemsProvider(widget.checklistId!));

      return checklistAsync.when(
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, _) =>
            Scaffold(body: Center(child: Text(error.toString()))),
        data: (checklist) => itemsAsync.when(
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, _) =>
              Scaffold(body: Center(child: Text(error.toString()))),
          data: (liveItems) {
            final itemsByCategoryId = <String, List<ChecklistItemModel>>{};
            for (final item in liveItems) {
              itemsByCategoryId
                  .putIfAbsent(item.categoryId, () => [])
                  .add(item);
            }
            return _buildScaffold(
              categories: checklist.categories,
              itemsByCategoryId: itemsByCategoryId,
            );
          },
        ),
      );
    }

    final state = ref.watch(checklistControllerProvider);
    return _buildScaffold(
      categories: state.categories,
      itemsByCategoryId: state.items,
    );
  }

  Widget _buildScaffold({
    required List<ChecklistCategory> categories,
    required Map<String, List<ChecklistItemModel>> itemsByCategoryId,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(_isEditMode ? "Edit Checklist" : "Create Checklist"),
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
                        final categoryItemList =
                            itemsByCategoryId[category.id] ?? [];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: ExpansionTile(
                            initiallyExpanded: index == 0,
                            title: Text(
                              "${category.name} (${categoryItemList.length})",
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
                              ...categoryItemList.map((item) {
                                return CheckboxListTile(
                                  contentPadding: const EdgeInsets.only(
                                    left: 8,
                                    right: 8,
                                  ),
                                  value: item.checked,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  onChanged: (value) async {
                                    // Tri-state checkboxes can report `null`
                                    // (e.g. tristate widgets, platform edge
                                    // cases) — bail out instead of silently
                                    // coercing that into `false`.
                                    if (value == null) return;

                                    if (_isEditMode) {
                                      await ErrorHandler.run(
                                        context: context,
                                        action: () => ref
                                            .read(
                                              checklistControllerProvider
                                                  .notifier,
                                            )
                                            .toggleItemChecked(
                                              checklistId: widget.checklistId!,
                                              itemId: item.id,
                                              checked: value,
                                            ),
                                      );
                                    } else {
                                      ref
                                          .read(
                                            checklistControllerProvider
                                                .notifier,
                                          )
                                          .updateItem(
                                            categoryId: category.id,
                                            oldItem: item,
                                            newItem: item.copyWith(
                                              checked: value,
                                            ),
                                          );
                                    }
                                  },
                                  title: Text(item.title),
                                  secondary: PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    iconSize: 22,
                                    onSelected: (value) {
                                      if (value == "edit") {
                                        _isEditMode
                                            ? _editLiveItemDialog(
                                                widget.checklistId!,
                                                item,
                                                categoryItemList,
                                              )
                                            : _editDraftItemDialog(
                                                category.id,
                                                item,
                                              );
                                      } else {
                                        _isEditMode
                                            ? _deleteLiveItemDialog(
                                                widget.checklistId!,
                                                item,
                                              )
                                            : _deleteDraftItemDialog(
                                                category.id,
                                                item,
                                              );
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
                                  _isEditMode
                                      ? _addLiveItemDialog(
                                          widget.checklistId!,
                                          category.id,
                                          category.name,
                                          categoryItemList.length,
                                        )
                                      : _addDraftItemDialog(
                                          category.id,
                                          category.name,
                                        );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: colorScheme.primary,
                                      ),
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
                    onPressed: _isSubmitting
                        ? null
                        : (_isEditMode
                              ? _handleEditSubmit
                              : _handleCreateSubmit),
                    child: _isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : Text(_isEditMode ? "Save Changes" : "Create"),
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