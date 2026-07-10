import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repository/checklist_repository.dart';

final checklistRepositoryProvider =
    Provider<ChecklistRepository>((ref) {
  return ChecklistRepository();
});