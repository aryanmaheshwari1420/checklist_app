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

  // Future<TemplateModel> getTemplateById(String templateId) async {
  //   final doc = await _templatesRef.doc(templateId).get();

  //   if (!doc.exists) {
  //     throw Exception('Template not found');
  //   }

  //   return TemplateModel.fromMap(doc.data()!);
  // }

  Future<String> createTemplate(TemplateModel template) async {
    final doc = _templatesRef.doc();

    await doc.set({
      ...template.toMap(),
      'id': doc.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((e){
            debugPrint("Background sync failed for template ${doc.id}: $e");
    });

    return doc.id;
  }

  Future<void> updateTemplate(TemplateModel template) async {
    await _templatesRef.doc(template.id).update({
      ...template.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((e){
      debugPrint("Background sync failed for template ${template.id}: $e");
    });
  }

  Future<void> deleteTemplate(String templateId) async {
    await _templatesRef.doc(templateId).delete().catchError((e){
      debugPrint("Background sync failed for template delete $templateId: $e");
    });
  }
}