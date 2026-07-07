import 'package:checklist_app/features/checklist/presentation/screens/category_selection_screen.dart';
import 'package:checklist_app/features/checklist/presentation/screens/create_checklist_screen.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoreDetailScreen extends ConsumerStatefulWidget {
  const MoreDetailScreen({super.key});

  @override
  ConsumerState<MoreDetailScreen> createState() => _MoreDetailScreenState();
}

class _MoreDetailScreenState extends ConsumerState<MoreDetailScreen> {
  final TextEditingController notesController = TextEditingController();

  final List<String> categories = [
    "Travel",
    "Personal",
    "Work",
    "Shopping",
    "Finance",
    "Health"
  ];

  String selectedCategory = "Travel";

  String selectedPriority = "Medium";

  bool reminder = false;

  DateTime? reminderDate;

  TimeOfDay? reminderTime;

  @override
  void initState() {
    super.initState();

    final checklist =  ref.read(checklistControllerProvider);

    if(checklist.category.isNotEmpty){
      selectedCategory = checklist.category;
    }

    selectedPriority = checklist.priority;
    reminder = checklist.reminderEnabled;
    reminderDate = checklist.reminderDateTime;

    if(checklist.reminderDateTime!=null){
      reminderTime = TimeOfDay.fromDateTime(checklist.reminderDateTime!);
    }
    notesController.text = checklist.notes;
  }
  @override
void dispose() {
  notesController.dispose();
  super.dispose();
}

  Future<void> pickReminderDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        if (reminderTime != null) {
  reminderDate = DateTime(
    date.year,
    date.month,
    date.day,
    reminderTime!.hour,
    reminderTime!.minute,
  );
} else {
  reminderDate = date;
}
      });
    }
  }

  Future<void> pickReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        reminderTime = time;

if (reminderDate != null) {
  reminderDate = DateTime(
    reminderDate!.year,
    reminderDate!.month,
    reminderDate!.day,
    time.hour,
    time.minute,
  );
}
      });
    }
  }

  Widget buildPriorityChip(String value) {
    final selected = selectedPriority == value;

    return ChoiceChip(
      label: Text(value),
      selected: selected,
      selectedColor: const Color(0xff5B3DF5), 
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontWeight: FontWeight.w600,
      ),
      onSelected: (_) {
        setState(() {
          selectedPriority = value;
        });
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          "Create Checklist",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "Step 2 of 4",
                  style: TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: 0.5,
                minHeight: 6,
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xff5B3DF5),
                backgroundColor: Colors.grey.shade300,
              ),

              const SizedBox(height: 35),

              const Text(
                "Category",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "Priority",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                children: [
                  buildPriorityChip("Low"),
                  buildPriorityChip("Medium"),
                  buildPriorityChip("High"),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                children: [

                  const Expanded(
                    child: Text(
                      "Reminder",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  Switch(
                    value: reminder,
                    activeThumbColor: const Color(0xff5B3DF5),
                    onChanged: (value) {
                      setState(() {
                        reminder = value;
                      });
                    },
                  ),
                ],
              ),

              if (reminder) ...[
                const SizedBox(height: 20),

                InkWell(
                  onTap: pickReminderDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [

                        const Icon(Icons.calendar_today),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            reminderDate == null
                                ? "Select Reminder Date"
                                : "${reminderDate!.day}/${reminderDate!.month}/${reminderDate!.year}",
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                InkWell(
                  onTap: pickReminderTime,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [

                        const Icon(Icons.access_time),

                        const SizedBox(width: 15),

                        Expanded(
                          child: Text(
                            reminderTime == null
                                ? "Select Reminder Time"
                                : reminderTime!.format(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 25),

              const Text(
                "Notes (Optional)",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              TextField(
                controller: notesController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: "Add additional notes...",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 45),

              Row(
                children: [

                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CreateCheckListScreen(),
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
                        minimumSize: const Size(0, 55),
                        backgroundColor:
                            const Color(0xff5B3DF5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {


                        ref.read(checklistControllerProvider.notifier).updateDetails(
                          category: selectedCategory,
                          priority: selectedPriority,
                          reminderEnabled: reminder,
                          reminderDateTime: reminderDate,
                          notes: notesController.text.trim(),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AddCategoryScreen(),
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}