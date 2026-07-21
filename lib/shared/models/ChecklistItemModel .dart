import 'package:cloud_firestore/cloud_firestore.dart';

class ChecklistItemModel {
  final String id;
  final String categoryId;
  final String title;
  final bool checked;
  final int order;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  const ChecklistItemModel({
    required this.id,
    required this.categoryId,
    required this.title,
    this.checked = false,
    this.order = 0,
    this.createdAt,
    this.updatedAt,
  });

  ChecklistItemModel copyWith({
    String? id,
    String? categoryId,
    String? title,
    bool? checked,
    int? order,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return ChecklistItemModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
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
      'categoryId': categoryId,
      'title': title,
      'checked': checked,
      'order': order,
    };
  }

  factory ChecklistItemModel.fromMap(String id, Map<String, dynamic> map) {
    return ChecklistItemModel(
      id: id,
      categoryId: map['categoryId'] ?? '',
      title: map['title'] ?? '',
      checked: map['checked'] ?? false,
      order: map['order'] ?? 0,
      createdAt: map['createdAt'] as Timestamp?,
      updatedAt: map['updatedAt'] as Timestamp?,
    );
  }
}