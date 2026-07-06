import 'package:flutter/material.dart';

class CreateChecklistScreen extends StatefulWidget {
  const CreateChecklistScreen({super.key});

  @override
  State<CreateChecklistScreen> createState() =>
      _CreateChecklistScreenState();
}

class _CreateChecklistScreenState
    extends State<CreateChecklistScreen> {

  final TextEditingController nameController =
      TextEditingController(text: "Travel Insurance");

  final TextEditingController descriptionController =
      TextEditingController(
        text: "Checklist for travel insurance\nbefore Bali trip.",
      );

  bool linkTransaction = false;

  String selectedCategory = "Travel";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Create Checklist",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Checklist Name*",
              style: TextStyle(
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: nameController,
              decoration: inputDecoration(),
            ),

            const SizedBox(height: 20),

            const Text(
              "Description (Optional)",
              style: TextStyle(
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: inputDecoration(),
            ),

            const SizedBox(height: 20),

            const Text(
              "Category*",
              style: TextStyle(
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategory,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: const [
                    DropdownMenuItem(
                      value: "Travel",
                      child: Row(
                        children: [
                          Icon(Icons.flight_takeoff,
                              color: Colors.deepPurple),
                          SizedBox(width: 10),
                          Text("Travel"),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: "Shopping",
                      child: Text("Shopping"),
                    ),
                    DropdownMenuItem(
                      value: "Work",
                      child: Text("Work"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Use Template (Optional)",
              style: TextStyle(
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.grey.shade300),
              ),
              child: Row(
                children: [

                  const Icon(Icons.description_outlined,
                      color: Colors.deepPurple),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      "Travel Insurance Template",
                      style: TextStyle(fontSize: 15),
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text("Change"),
                  )
                ],
              ),
            ),

            const SizedBox(height: 25),

            Row(
              children: [

                const Expanded(
                  child: Text(
                    "Link to Transaction (Optional)",
                    style: TextStyle(
                        fontWeight: FontWeight.bold),
                  ),
                ),

                Switch(
                  value: linkTransaction,
                  activeColor: Colors.deepPurple,
                  onChanged: (value) {
                    setState(() {
                      linkTransaction = value;
                    });
                  },
                )
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xff5B3DF5),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Create",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Row(
                children: [

                  Icon(Icons.lightbulb_outline,
                      color: Colors.deepPurple),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      "User creates a new checklist manually or using a template.",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
            color: Colors.deepPurple),
      ),
    );
  }
}