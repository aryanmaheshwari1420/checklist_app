import 'package:checklist_app/features/dashboard/presentation/providers/dashboard_repository_provider.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardControllerProvider =
    NotifierProvider<DashboardController, void>(
  DashboardController.new,
);

class DashboardController extends Notifier<void> {
  @override
  void build() {}

  Stream<List<ChecklistModel>> watchUserChecklists()  {
    final repository = ref.read(
      dashboardRepositoryProvider,
    );

    return repository.watchUserChecklists();
  }
}