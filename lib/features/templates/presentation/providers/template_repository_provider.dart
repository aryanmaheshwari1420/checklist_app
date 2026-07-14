import 'package:checklist_app/features/templates/domain/repositories/template_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final templateRepositoryProvider = Provider<TemplateRepository>((ref) {
  return TemplateRepository();
});