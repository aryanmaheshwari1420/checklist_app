import 'package:checklist_app/features/dashboard/presentation/controller/dashboard_controller.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardProvider =
    StreamProvider<List<ChecklistModel>>((ref) {
  return ref
      .read(dashboardControllerProvider.notifier)
      .watchUserChecklists();
});

// This is exactly how we fetched a checklist by ID.