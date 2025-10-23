import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_paths.dart';
import '../models/event.dart';

class EventService {
  final col = FirebaseFirestore.instance.collection(FirestorePaths.events);

  Stream<List<EventModel>> watchAll() => col
      .orderBy('startAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => EventModel.fromDoc(d)).toList());

  Future<String> create(EventModel e) async {
    final ref = await col.add(e.toMap()..['createdAt'] = FieldValue.serverTimestamp());
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> data) => col.doc(id).update(data);
  Future<void> delete(String id) => col.doc(id).delete();

  // 👇 NUEVO: compatible con tu llamada
  Future<EventModel?> porId(String id) async {
    final doc = await col.doc(id).get();
    if (!doc.exists) return null;
    return EventModel.fromDoc(doc);
  }
}
