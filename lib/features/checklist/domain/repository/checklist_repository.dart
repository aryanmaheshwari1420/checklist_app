import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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

    doc.set({
      ...checklist.toMap(),
      'id': doc.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((e){
        debugPrint("Background sync failed for checklist ${doc.id}: $e");
    });
    return doc.id;
  }
  

  Future<void> updateChecklist(ChecklistModel checklist) async {
    // Later
     _firestore
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .collection("checklists")
      .doc(checklist.id)
      .update(checklist.toMap())
      .catchError((e){
                debugPrint("Background sync failed for checklist ${checklist.id}: $e");

      });

      return;
  }

  Future<void> deleteChecklist(String checklistId) async {
    // Later
     _firestore
      .collection("users")
      .doc(_auth.currentUser!.uid)
      .collection("checklists")
      .doc(checklistId)
      .delete()
      .catchError((e){
      debugPrint("Background sync failed for checklist delete $checklistId: $e");

      });

    return;
  }

//   Future<ChecklistModel> getChecklistById(
//     String checklistId,
// ) async {
//     final uid = _auth.currentUser!.uid;

//     final doc = await _firestore
//         .collection('users')
//         .doc(uid)
//         .collection('checklists')
//         .doc(checklistId)
//         .get();

//     if (!doc.exists) {
//       throw Exception('Checklist not found');
//     }

//     return ChecklistModel.fromMap(doc.data()!);
//   }

  Stream<ChecklistModel> watchChecklistById(String checklistId) {
  final uid = _auth.currentUser!.uid;

  return _firestore
      .collection('users')
      .doc(uid)
      .collection('checklists')
      .doc(checklistId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) {
      throw Exception('Checklist not found');
    }
    return ChecklistModel.fromMap(doc.data()!);
  });
}
  
}