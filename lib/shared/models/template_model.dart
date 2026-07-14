class TemplateModel {
  final String id;

  final String title;
  final String description;

  /// High-level type used for tab filtering — e.g. "Travel", "Finance",
  /// "Vehicle", "Personal", "Other". Matches the tabs in the Templates list.
  /// Named "type" to stay consistent with ChecklistModel.type.
  final String type;

  /// Sub-categories inside the template — e.g. "Documents", "Packing".
  final List<String> categories;

  /// Category -> List of item titles.
  /// Plain strings only — templates have no "checked" state, they're just
  /// a blueprint that gets converted into a real ChecklistItem list later.
  final Map<String, List<String>> items;

  final bool isPublic;

  const TemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.categories,
    required this.items,
    this.isPublic = true,
  });

  int get totalCategories => categories.length;

  int get totalItems =>
      items.values.fold(0, (sum, list) => sum + list.length);

  TemplateModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    List<String>? categories,
    Map<String, List<String>>? items,
    bool? isPublic,
  }) {
    return TemplateModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'categories': categories,
      'items': items.map(
        (key, value) => MapEntry(key, value),
      ),
      'isPublic': isPublic,
    };
  }

  factory TemplateModel.fromMap(Map<String, dynamic> map) {
    return TemplateModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: map['type'] ?? 'Other',
      categories: List<String>.from(map['categories'] ?? []),
      items: Map<String, List<String>>.from(
        (map['items'] ?? {}).map(
          (key, value) => MapEntry(
            key,
            List<String>.from(value ?? []),
          ),
        ),
      ),
      isPublic: map['isPublic'] ?? true,
    );
  }
}