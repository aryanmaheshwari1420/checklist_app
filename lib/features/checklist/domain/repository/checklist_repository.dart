import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChecklistRepository {
  ChecklistRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<String> createChecklist(ChecklistModel checklist) async {
    final uid = _auth.currentUser!.uid;

    final doc = _firestore
        .collection('users')
        .doc(uid)
        .collection('checklists')
        .doc();

    await doc.set({
      ...checklist.toMap(),
      'id': doc.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
  

  Future<void> updateChecklist(ChecklistModel checklist) async {
    // Later
    await _firestore
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .collection("checklists")
      .doc(checklist.id)
      .update(checklist.toMap());
  }

  Future<void> deleteChecklist(String checklistId) async {
    // Later
  }

  Future<ChecklistModel> getChecklistById(
    String checklistId,
) async {
    final uid = _auth.currentUser!.uid;

    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('checklists')
        .doc(checklistId)
        .get();

    if (!doc.exists) {
      throw Exception('Checklist not found');
    }

    return ChecklistModel.fromMap(doc.data()!);
  }
  
}