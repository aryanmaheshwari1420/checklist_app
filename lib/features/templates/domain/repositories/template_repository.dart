import 'package:checklist_app/shared/models/template_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TemplateRepository {
  TemplateRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // Templates are shared/public data, not tied to a specific user —
  // stored in a top-level collection, unlike checklists which live
  // under users/{uid}/checklists.
  CollectionReference<Map<String, dynamic>> get _templatesRef =>
      _firestore.collection('templates');

  /// Real-time stream of all public templates.
  Stream<List<TemplateModel>> watchAllTemplates() {
    return _templatesRef
        .where('isPublic', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TemplateModel.fromMap(doc.data()))
            .toList());
  }

  /// Real-time stream of templates filtered by type (e.g. "Travel").
  /// Pass null or "All" to get every template.
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

  /// Real-time stream of a single template by id — used by the
  /// Template Overview screen.
  Stream<TemplateModel> watchTemplateById(String templateId) {
    return _templatesRef.doc(templateId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Template not found');
      }
      return TemplateModel.fromMap(doc.data()!);
    });
  }

  /// One-time fetch — useful for the bulk-import script or any place
  /// where a live stream isn't needed.
  Future<TemplateModel> getTemplateById(String templateId) async {
    final doc = await _templatesRef.doc(templateId).get();

    if (!doc.exists) {
      throw Exception('Template not found');
    }

    return TemplateModel.fromMap(doc.data()!);
  }

  /// Creates a new template document. Mainly used by the bulk-import
  /// script or an admin flow — regular users only read templates.
  Future<String> createTemplate(TemplateModel template) async {
    final doc = _templatesRef.doc();

    await doc.set({
      ...template.toMap(),
      'id': doc.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<void> updateTemplate(TemplateModel template) async {
    await _templatesRef.doc(template.id).update({
      ...template.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTemplate(String templateId) async {
    await _templatesRef.doc(templateId).delete();
  }
}