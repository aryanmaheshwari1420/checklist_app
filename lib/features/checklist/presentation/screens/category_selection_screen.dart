import 'package:checklist_app/features/checklist/presentation/screens/checklist_items_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/checklist_details_screen.dart';
import 'package:checklist_app/features/checklist/providers/checklist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddCategoryScreen extends ConsumerStatefulWidget {
  const AddCategoryScreen({super.key});

  @override
  ConsumerState<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends ConsumerState<AddCategoryScreen> {

  List<String> get categories => ref.read(checklistControllerProvider).categories;


  // -------------------- ADD CATEGORY --------------------

  void addCategoryDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Add Category"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Enter category name"),
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
                  // setState(() {
                  //   categories.add(value);
                  // }
                  // );
                  ref
                      .read(checklistControllerProvider.notifier)
                      .addCategory(value);
                }

                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Edit Category"),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Category name"),
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
                  // setState(() {
                  //   categories[index] = value;
                  // });

                  ref
    .read(checklistControllerProvider.notifier)
    .updateCategory(
      oldName: categories[index],
      newName: value,
    );
                }

                Navigator.pop(context);
              },
              child: const Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------- DELETE CATEGORY --------------------

  void deleteCategory(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Delete Category"),
          content: Text("Delete '${categories[index]}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                setState(() {
                  // categories.removeAt(index);

                  ref
    .read(checklistControllerProvider.notifier)
    .removeCategory(
      categories[index],
    );
                });

                Navigator.pop(context);
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
  }


  @override
  Widget build(BuildContext context) {

    final categories = ref.watch(checklistControllerProvider).categories;
     
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,

        elevation: 0,

        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "Create Checklist",

          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Text(
                "Add Categories",

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                "You can add multiple categories\none by one.",

                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),

              const SizedBox(height: 25),

              Expanded(
                child: categories.isEmpty
                    ? buildEmptyState()
                    : buildCategoryList(),
              ),

              SizedBox(
                width: double.infinity,

                height: 52,

                child: OutlinedButton.icon(
                  icon: const Icon(Icons.add, color: Color(0xff5B3DF5)),

                  label: const Text(
                    "Add Category",

                    style: TextStyle(
                      color: Color(0xff5B3DF5),

                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  onPressed: () {
                    addCategoryDialog();
                  },

                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(
                          context,

                          MaterialPageRoute(
                            builder: (_) => const MoreDetailScreen(),
                          ),
                        );
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

                      onPressed: categories.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddITemCategoryScreen(),
                                ),
                              );
                            },

                      child: const Text(
                        "Next",

                        style: TextStyle(color: Colors.white),
                      ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(Icons.folder_open, size: 80, color: Colors.grey.shade400),

          const SizedBox(height: 20),

          const Text(
            "No Categories Yet",

            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const Text(
            "Create your first category.",

            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryList() {
    return ListView.builder(
      itemCount: categories.length,

      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          child: ListTile(
            title: Text(
              categories[index],

              style: const TextStyle(fontWeight: FontWeight.w500),
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
                  icon: const Icon(Icons.delete_outline, color: Colors.red),

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
