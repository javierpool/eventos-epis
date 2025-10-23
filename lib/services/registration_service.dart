import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_paths.dart';
import '../models/registration.dart';


class RegistrationService {
final col = FirebaseFirestore.instance.collection(FirestorePaths.registrations);


Stream<int> countForEvent(String eventId) => col
.where('eventId', isEqualTo: eventId)
.snapshots()
.map((s) => s.docs.length);


Future<String> create(RegistrationModel r) async {
final ref = await col.add(r.toMap());
return ref.id;
}


Future<void> delete(String id) => col.doc(id).delete();
}