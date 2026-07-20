import 'package:checklist_app/app/app_routes.dart';
import 'package:checklist_app/features/checklist/domain/enums/checklist_status.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChecklistDetailScreen extends ConsumerStatefulWidget {
  final ChecklistMode mode;
  final String? checklistId;

  const ChecklistDetailScreen({super.key, required this.mode, this.checklistId});

  @override
  ConsumerState<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends ConsumerState<ChecklistDetailScreen> {
  final TextEditingController notesController = TextEditingController();

  final List<String> categories = [
    "Travel",
    "Personal",
    "Work",
    "Shopping",
    "Finance",
    "Split",
    "Charity",
    "Event",
    "Vehicle",
    "Vendor",
    "Health",
  ];

  String selectedType = "Travel";
  String selectedPriority = "Medium";
  bool reminder = false;
  DateTime? reminderDate;
  TimeOfDay? reminderTime;

  @override
  void initState() {
    super.initState();

    final checklist = ref.read(checklistControllerProvider);

    // ---- Guard: dropdown value must exist in the items list, otherwise
    // Flutter throws an assertion error when it can't find a matching item
    // (e.g. checklist came from a template with a custom/unknown type). ----
    if (checklist.type.isNotEmpty && categories.contains(checklist.type)) {
      selectedType = checklist.type;
    } else {
      selectedType = categories.first;
    }

    selectedPriority = checklist.priority.isNotEmpty
        ? checklist.priority
        : "Medium";
    reminder = checklist.reminderEnabled;
    reminderDate = checklist.reminderDateTime;

    if (checklist.reminderDateTime != null) {
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
      initialDate: reminderDate ?? DateTime.now(),
    );

    if (date != null && mounted) {
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
      initialTime: reminderTime ?? TimeOfDay.now(),
    );

    if (time != null && mounted) {
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
    final color = _priorityColor(value);

    return ChoiceChip(
      label: Text(value),
      selected: selected,
      onSelected: (_) {
        setState(() {
          selectedPriority = value;
        });
      },
      selectedColor: color.withOpacity(0.15),
      checkmarkColor: color,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: selected
            ? color
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: selected ? color : Theme.of(context).colorScheme.outline,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Color _priorityColor(String value) {
    switch (value.toLowerCase()) {
      case "low":
        return Colors.green;
      case "medium":
        return Colors.orange;
      case "high":
        return Colors.red;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  void _handleNext() {
    // ---- Guard: if reminder is ON, both date and time must be selected ----
    if (reminder && (reminderDate == null || reminderTime == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select both a reminder date and time."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // ---- Guard: reminder date/time shouldn't be in the past ----
    if (reminder &&
        reminderDate != null &&
        reminderDate!.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reminder date/time can't be in the past."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ref
        .read(checklistControllerProvider.notifier)
        .updateDetails(
          type: selectedType,
          priority: selectedPriority,
          reminderEnabled: reminder,
          reminderDateTime: reminder ? reminderDate : null,
          notes: notesController.text.trim(),
        );

    Navigator.pushNamed(
      context,
      AppRoutes.addCategories,
      arguments: {
        'mode': widget.mode,
        'checklistId': widget.checklistId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Step 2 of 4",
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: 0.5,
                minHeight: 6,
                borderRadius: BorderRadius.circular(20),
              ),
              const SizedBox(height: 35),
              Text("Type", style: textTheme.labelLarge),
              const SizedBox(height: 8),

              InputDecorator(
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedType,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(14),
                    elevation: 3,
                    dropdownColor: colorScheme.surfaceContainerHigh,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedType = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),
              Text("Priority", style: textTheme.labelLarge),
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
                  Expanded(
                    child: Text("Reminder", style: textTheme.titleMedium),
                  ),
                  Switch(
                    value: reminder,
                    onChanged: (value) {
                      setState(() {
                        reminder = value;
                        // Clear stale date/time if reminder gets turned off,
                        // so re-enabling doesn't silently reuse an old value.
                        if (!value) {
                          reminderDate = null;
                          reminderTime = null;
                        }
                      });
                    },
                  ),
                ],
              ),
              if (reminder) ...[
                const SizedBox(height: 20),

                InkWell(
                  onTap: pickReminderDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            reminderDate == null
                                ? "Select Reminder Date"
                                : "${reminderDate!.day}/${reminderDate!.month}/${reminderDate!.year}",
                            style: textTheme.bodyMedium?.copyWith(
                              color: reminderDate == null
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                InkWell(
                  onTap: pickReminderTime,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            reminderTime == null
                                ? "Select Reminder Time"
                                : reminderTime!.format(context),
                            style: textTheme.bodyMedium?.copyWith(
                              color: reminderTime == null
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 25),
              Text("Notes (Optional)", style: textTheme.labelLarge),
              const SizedBox(height: 8),

              TextField(
                controller: notesController,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  hintText: "Add additional notes...",
                ),
              ),
              const SizedBox(height: 45),
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
                      onPressed: _handleNext,
                      child: const Text("Next"),
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