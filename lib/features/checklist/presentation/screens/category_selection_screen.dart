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
    this.checklist
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

  // -------------------- ADD CATEGORY --------------------

  void addCategoryDialog() {
    final TextEditingController controller = TextEditingController();

    showBlurDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Category"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "e.g., Groceries"),
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
                      .addCategory(value);
                }

                Navigator.pop(context);
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
    final TextEditingController controller = TextEditingController(
      text: categories[index],
    );

    showBlurDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Category"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "e.g., Work"),
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
                      .updateCategory(
                        oldName: categories[index],
                        newName: value,
                      );
                }

                Navigator.pop(context);
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
    showBlurDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Category"),
          content: Text("Delete '${categories[index]}'?"),
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
                setState(() {
                  ref
                      .read(checklistControllerProvider.notifier)
                      .removeCategory(categories[index]);
                });

                Navigator.pop(context);
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
      // Scaffold and AppBar are now styled by the global theme
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Create Checklist",
          // Style is inherited from appBarTheme.titleTextStyle
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Categories",
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                "You can add multiple categories\none by one.",
                style: textTheme.bodyLarge
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
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
                // This button is now styled by the theme's `outlinedButtonTheme`
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
                    // This button is now styled by the theme's `outlinedButtonTheme`
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    // This button is now styled by the theme's `elevatedButtonTheme`
                    child: ElevatedButton(
                      onPressed: categories.isEmpty
                          ? null
                          : () {
                              Navigator.pushNamed(context, AppRoutes.addItems,
                                  arguments: {
                                    'mode': widget.mode,
                                    'checklistId': widget.checklistId,
                                  });
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
          Icon(Icons.folder_open_outlined,
              size: 80, color: colorScheme.onSurface.withOpacity(0.4)),
          const SizedBox(height: 20),
          Text(
            "No Categories Yet",
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(
            "Create your first category.",
            style: textTheme.bodyLarge
                ?.copyWith(color: colorScheme.onSurfaceVariant),
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
          // The Card is now styled by the theme's `cardTheme`
          child: ListTile(
            title: Text(
              categories[index],
              style: textTheme.titleMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    editCategory(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: () {
                    deleteCategory(index);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
