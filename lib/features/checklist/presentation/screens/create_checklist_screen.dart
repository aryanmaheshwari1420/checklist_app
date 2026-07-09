import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_repository_provider.dart';
import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateCheckListScreen extends ConsumerStatefulWidget {
  final String? checklistId;
  final ChecklistMode mode;
  final bool showSkip;

  const CreateCheckListScreen({
    super.key,
    this.mode = ChecklistMode.create,
    this.checklistId,
    this.showSkip = false,
  });

  @override
  ConsumerState<CreateCheckListScreen> createState() =>
      _CreateCheckListScreenState();
}

class _CreateCheckListScreenState extends ConsumerState<CreateCheckListScreen> {
  final _formkey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? selectedDate;

  Future<void> pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      initialDate: selectedDate ?? DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  String get formattedDate {
    if (selectedDate == null) {
      return "Select Due Date";
    }

    return "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}";
  }

  @override
  void initState() {
    super.initState();

    if (widget.mode == ChecklistMode.edit) {
      Future.microtask(() async {
        await loadChecklist();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        title: Text(
          widget.mode == ChecklistMode.create
              ? "Create Checklist"
              : "Edit Checklist",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: widget.showSkip
            ? [
                TextButton(
                  onPressed: () {
                    ref.read(checklistControllerProvider.notifier).clear();

                    ref.invalidate(dashboardProvider);
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.dashboard,
                      (routes) => false,
                    );
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                ),
              ]
            : null,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: Colors.deepPurple,
                      size: 45,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    widget.mode == ChecklistMode.create
                        ? "Let's create a new checklist"
                        : "Edit Checklist",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    widget.mode == ChecklistMode.create
                        ? "Fill in the basic details to get started."
                        : "Update your checklist information.",
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  "Checklist Name *",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Checklist name is required";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: "Bali Trip",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  "Description (Optional)",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Checklist for our Bali trip preparation.",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  "Due Date",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 8),

                InkWell(
                  onTap: pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            formattedDate,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),

                        const Icon(Icons.calendar_today_outlined),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff5B3DF5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      if (_formkey.currentState!.validate()) {
                        ref
                            .read(checklistControllerProvider.notifier)
                            .updateBasicInfo(
                              title: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              dueDate: selectedDate,
                            );

                        Navigator.pushNamed(
                          context,
                          AppRoutes.checklistDetails,
                        );
                      }
                    },
                    child: Text(
                      widget.mode == ChecklistMode.create ? "Next" : "Save",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> loadChecklist() async {
    final checklist = await ref
        .read(checklistRepositoryProvider)
        .getChecklistById(widget.checklistId!);

    ref.read(checklistControllerProvider.notifier).loadChecklist(checklist);
  
      if (!mounted) return;


    setState(() {
      nameController.text = checklist.title;
      descriptionController.text = checklist.description;
      selectedDate = checklist.dueDate;
    });
  }
}


// Why Future.microtask?

// Because ref.read() directly initState me state update karega. Riverpod recommends scheduling it after initialization to avoid lifecycle issues.