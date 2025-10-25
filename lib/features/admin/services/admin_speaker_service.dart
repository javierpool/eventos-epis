import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_speaker_model.dart';

class AdminSpeakerService {
  final _col = FirebaseFirestore.instance.collection('speakers');

  Stream<List<AdminSpeakerModel>> streamAll() {
    return _col.orderBy('nombre').snapshots().map(
      (qs) => qs.docs
          .map((d) => AdminSpeakerModel.fromDoc(
                d as DocumentSnapshot<Map<String, dynamic>>,
              ))
          .toList(),
    );
  }

  Future<void> upsert(AdminSpeakerModel s) async {
    final data = s.id.isEmpty ? s.toCreate() : s.toUpdate();
    if (s.id.isEmpty) {
      await _col.add(data);
    } else {
      await _col.doc(s.id).set(data, SetOptions(merge: true));
    }
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}
