import 'package:checklist_app/shared/models/checklist_category_model.dart';

class ChecklistModel {
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

  final int totalItems;
  final int completedItems;

  const ChecklistModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.type,
    required this.priority,
    required this.reminderEnabled,
    this.reminderDateTime,
    required this.notes,
    required this.categories,
    this.totalItems = 0,
    this.completedItems = 0,
  });

  ChecklistModel copyWith({
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
    int? totalItems,
    int? completedItems,
  }) {
    return ChecklistModel(
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
      totalItems: totalItems ?? this.totalItems,
      completedItems: completedItems ?? this.completedItems,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.toIso8601String(),
      'type': type,
      'priority': priority,
      'reminderEnabled': reminderEnabled,
      'reminderDateTime': reminderDateTime?.toIso8601String(),
      'notes': notes,
      'categories': categories.map((c) => c.toMap()).toList(),
    };
  }

  factory ChecklistModel.fromMap(Map<String, dynamic> map) {
    return ChecklistModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      type: map['type'] ?? '',
      priority: map['priority'] ?? 'Medium',
      reminderEnabled: map['reminderEnabled'] ?? false,
      reminderDateTime: map['reminderDateTime'] != null
          ? DateTime.parse(map['reminderDateTime'])
          : null,
      notes: map['notes'] ?? '',
      categories: List<Map<String, dynamic>>.from(map['categories'] ?? [])
          .map((c) => ChecklistCategory.fromMap(c))
          .toList(),
      totalItems: map['totalItems'] ?? 0,
      completedItems: map['completedItems'] ?? 0,
    );
  }
}