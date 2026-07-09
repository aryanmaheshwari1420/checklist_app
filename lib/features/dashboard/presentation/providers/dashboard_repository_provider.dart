import 'package:checklist_app/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:checklist_app/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl();
});