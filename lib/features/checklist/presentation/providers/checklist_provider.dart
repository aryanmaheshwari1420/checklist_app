import 'package:checklist_app/features/checklist/presentation/providers/checklist_controller.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final checklistByIdProvider =
    FutureProvider.family<ChecklistModel?, String>(
  (ref, checklistId) {
    return ref
        .read(checklistControllerProvider.notifier)
        .getChecklistById(checklistId);
  },
);