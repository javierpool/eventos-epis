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
    try {
      final data = s.id.isEmpty ? s.toCreate() : s.toUpdate();
      if (s.id.isEmpty) {
        final docRef = await _col.add(data);
        // ignore: avoid_print
        print('✅ Ponente creado con ID: ${docRef.id}');
      } else {
        await _col.doc(s.id).set(data, SetOptions(merge: true));
        // ignore: avoid_print
        print('✅ Ponente actualizado: ${s.id}');
      }
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print('❌ Error Firebase: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error inesperado: $e');
      rethrow;
    }
  }

  Future<void> delete(String id) => _col.doc(id).delete();
}
