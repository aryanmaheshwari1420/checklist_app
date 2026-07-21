import 'package:checklist_app/features/checklist/presentation/providers/checklist_repository_provider.dart';
import 'package:checklist_app/shared/models/ChecklistItemModel%20.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live stream of a checklist's items (subcollection). Used by edit/view
/// mode screens instead of the draft state — keeps writes granular and
/// the UI always reflects the latest Firestore data.
final checklistItemsProvider =
    StreamProvider.family<List<ChecklistItemModel>, String>((ref, checklistId) {
  final repository = ref.watch(checklistRepositoryProvider);
  return repository.watchItems(checklistId);
});