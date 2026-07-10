class ChecklistModel {
  final String id;

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

  // Step 3 & 4
  final List<String> categories;

  /// Category -> List of Items
  final Map<String, List<ChecklistItem>> items;

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
    required this.items,
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
    List<String>? categories,
    Map<String, List<ChecklistItem>>? items,
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
      items: items ?? this.items,
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
      'categories': categories,
      'items': items.map(
        (key, value) =>
            MapEntry(key, value.map((item) => item.toMap()).toList()),
      ),
    };
  }

  factory ChecklistModel.fromMap(Map<String, dynamic> map) {
    return ChecklistModel(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'])
          : null,
      type: map['type'] ?? '',
      priority: map['priority'] ?? 'Medium',
      reminderEnabled: map['reminderEnabled'] ?? false,
      reminderDateTime: map['reminderDateTime'] != null
          ? DateTime.parse(map['reminderDateTime'])
          : null,
      notes: map['notes'] ?? '',
      categories: List<String>.from(map['categories'] ?? []),
      items: Map<String, List<ChecklistItem>>.from(
        (map['items'] ?? {}).map(
          (key, value) => MapEntry(
            key,
            List<ChecklistItem>.from(
              (value as List).map((item) => ChecklistItem.fromMap(item)),
            ),
          ),
        ),
      ),
    );
  }
}

class ChecklistItem {
  final String title;
  final bool checked;

  const ChecklistItem({required this.title, this.checked = false});

  ChecklistItem copyWith({String? title, bool? checked}) {
    return ChecklistItem(
      title: title ?? this.title,
      checked: checked ?? this.checked,
    );
  }

  Map<String, dynamic> toMap() {
    return {"title": title, "checked": checked};
  }

  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      title: map["title"] ?? "",
      checked: map["checked"] ?? false,
    );
  }
}
