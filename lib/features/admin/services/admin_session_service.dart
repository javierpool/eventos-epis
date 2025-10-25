import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_session_model.dart';

class AdminSessionService {
  final _db = FirebaseFirestore.instance;

  // colecciones: eventos/{eventId}/sesiones
  CollectionReference<Map<String, dynamic>> _col(String eventId) =>
      _db.collection('eventos').doc(eventId).collection('sesiones');

  // LECTURA por evento (simple, sin índice compuesto)
  Stream<List<AdminSessionModel>> streamByEvent(String eventId) {
    return _col(eventId)
        .orderBy('horaInicio')              // solo orderBy → no requiere índice
        .snapshots()
        .map((s) => s.docs.map((d) => AdminSessionModel.fromDoc(d)).toList());
  }

  Future<void> delete(String eventId, String id) => _col(eventId).doc(id).delete();

  Future<void> upsert(AdminSessionModel s) async {
    try {
      final data = s.id.isEmpty ? s.toCreate() : s.toUpdate();
      if (s.id.isEmpty) {
        final docRef = await _col(s.eventoId).add(data);
        // ignore: avoid_print
        print('✅ Ponencia creada con ID: ${docRef.id} en evento: ${s.eventoId}');
      } else {
        await _col(s.eventoId).doc(s.id).set(data, SetOptions(merge: true));
        // ignore: avoid_print
        print('✅ Ponencia actualizada: ${s.id} en evento: ${s.eventoId}');
      }
    } on FirebaseException catch (e) {
      // ignore: avoid_print
      print('❌ Error Firebase al guardar ponencia: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error inesperado al guardar ponencia: $e');
      rethrow;
    }
  }
}
