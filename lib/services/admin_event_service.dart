// lib/features/admin/services/admin_event_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../features/admin/models/admin_event_model.dart';

class AdminEventService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('events'); // 👈 Colección de eventos en inglés

  Stream<List<AdminEventModel>> streamAll() => _col
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs
          .map((d) {
            try {
              return AdminEventModel.fromDoc(d);
            } catch (_) {
              // Ignora docs incompletos para evitar errores de conversión
              return null;
            }
          })
          .whereType<AdminEventModel>()
          .toList());

  Future<void> delete(String id) => _col.doc(id).delete();

  Future<void> upsert(AdminEventModel e) async {
    // ✅ Ya no usamos .toDate(); trabajamos directamente con DateTime?
    final DateTime? inicio = e.fechaInicio;
    final DateTime? fin = e.fechaFin;

    // Calculamos los días solo si existen fechas válidas
    final diasCalc = (e.dias.isNotEmpty || inicio == null)
        ? e.dias
        : _buildDias(inicio, fin ?? inicio);

    final data = {
      ...e.toMapForUpdate(),
      'dias': diasCalc,
      'createdAt': e.createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (e.id.isEmpty) {
      // Crear nuevo
      await _col.add(data);
    } else {
      // Actualizar existente
      await _col.doc(e.id).set(data, SetOptions(merge: true));
    }
  }

  // Genera lista de días entre fechaInicio y fechaFin
  List<String> _buildDias(DateTime inicio, DateTime fin) {
    if (fin.isBefore(inicio)) {
      final tmp = inicio;
      inicio = fin;
      fin = tmp;
    }
    final out = <String>[];
    for (var d = DateTime(inicio.year, inicio.month, inicio.day);
        !d.isAfter(fin);
        d = d.add(const Duration(days: 1))) {
      out.add(
          "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}");
    }
    return out;
  }
}
