class ChecklistCategory {
  final String id;
  final String name;

  const ChecklistCategory({
    required this.id,
    required this.name,
  });

  ChecklistCategory copyWith({String? id, String? name}) {
    return ChecklistCategory(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }

  factory ChecklistCategory.fromMap(Map<String, dynamic> map) {
    return ChecklistCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
    );
  }
}