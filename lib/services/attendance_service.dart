import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_paths.dart';


class AttendanceService {
final col = FirebaseFirestore.instance.collection(FirestorePaths.attendance);


Future<void> mark(String eventId, String userId) async {
final key = '${eventId}_$userId';
await col.doc(key).set({
'eventId': eventId,
'userId': userId,
'markedAt': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));
}


Stream<int> count(String eventId) => col
.where('eventId', isEqualTo: eventId)
.snapshots()
.map((s) => s.docs.length);
}