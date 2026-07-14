import 'package:checklist_app/features/templates/presentation/providers/template_repository_provider.dart';
import 'package:checklist_app/shared/models/template_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All public templates, live-updating.
final allTemplatesProvider = StreamProvider<List<TemplateModel>>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.watchAllTemplates();
});

/// Templates filtered by type (e.g. "Travel"). Pass "All" (or null) for
/// every template — used by the category tabs on the Templates list screen.
final templatesByTypeProvider =
    StreamProvider.family<List<TemplateModel>, String?>((ref, type) {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.watchTemplatesByType(type);
});

/// A single template by id, live-updating — used by the
/// Template Overview screen.
final templateByIdProvider =
    StreamProvider.family<TemplateModel, String>((ref, templateId) {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.watchTemplateById(templateId);
});

/// Distinct list of types found across all templates, derived live from
/// Firestore data instead of being hardcoded. "All" is always first, and
/// "Other" (if present) is always pushed last since it's a catch-all bucket.
/// Everything else is sorted alphabetically in between.
final templateTypesProvider = Provider<AsyncValue<List<String>>>((ref) {
  final allTemplatesAsync = ref.watch(allTemplatesProvider);

  return allTemplatesAsync.whenData((templates) {
    final distinctTypes = templates.map((t) => t.type).toSet().toList();

    final hasOther = distinctTypes.remove('Other');
    distinctTypes.sort();

    if (hasOther) {
      distinctTypes.add('Other');
    }

    return ['All', ...distinctTypes];
  });
});

// TemplateModel (data structure)
//     ↓
// TemplateRepository (Firestore access)
//     ↓
// templateRepositoryProvider → allTemplatesProvider / templatesByTypeProvider / templateByIdProvider