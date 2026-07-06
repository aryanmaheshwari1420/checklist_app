import 'package:checklist_app/features/auth/presentation/screens/check_list_screens/Sucesssceen.dart';
import 'package:flutter/material.dart';

class AddITemCategoryScreen extends StatefulWidget {
  final List<String> categories;

  const AddITemCategoryScreen({super.key, required this.categories});

  @override
  State<AddITemCategoryScreen> createState() => _AddITemCategoryScreenState();
}

class _AddITemCategoryScreenState extends State<AddITemCategoryScreen> {
  void editItemDialog(String category, int index) {
    final controller = TextEditingController(
      text: categoryItems[category]![index]["title"],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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
                setState(() {
                  categoryItems[category]![index]["title"] = controller.text
                      .trim();
                });

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

  void deleteItem(String category, int index) {
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
              setState(() {
                categoryItems[category]!.removeAt(index);
              });

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
                  setState(() {
                    categoryItems[category]!.add({
                      "title": value,
                      "checked": false,
                    });
                  });
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

  late Map<String, List<Map<String, dynamic>>> categoryItems;

  @override
  void initState() {
    super.initState();

    categoryItems = {};

    for (var category in widget.categories) {
      categoryItems[category] = [];
    }
  }

  @override
  Widget build(BuildContext context) {
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
                itemCount: widget.categories.length,

                itemBuilder: (context, index) {
                  final category = widget.categories[index];

                  final items = categoryItems[category]!;

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
                        "$category (${items.length})",

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,

                          color: Color(0xff5B3DF5),
                        ),
                      ),

                      children: [
                        if (items.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 15),

                            child: Text(
                              "No Items Added",

                              style: TextStyle(color: Colors.grey),
                            ),
                          ),

                        ...items.asMap().entries.map((entry) {
                          int itemIndex = entry.key;

                          Map<String, dynamic> item = entry.value;

                          return ListTile(
                            leading: Checkbox(
                              value: item["checked"],
                              activeColor: const Color(0xff5B3DF5),
                              onChanged: (value) {
                                setState(() {
                                  items[itemIndex]["checked"] = value!;
                                });
                              },
                            ),

                            title: Text(item["title"]),

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
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SuccessScreen(),
                        ),
                      );
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
