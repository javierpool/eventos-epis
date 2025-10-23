import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_paths.dart';
import '../models/speaker.dart';


class SpeakerService {
final col = FirebaseFirestore.instance.collection(FirestorePaths.speakers);


Stream<List<SpeakerModel>> watchAll() => col
.orderBy('name')
.snapshots()
.map((s) => s.docs.map((d) => SpeakerModel.fromMap(d.id, d.data())).toList());


Future<String> create(SpeakerModel s) async {
final ref = await col.add(s.toMap()..['createdAt'] = FieldValue.serverTimestamp());
return ref.id;
}


Future<void> update(String id, Map<String, dynamic> data) => col.doc(id).update(data);
Future<void> delete(String id) => col.doc(id).delete();
}