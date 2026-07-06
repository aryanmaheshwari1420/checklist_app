import 'package:checklist_app/core/services/firebase_auth_service.dart';
import 'package:checklist_app/core/services/firestore_service.dart';
import 'package:checklist_app/shared/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepository({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  Future<UserModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    // Create Firebase Auth user
    final credential = await _authService.register(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw Exception("Unable to create user.");
    }

    final now = Timestamp.now();

    final user = UserModel(
      uid: firebaseUser.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      createdAt: now,
      updatedAt: now,
    );

    // Save user profile in Firestore
    await _firestoreService.createUser(user);

    return user;
  }

  Future<UserModel?> getCurrentUser() async {
    final currentUser = _authService.currentUser;

    if (currentUser == null) return null;

    return await _firestoreService.getUser(currentUser.uid);
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}