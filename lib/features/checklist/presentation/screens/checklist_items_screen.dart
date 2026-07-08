import 'package:checklist_app/features/checklist/presentation/screens/success_screen.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddITemCategoryScreen extends ConsumerStatefulWidget {
  const AddITemCategoryScreen({super.key});

  @override
  ConsumerState<AddITemCategoryScreen> createState() =>
      _AddITemCategoryScreenState();
}

class _AddITemCategoryScreenState extends ConsumerState<AddITemCategoryScreen> {
  void editItemDialog(String category, int index) {
    final items = ref.read(checklistControllerProvider).items[category] ?? [];

    final oldItem = items[index];

    final controller = TextEditingController(text: oldItem.title);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Item"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff5B3DF5),
            ),
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
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void deleteItem(String category, int index) {
    final items = ref.read(checklistControllerProvider).items[category] ?? [];
    final item = items[index];

    showDialog(
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref
                  .read(checklistControllerProvider.notifier)
                  .removeItem(category: category, item: item);

              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void addItemDialog(String category) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff5B3DF5),
              ),
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  ref
                      .read(checklistControllerProvider.notifier)
                      .addItem(category: category, item: value);
                }

                Navigator.pop(context);
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checklistControllerProvider);

    final categories = state.categories;

    final items = state.items;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: Colors.white,

        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Create Checklist",

          style: TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Add Items in Categories",

              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Add checklist items for each category.",

              style: TextStyle(color: Colors.grey),
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

                  return Container(
                    margin: const EdgeInsets.only(bottom: 15),

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(14),

                      border: Border.all(color: Colors.grey.shade300),
                    ),

                    child: ExpansionTile(
                      initiallyExpanded: index == 0,

                      title: Text(
                        "$category (${categoryItemList.length})",

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,

                          color: Color(0xff5B3DF5),
                        ),
                      ),

                      children: [
                        if (categoryItemList.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 15),

                            child: Text(
                              "No Items Added",

                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                        ...categoryItemList.asMap().entries.map((entry) {
                          int itemIndex = entry.key;

                          final ChecklistItem item = entry.value;

                          return ListTile(
                            leading: Checkbox(
                              value: item.checked,
                              activeColor: const Color(0xff5B3DF5),
                              onChanged: (value) {
                                // Update through the notifier instead of
                                // setState mutating a local list — the
                                // provider is the single source of truth,
                                // and ref.watch above already rebuilds
                                // this widget when it changes.
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
                            ),

                            title: Text(item.title),

                            trailing: PopupMenuButton<String>(
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

                          child: const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),

                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Icon(Icons.add, color: Color(0xff5B3DF5)),

                                SizedBox(width: 6),

                                Text(
                                  "Add Item",

                                  style: TextStyle(
                                    color: Color(0xff5B3DF5),

                                    fontWeight: FontWeight.bold,
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
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    child: const Text("Back"),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5B3DF5),
                    ),
                    onPressed: () async {
                      final checklistId = await ref
                          .read(checklistControllerProvider.notifier)
                          .createChecklist();

                      if (!mounted) return;

                      if (checklistId != null) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                SuccessScreen(checklistId: checklistId),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Failed to create checklist. Please try again.",
                            ),
                          ),
                        );
                      }
                    },

                    child: const Text(
                      "Create",

                      style: TextStyle(color: Colors.white),
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
