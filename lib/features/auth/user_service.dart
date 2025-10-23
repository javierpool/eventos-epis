// lib/services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/app_user.dart';
import '../../core/firestore_paths.dart'; // <- Clase: FirestorePaths

class UserService {
  // Usa directamente FirestorePaths.users
  final CollectionReference<Map<String, dynamic>> col =
      FirebaseFirestore.instance.collection(FirestorePaths.users);

  Future<AppUser?> getById(String uid) async {
    final doc = await col.doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;

    final data = doc.data()!;
    // OJO: el factory es AppUser.fromMap(String id, Map<String, dynamic> map)
    return AppUser.fromMap(doc.id, data);
  }

  Future<void> upsert(AppUser u) {
    return col.doc(u.uid).set(u.toMap(), SetOptions(merge: true));
  }
}
