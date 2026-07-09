import 'package:checklist_app/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  DashboardRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<List<ChecklistModel>> getUserChecklists() async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _firestore
        .collection("users")
        .doc(uid)
        .collection("checklists")
        .orderBy("createdAt", descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => ChecklistModel.fromMap(doc.data()),
        )
        .toList();
  }
}