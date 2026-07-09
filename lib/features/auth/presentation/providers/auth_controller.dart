import 'package:checklist_app/shared/models/user_model.dart';
import 'package:checklist_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_providers.dart';

final authControllerProvider =
    AsyncNotifierProvider<AuthController, UserModel?>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<UserModel?> {
  late final AuthRepository _repository;

  @override
  Future<UserModel?> build() async {
    _repository = ref.read(authRepositoryProvider);

    return await _repository.getCurrentUser();
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      return await _repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
    });
  }

  Future<void> logout() async {
    await _repository.logout();

    state = const AsyncData(null);
  }
  Future<UserModel?> getCurrentUser() async {
    return await _repository.getCurrentUser();
  }
}