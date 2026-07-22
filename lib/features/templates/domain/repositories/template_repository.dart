import 'package:checklist_app/shared/models/template_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TemplateRepository {
  TemplateRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _templatesRef =>
      _firestore.collection('templates');

  Stream<List<TemplateModel>> watchAllTemplates() {
    return _templatesRef
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TemplateModel.fromMap(doc.data()))
            .toList());
  }

  Stream<List<TemplateModel>> watchTemplatesByType(String? type) {
    if (type == null || type == 'All') {
      return watchAllTemplates();
    }

    return _templatesRef
        .where('isPublic', isEqualTo: true)
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TemplateModel.fromMap(doc.data()))
            .toList());
  }

  Stream<TemplateModel> watchTemplateById(String templateId) {
    return _templatesRef.doc(templateId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Template not found');
      }
      return TemplateModel.fromMap(doc.data()!);
    });
  }

  Future<String> createTemplate(TemplateModel template) async {
    final doc = _templatesRef.doc();

    try {
      await doc.set({
        ...template.toMap(),
        'id': doc.id,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      // 'unavailable' means Firestore queued this locally and will sync
      // once back online — expected, not a failure the user needs to see.
      if (e.code == 'unavailable') return doc.id;

      debugPrint("Background sync failed for template ${doc.id}: $e");
      rethrow;
    }

    return doc.id;
  }

  Future<void> updateTemplate(TemplateModel template) async {
    try {
      await _templatesRef.doc(template.id).update({
        ...template.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') return;

      debugPrint("Background sync failed for template ${template.id}: $e");
      rethrow;
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      await _templatesRef.doc(templateId).delete();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable') return;

      debugPrint("Background sync failed for template delete $templateId: $e");
      rethrow;
    }
  }
}