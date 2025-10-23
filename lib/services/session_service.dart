import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_paths.dart';
import '../models/session.dart';


class SessionService {
final col = FirebaseFirestore.instance.collection(FirestorePaths.sessions);


Stream<List<SessionModel>> watchByEvent(String eventId) => col
.where('eventId', isEqualTo: eventId)
.orderBy('startAt')
.snapshots()
.map((s) => s.docs.map((d) => SessionModel.fromMap(d.id, d.data())).toList());


Future<String> create(SessionModel s) async {
final ref = await col.add(s.toMap()..['createdAt'] = FieldValue.serverTimestamp());
return ref.id;
}


Future<void> update(String id, Map<String, dynamic> data) => col.doc(id).update(data);
Future<void> delete(String id) => col.doc(id).delete();
}