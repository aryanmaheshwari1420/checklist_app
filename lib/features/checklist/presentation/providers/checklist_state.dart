//this will become the single source of truth for all four screens, and each step will simply update the shared state without touching firebase until the final create action.


import 'package:checklist_app/shared/models/checklist_model.dart';

class ChecklistState {
  // Step 1
  final String title;
  final String description;
  final DateTime? dueDate;

  // Step 2
  final String type;
  final String priority;
  final bool reminderEnabled;
  final DateTime? reminderDateTime;
  final String notes;

  // Step 3 & Step 4
  final List<String> categories;

  /// Category -> List of Items
  final Map<String, List<ChecklistItem>> items;

  const ChecklistState({
    this.title = '',
    this.description = '',
    this.dueDate,
    this.type = '',
    this.priority = 'Medium',
    this.reminderEnabled = false,
    this.reminderDateTime,
    this.notes = '',
    this.categories = const [],
    this.items = const {},
  });

  ChecklistState copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? type,
    String? priority,
    bool? reminderEnabled,
    DateTime? reminderDateTime,
    String? notes,
    List<String>? categories,
    Map<String, List<ChecklistItem>>? items,
  }) {
    return ChecklistState(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDateTime: reminderDateTime ?? this.reminderDateTime,
      notes: notes ?? this.notes,
      categories: categories ?? this.categories,
      items: items ?? this.items,
    );
  }

  ChecklistModel toChecklistModel() {
    return ChecklistModel(
      title: title,
      description: description,
      dueDate: dueDate,
      type: type,
      priority: priority,
      reminderEnabled: reminderEnabled,
      reminderDateTime: reminderDateTime,
      notes: notes,
      categories: categories,
      items: items,
    );
  }

  factory ChecklistState.initial() {
    return const ChecklistState();
  }
}