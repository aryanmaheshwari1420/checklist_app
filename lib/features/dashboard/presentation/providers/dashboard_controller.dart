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

  Future<List<ChecklistModel>> getUserChecklists() async {
    final repository = ref.read(
      dashboardRepositoryProvider,
    );

    return repository.getUserChecklists();
  }
}

// no state here.

// Dashboard is just reading.