import 'package:checklist_app/features/auth/presentation/providers/auth_controller.dart';
import 'package:checklist_app/shared/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final currentUserProvider =
    FutureProvider<UserModel?>((ref) async {
  return ref
      .read(authControllerProvider.notifier)
      .getCurrentUser();
});