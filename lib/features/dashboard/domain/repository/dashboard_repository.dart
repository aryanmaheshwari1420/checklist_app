import 'package:checklist_app/shared/models/checklist_model.dart';

abstract class DashboardRepository {
  Stream<List<ChecklistModel>> watchUserChecklists();
}