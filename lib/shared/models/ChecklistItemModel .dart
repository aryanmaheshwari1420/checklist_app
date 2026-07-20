import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistItemModel {
  final String id;
  final String category;
  final String title;
  final bool checked;
  final int order;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ChecklistItemModel({
    required this.id,
    required this.category,
    required this.title,
    this.checked = false,
    this.order = 0,
    this.createdAt,
    this.updatedAt,
  });

  ChecklistItemModel copyWith({
    String? id,
    String? category,
    String? title,
    bool? checked,
    int? order,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ChecklistItemModel(
      id: id ?? this.id,
      category: category ?? this.category,
      title: title ?? this.title,
      checked: checked ?? this.checked,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'checked': checked,
      'order': order,
    };
  }

  factory ChecklistItemModel.fromMap(String id, Map<String, dynamic> map) {
    return ChecklistItemModel(
      id: id,
      category: map['category'] ?? '',
      title: map['title'] ?? '',
      checked: map['checked'] ?? false,
      order: map['order'] ?? 0,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }
}