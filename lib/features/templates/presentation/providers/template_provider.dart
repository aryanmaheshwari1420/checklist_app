import 'package:checklist_app/features/templates/presentation/providers/template_repository_provider.dart';
import 'package:checklist_app/shared/models/template_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final allTemplatesProvider = StreamProvider<List<TemplateModel>>((ref) {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.watchAllTemplates();
});

final templatesByTypeProvider =
    StreamProvider.family<List<TemplateModel>, String?>((ref, type) {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.watchTemplatesByType(type);
});

final templateByIdProvider =
    StreamProvider.family<TemplateModel, String>((ref, templateId) {
  final repository = ref.watch(templateRepositoryProvider);
  return repository.watchTemplateById(templateId);
});

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