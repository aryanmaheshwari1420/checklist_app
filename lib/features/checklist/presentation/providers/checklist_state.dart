import 'package:checklist_app/shared/models/ChecklistItemModel%20.dart';
import 'package:checklist_app/shared/models/checklist_category_model.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';

class ChecklistState {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;

  final String type;
  final String priority;
  final bool reminderEnabled;
  final DateTime? reminderDateTime;
  final String notes;

  final List<ChecklistCategory> categories;

  /// categoryId -> List of draft items (not yet in Firestore).
  final Map<String, List<ChecklistItemModel>> items;

  const ChecklistState({
    this.id = '',
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
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? type,
    String? priority,
    bool? reminderEnabled,
    DateTime? reminderDateTime,
    String? notes,
    List<ChecklistCategory>? categories,
    Map<String, List<ChecklistItemModel>>? items,
  }) {
    return ChecklistState(
      id: id ?? this.id,
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
      id: id,
      title: title,
      description: description,
      dueDate: dueDate,
      type: type,
      priority: priority,
      reminderEnabled: reminderEnabled,
      reminderDateTime: reminderDateTime,
      notes: notes,
      categories: categories,
    );
  }

  factory ChecklistState.initial() {
    return const ChecklistState();
  }
}