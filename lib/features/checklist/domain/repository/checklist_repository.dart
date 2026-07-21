import 'package:checklist_app/shared/models/ChecklistItemModel%20.dart';
import 'package:checklist_app/shared/models/checklist_category_model.dart';
import 'package:checklist_app/shared/models/checklist_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChecklistRepository {
  ChecklistRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _checklistsRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('checklists');

  CollectionReference<Map<String, dynamic>> _itemsRef(
    String uid,
    String checklistId,
  ) =>
      _checklistsRef(uid).doc(checklistId).collection('items');

  // ---------------------------------------------------------------
  // CHECKLIST METADATA
  // ---------------------------------------------------------------

  Future<String> createChecklist(
    ChecklistModel checklist,
    Map<String, List<ChecklistItemModel>> draftItemsByCategoryId,
  ) async {
    final uid = _auth.currentUser!.uid;
    final doc = _checklistsRef(uid).doc();

    final batch = _firestore.batch();

    final totalItems =
        draftItemsByCategoryId.values.fold<int>(0, (sum, l) => sum + l.length);
    final completedItems = draftItemsByCategoryId.values
        .fold<int>(0, (sum, l) => sum + l.where((i) => i.checked).length);

    batch.set(doc, {
      ...checklist.toMap(),
      'id': doc.id,
      'totalItems': totalItems,
      'completedItems': completedItems,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    for (final entry in draftItemsByCategoryId.entries) {
      for (final item in entry.value) {
        final itemDoc = _itemsRef(uid, doc.id).doc();
        batch.set(itemDoc, {
          'categoryId': entry.key,
          'title': item.title,
          'checked': item.checked,
          'order': item.order,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    }

    batch.commit().catchError((e) {
      debugPrint("Background sync failed for checklist create ${doc.id}: $e");
    });

    return doc.id;
  }

  /// Updates metadata fields only. totalItems/completedItems are
  /// deliberately excluded from ChecklistModel.toMap(), so this never
  /// clobbers the counters.
  Future<void> updateChecklistMetadata(ChecklistModel checklist) async {
    final uid = _auth.currentUser!.uid;

    _checklistsRef(uid).doc(checklist.id).update({
      ...checklist.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((e) {
      debugPrint("Background sync failed for checklist ${checklist.id}: $e");
    });
  }

  Future<void> updateCategories({
    required String checklistId,
    required List<ChecklistCategory> categories,
  }) async {
    final uid = _auth.currentUser!.uid;

    _checklistsRef(uid).doc(checklistId).update({
      'categories': categories.map((c) => c.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((e) {
      debugPrint("Background sync failed updating categories for $checklistId: $e");
    });
  }

  Future<void> deleteChecklist(String checklistId) async {
    final uid = _auth.currentUser!.uid;

    // Delete the checklist doc immediately — fire-and-forget, offline-safe,
  // exactly like create/update. This resolves instantly regardless of
  // network state, so the UI never hangs waiting on it.
  _checklistsRef(uid).doc(checklistId).delete().catchError((e) {
    debugPrint("Background sync failed for checklist delete $checklistId: $e");
  });

  // Clean up the items subcollection in the background — not awaited by
  // the caller, so a slow/offline items query never blocks deletion of
  // the checklist itself.
  _deleteAllItems(uid, checklistId);
  }

  Future<void> _deleteAllItems(String uid, String checklistId) async {
  try {
    // Try cache first — if this checklist's items were ever loaded via
    // watchItems()'s .snapshots(), they're already cached locally and this
    // resolves instantly even fully offline. A server-sourced get() here
    // is what was hanging: with zero connectivity it can block for a long
    // time before failing, which is why deletion felt inconsistent.
    QuerySnapshot<Map<String, dynamic>> snapshot;
    try {
      snapshot = await _itemsRef(uid, checklistId)
          .get(const GetOptions(source: Source.cache));
    } catch (_) {
      // No cached data (e.g. this checklist's items screen was never
      // opened) — fall back to a normal get(), which is fine when online
      // and simply won't find anything useful to delete when offline.
      snapshot = await _itemsRef(uid, checklistId).get();
    }

    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    batch.commit().catchError((e) {
      debugPrint("Background sync failed deleting items for $checklistId: $e");
    });
  } catch (e) {
    debugPrint("Failed to fetch items for deletion of $checklistId: $e");
  }
  }

  Stream<ChecklistModel> watchChecklistById(String checklistId) {
    final uid = _auth.currentUser!.uid;

    return _checklistsRef(uid).doc(checklistId).snapshots().map((doc) {
      if (!doc.exists) {
        throw Exception('Checklist not found');
      }
      return ChecklistModel.fromMap(doc.data()!);
    });
  }

  // ---------------------------------------------------------------
  // ITEMS (subcollection)
  // ---------------------------------------------------------------

  Stream<List<ChecklistItemModel>> watchItems(String checklistId) {
    final uid = _auth.currentUser!.uid;

    return _itemsRef(uid, checklistId)
        .orderBy('order')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChecklistItemModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Future<void> addItem({
    required String checklistId,
    required String categoryId,
    required String title,
    int order = 0,
  }) async {
    final uid = _auth.currentUser!.uid;
    final doc = _itemsRef(uid, checklistId).doc();
    final checklistDoc = _checklistsRef(uid).doc(checklistId);

    final batch = _firestore.batch();
    batch.set(doc, {
      'categoryId': categoryId,
      'title': title,
      'checked': false,
      'order': order,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(checklistDoc, {
      'totalItems': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.commit().catchError((e) {
      debugPrint("Background sync failed adding item to $checklistId: $e");
    });
  }

  /// The hot-path fix: toggling a checkbox updates one item field and
  /// increments/decrements the parent's completedItems counter — both
  /// tiny, atomic writes. No full-checklist rewrite.
  Future<void> toggleItemChecked({
    required String checklistId,
    required String itemId,
    required bool checked,
  }) async {
    final uid = _auth.currentUser!.uid;
    final itemDoc = _itemsRef(uid, checklistId).doc(itemId);
    final checklistDoc = _checklistsRef(uid).doc(checklistId);

    final batch = _firestore.batch();
    batch.update(itemDoc, {
      'checked': checked,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(checklistDoc, {
      'completedItems': FieldValue.increment(checked ? 1 : -1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.commit().catchError((e) {
      debugPrint("Background sync failed toggling item $itemId: $e");
    });
  }

  Future<void> updateItemTitle({
    required String checklistId,
    required String itemId,
    required String title,
  }) async {
    final uid = _auth.currentUser!.uid;

    _itemsRef(uid, checklistId).doc(itemId).update({
      'title': title,
      'updatedAt': FieldValue.serverTimestamp(),
    }).catchError((e) {
      debugPrint("Background sync failed updating item $itemId: $e");
    });
  }

  /// Needs to know whether the item was checked, to correctly decrement
  /// completedItems as well as totalItems.
  Future<void> deleteItem({
    required String checklistId,
    required String itemId,
    required bool wasChecked,
  }) async {
    final uid = _auth.currentUser!.uid;
    final itemDoc = _itemsRef(uid, checklistId).doc(itemId);
    final checklistDoc = _checklistsRef(uid).doc(checklistId);

    final batch = _firestore.batch();
    batch.delete(itemDoc);
    batch.update(checklistDoc, {
      'totalItems': FieldValue.increment(-1),
      if (wasChecked) 'completedItems': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.commit().catchError((e) {
      debugPrint("Background sync failed deleting item $itemId: $e");
    });
  }

  /// Deletes all items under a categoryId and decrements counters by the
  /// exact amounts removed (fetches current state first to compute deltas).
  Future<void> deleteItemsByCategoryId({
    required String checklistId,
    required String categoryId,
  }) async {
    final uid = _auth.currentUser!.uid;

    final snapshot = await _itemsRef(uid, checklistId)
        .where('categoryId', isEqualTo: categoryId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final removedTotal = snapshot.docs.length;
    final removedCompleted =
        snapshot.docs.where((d) => (d.data()['checked'] ?? false) == true).length;

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.update(_checklistsRef(uid).doc(checklistId), {
      'totalItems': FieldValue.increment(-removedTotal),
      if (removedCompleted > 0)
        'completedItems': FieldValue.increment(-removedCompleted),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.commit().catchError((e) {
      debugPrint("Background sync failed deleting category items for $checklistId: $e");
    });
  }
}