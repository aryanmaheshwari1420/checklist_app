import 'package:checklist_app/shared/models/checklist_model.dart';

abstract class DashboardRepository {
  Future<List<ChecklistModel>> getUserChecklists();
}