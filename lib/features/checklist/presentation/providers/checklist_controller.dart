import 'package:checklist_app/features/checklist/presentation/providers/checklist_repository_provider.dart';
import 'package:checklist_app/features/checklist/presentation/providers/checklist_state.dart';
import 'package:checklist_app/shared/models/ChecklistItemModel%20.dart';
import 'package:checklist_app/shared/models/checklist_category_model.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:checklist_app/shared/models/template_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final checklistControllerProvider =
    NotifierProvider<ChecklistController, ChecklistState>(
  ChecklistController.new,
);

class ChecklistController extends Notifier<ChecklistState> {
  static const _uuid = Uuid();

  @override
  ChecklistState build() {
    return ChecklistState.initial();
  }

  // =================================================================
  // CREATE MODE — local draft, written as one batch at the very end.
  // =================================================================

  Future<String?> createChecklist() async {
    final repository = ref.read(checklistRepositoryProvider);

    final checklistId = await repository.createChecklist(
      state.toChecklistModel(),
      state.items,
    );

    clear();
    return checklistId;
  }

  /// Loads an existing checklist's metadata into the draft. Items are NOT
  /// loaded here — edit-mode screens read items live via checklistItemsProvider.
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
      items: const {},
    );
  }

  void updateBasicInfo({
    required String title,
    required String description,
    DateTime? dueDate,
  }) {
    state = state.copyWith(title: title, description: description, dueDate: dueDate);
  }

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

  /// Metadata-only update — never touches items.
  Future<void> updateChecklist() async {
    final repository = ref.read(checklistRepositoryProvider);

    await repository.updateChecklistMetadata(state.toChecklistModel());
  }

  Future<void> deleteChecklist(String checklistId) async {
    final repository = ref.read(checklistRepositoryProvider);
    await repository.deleteChecklist(checklistId);
  }

  // ---- STEP 3 — draft category ops (create mode only) ----

  void addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final alreadyExists = state.categories.any(
      (c) => c.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (alreadyExists) return;

    final newCategory = ChecklistCategory(id: _uuid.v4(), name: trimmed);
    final updatedCategories = [...state.categories, newCategory];

    final updatedItems = Map<String, List<ChecklistItemModel>>.from(state.items);
    updatedItems[newCategory.id] = [];

    state = state.copyWith(categories: updatedCategories, items: updatedItems);
  }

  void removeCategory(String categoryId) {
    final updatedCategories = [...state.categories]
      ..removeWhere((c) => c.id == categoryId);

    final updatedItems = Map<String, List<ChecklistItemModel>>.from(state.items)
      ..remove(categoryId);

    state = state.copyWith(categories: updatedCategories, items: updatedItems);
  }

  void updateCategory({required String categoryId, required String newName}) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final index = state.categories.indexWhere((c) => c.id == categoryId);
    if (index == -1) return;

    final updatedCategories = [...state.categories];
    updatedCategories[index] = updatedCategories[index].copyWith(name: trimmed);

    // Items reference categoryId, which never changes — nothing else to update.
    state = state.copyWith(categories: updatedCategories);
  }

  // ---- STEP 4 — draft item ops (create mode only) ----

  void addItem({required String categoryId, required String title}) {
    final updatedItems = Map<String, List<ChecklistItemModel>>.from(state.items);
    final categoryItems = List<ChecklistItemModel>.from(updatedItems[categoryId] ?? []);

    categoryItems.add(ChecklistItemModel(
      id: _uuid.v4(),
      categoryId: categoryId,
      title: title,
      checked: false,
      order: categoryItems.length,
    ));

    updatedItems[categoryId] = categoryItems;
    state = state.copyWith(items: updatedItems);
  }

  void removeItem({required String categoryId, required ChecklistItemModel item}) {
    final updatedItems = Map<String, List<ChecklistItemModel>>.from(state.items);
    final categoryItems = List<ChecklistItemModel>.from(updatedItems[categoryId] ?? []);

    categoryItems.removeWhere((i) => i.id == item.id);
    updatedItems[categoryId] = categoryItems;

    state = state.copyWith(items: updatedItems);
  }

  void updateItem({
    required String categoryId,
    required ChecklistItemModel oldItem,
    required ChecklistItemModel newItem,
  }) {
    final updatedItems = Map<String, List<ChecklistItemModel>>.from(state.items);
    final list = List<ChecklistItemModel>.from(updatedItems[categoryId] ?? []);

    final index = list.indexWhere((i) => i.id == oldItem.id);
    if (index == -1) return;

    list[index] = newItem;
    updatedItems[categoryId] = list;

    state = state.copyWith(items: updatedItems);
  }

  void clear() {
    state = ChecklistState.initial();
  }

  /// Template categories/items are keyed by name (TemplateModel is a
  /// separate, simpler structure) — generate fresh categoryIds here.
  void loadFromTemplate(TemplateModel template) {
    final categories = template.categories
        .map((name) => ChecklistCategory(id: _uuid.v4(), name: name))
        .toList();

    final items = <String, List<ChecklistItemModel>>{};
    for (final category in categories) {
      final templateItemTitles = template.items[category.name] ?? [];
      items[category.id] = templateItemTitles
          .asMap()
          .entries
          .map((entry) => ChecklistItemModel(
                id: _uuid.v4(),
                categoryId: category.id,
                title: entry.value,
                checked: false,
                order: entry.key,
              ))
          .toList();
    }

    state = ChecklistState(
      id: '',
      title: template.title,
      description: template.description,
      dueDate: null,
      type: template.type,
      priority: "Medium",
      reminderEnabled: false,
      reminderDateTime: null,
      notes: '',
      categories: categories,
      items: items,
    );
  }

  // =================================================================
  // EDIT MODE — direct passthrough to repository, per-item/per-field
  // writes only. Screens call these directly with a live ChecklistModel.
  // =================================================================

  Future<void> toggleItemChecked({
    required String checklistId,
    required String itemId,
    required bool checked,
  }) {
    final repository = ref.read(checklistRepositoryProvider);
    return repository.toggleItemChecked(
      checklistId: checklistId,
      itemId: itemId,
      checked: checked,
    );
  }

  Future<void> addItemToChecklist({
    required String checklistId,
    required String categoryId,
    required String title,
    int order = 0,
  }) {
    final repository = ref.read(checklistRepositoryProvider);
    return repository.addItem(
      checklistId: checklistId,
      categoryId: categoryId,
      title: title,
      order: order,
    );
  }

  Future<void> updateItemTitle({
    required String checklistId,
    required String itemId,
    required String title,
  }) {
    final repository = ref.read(checklistRepositoryProvider);
    return repository.updateItemTitle(checklistId: checklistId, itemId: itemId, title: title);
  }

  Future<void> deleteItemFromChecklist({
    required String checklistId,
    required String itemId,
    required bool wasChecked,
  }) {
    final repository = ref.read(checklistRepositoryProvider);
    return repository.deleteItem(checklistId: checklistId, itemId: itemId,wasChecked: wasChecked);
  }

  /// Adds a category to an EXISTING checklist — updates only the
  /// `categories` array field.
  Future<void> addCategoryToChecklist({
    required ChecklistModel checklist,
    required String name,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final alreadyExists = checklist.categories.any(
      (c) => c.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (alreadyExists) return;

    final repository = ref.read(checklistRepositoryProvider);
    final newCategory = ChecklistCategory(id: _uuid.v4(), name: trimmed);
    final updatedCategories = [...checklist.categories, newCategory];

    await repository.updateCategories(
      checklistId: checklist.id,
      categories: updatedCategories,
    );
  }

  /// Renaming a category is now JUST an array-field update — items
  /// reference categoryId, which never changes, so they're never touched.
  Future<void> renameCategoryInChecklist({
    required ChecklistModel checklist,
    required String categoryId,
    required String newName,
  }) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;

    final index = checklist.categories.indexWhere((c) => c.id == categoryId);
    if (index == -1) return;

    final repository = ref.read(checklistRepositoryProvider);
    final updatedCategories = [...checklist.categories];
    updatedCategories[index] = updatedCategories[index].copyWith(name: trimmed);

    await repository.updateCategories(
      checklistId: checklist.id,
      categories: updatedCategories,
    );
  }

  Future<void> removeCategoryFromChecklist({
    required ChecklistModel checklist,
    required String categoryId,
  }) async {
    final repository = ref.read(checklistRepositoryProvider);
    final updatedCategories = [...checklist.categories]
      ..removeWhere((c) => c.id == categoryId);

    await repository.updateCategories(
      checklistId: checklist.id,
      categories: updatedCategories,
    );
    await repository.deleteItemsByCategoryId(
      checklistId: checklist.id,
      categoryId: categoryId,
    );
  }
}