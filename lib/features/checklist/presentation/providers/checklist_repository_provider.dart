import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/checklist_repository.dart';

final checklistRepositoryProvider =
    Provider<ChecklistRepository>((ref) {
  return ChecklistRepository();
});