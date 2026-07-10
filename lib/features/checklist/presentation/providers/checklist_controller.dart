import 'package:checklist_app/features/checklist/presentation/providers/checklist_repository_provider.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_state.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checklistControllerProvider =
    NotifierProvider<ChecklistController, ChecklistState>(
      ChecklistController.new,
    );

class ChecklistController extends Notifier<ChecklistState> {
  @override
  ChecklistState build() {
    return ChecklistState.initial();
  }

  Future<String?> createChecklist() async {
    try {
      final repository = ref.read(checklistRepositoryProvider);

      final checklistId = await repository.createChecklist(
        state.toChecklistModel(),
      );

      clear();

      return checklistId;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<ChecklistModel?> getChecklistById(String checklistId) async {
    try {
      final repository = ref.read(checklistRepositoryProvider);

      final checklist = await repository.getChecklistById(checklistId);

      return checklist;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> loadChecklist(ChecklistModel checklist) async {
    state = ChecklistState(
      id: checklist.id,
      title: checklist.title,
      description: checklist.description,
      dueDate: checklist.dueDate,
      type: checklist.type,
      priority: checklist.priority,
      reminderEnabled: checklist.reminderEnabled,
      reminderDateTime: checklist.reminderDateTime,
      notes: checklist.notes,
      categories: checklist.categories,
      items: checklist.items,
    );
  }

  /// STEP 1
  void updateBasicInfo({
    required String title,
    required String description,
    DateTime? dueDate,
  }) {
    state = state.copyWith(
      title: title,
      description: description,
      dueDate: dueDate,
    );
  }

  // STEP 2
  void updateDetails({
    required String type,
    required String priority,
    required bool reminderEnabled,
    DateTime? reminderDateTime,
    required String notes,
  }) {
    state = state.copyWith(
      type: type,
      priority: priority,
      reminderEnabled: reminderEnabled,
      reminderDateTime: reminderDateTime,
      notes: notes,
    );
  }

  /// STEP 3
  void addCategory(String type) {
    if (state.categories.contains(type)) return;

    final updatedCategories = [...state.categories, type];

    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

    updatedItems[type] = [];

    state = state.copyWith(categories: updatedCategories, items: updatedItems);
  }

  Future<void> updateChecklist() async {
    final repository = ref.read(checklistRepositoryProvider);

    final checklist = state.toChecklistModel();

    await repository.updateChecklist(checklist);
  }

  void removeCategory(String category) {
    final updatedCategories = [...state.categories]..remove(category);

    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items)
      ..remove(category);

    state = state.copyWith(categories: updatedCategories, items: updatedItems);
  }

  /// STEP 4
  void addItem({required String category, required String item}) {
    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

    final categoryItems = List<ChecklistItem>.from(
      updatedItems[category] ?? [],
    );

    categoryItems.add(ChecklistItem(title: item, checked: false));

    updatedItems[category] = categoryItems;

    state = state.copyWith(items: updatedItems);
  }

  void removeItem({required String category, required ChecklistItem item}) {
    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

    final categoryItems = List<ChecklistItem>.from(
      updatedItems[category] ?? [],
    );

    categoryItems.removeWhere(
      (checklistItem) =>
          checklistItem.title == item.title &&
          checklistItem.checked == item.checked,
    );

    updatedItems[category] = categoryItems;

    state = state.copyWith(items: updatedItems);
  }

  void updateCategory({required String oldName, required String newName}) {
    if (oldName == newName) return;

    final updatedCategories = [...state.categories];

    final index = updatedCategories.indexOf(oldName);

    if (index == -1) return;

    updatedCategories[index] = newName;

    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

    if (updatedItems.containsKey(oldName)) {
      updatedItems[newName] = updatedItems.remove(oldName)!;
    }

    state = state.copyWith(categories: updatedCategories, items: updatedItems);
  }

  void updateItem({
    required String category,
    required ChecklistItem oldItem,
    required ChecklistItem newItem,
  }) {
    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

    final list = List<ChecklistItem>.from(updatedItems[category] ?? []);

    final index = list.indexWhere(
      (item) => item.title == oldItem.title && item.checked == oldItem.checked,
    );

    if (index == -1) return;

    list[index] = newItem;

    updatedItems[category] = list;

    state = state.copyWith(items: updatedItems);
  }

  /// Clear draft after successful creation
  void clear() {
    state = ChecklistState.initial();
  }
}
