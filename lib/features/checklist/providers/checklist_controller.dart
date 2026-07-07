import 'package:checklist_app/features/checklist/providers/checklist_repository_provider.dart';
import 'package:checklist_app/features/checklist/providers/checklist_state.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
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

  Future<bool> createChecklist() async {
  try {
    final repository = ref.read(checklistRepositoryProvider);

    await repository.createChecklist(
      state.toChecklistModel(),
    );

    clear();

    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

  /// STEP 1
  void updateBasicInfo({
    required String title,
    required String description,
  }) {
    state = state.copyWith(
      title: title,
      description: description,
    );
  }

    // STEP 2
  void updateDetails({
  required String category,
  required String priority,
  required bool reminderEnabled,
  DateTime? reminderDateTime,
  required String notes,
}) {
  state = state.copyWith(
    category: category,
    priority: priority,
    reminderEnabled: reminderEnabled,
    reminderDateTime: reminderDateTime,
    notes: notes,
  );
}

  /// STEP 3
  void addCategory(String category) {
    if (state.categories.contains(category)) return;

    final updatedCategories = [...state.categories, category];

    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

    updatedItems[category] = [];

    state = state.copyWith(
      categories: updatedCategories,
      items: updatedItems,
    );
  }

  void removeCategory(String category) {
    final updatedCategories = [...state.categories]..remove(category);

    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items)
      ..remove(category);

    state = state.copyWith(
      categories: updatedCategories,
      items: updatedItems,
    );
  }

  /// STEP 4
  void addItem({
    required String category,
    required String item,
  }) {
    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

    final categoryItems = List<ChecklistItem>.from(
      updatedItems[category] ?? [],
    );

    categoryItems.add(ChecklistItem(title: item, checked: false));

    updatedItems[category] = categoryItems;

    state = state.copyWith(
      items: updatedItems,
    );
  }
 


  void removeItem({
    required String category,
    required ChecklistItem  item,
  }) {
    final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

    final categoryItems = List<ChecklistItem>.from(
      updatedItems[category] ?? [],
    );

    categoryItems.removeWhere((checklistItem) => checklistItem.title == item.title && checklistItem.checked == item.checked);

    updatedItems[category] = categoryItems;

    state = state.copyWith(
      items: updatedItems,
    );
  }

  void updateCategory({
  required String oldName,
  required String newName,
}) {
  if (oldName == newName) return;

  final updatedCategories = [...state.categories];

  final index = updatedCategories.indexOf(oldName);

  if (index == -1) return;

  updatedCategories[index] = newName;

  final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

  if (updatedItems.containsKey(oldName)) {
    updatedItems[newName] = updatedItems.remove(oldName)!;
  }

  state = state.copyWith(
    categories: updatedCategories,
    items: updatedItems,
  );
}
void updateItem({
  required String category,
  required ChecklistItem oldItem,
  required ChecklistItem newItem,
}) {
  final updatedItems = Map<String, List<ChecklistItem>>.from(state.items);

  final list = List<ChecklistItem>.from(
    updatedItems[category] ?? [],
  );

  final index = list.indexWhere(
    (item) =>
        item.title == oldItem.title &&
        item.checked == oldItem.checked,
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