// lib/services/event_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  if (v is String) {
    try {
      return DateTime.parse(v);
    } catch (_) {}
  }
  return null;
}

class EventService {
  final _db = FirebaseFirestore.instance;

  /// 🔹 Obtener un evento por su ID (para pantallas de detalle o edición)
  Future<EventModel?> porId(String id) async {
    final doc = await _db.collection('eventos').doc(id).get();
    if (!doc.exists) return null;
    final d = doc.data()!;
    return EventModel(
      id: doc.id,
      title: (d['nombre'] ?? d['title'] ?? '').toString(),
      description: (d['descripcion'] ?? d['description'])?.toString(),
      venue: (d['lugarGeneral'] ?? d['venue'])?.toString(),
      status: (d['estado'] ?? d['status'] ?? 'publicado').toString(),
      startAt: _toDate(d['fechaInicio'] ?? d['startAt']),
      endAt: _toDate(d['fechaFin'] ?? d['endAt']),
    );
  }

  /// 🔹 Guardar o actualizar un evento (admin)
  Future<void> upsert(String? id, EventModel model) async {
    final data = {
      'nombre': model.title,
      'descripcion': model.description,
      'lugarGeneral': model.venue,
      'estado': model.status,
      'fechaInicio': model.startAt,
      'fechaFin': model.endAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (id == null || id.isEmpty) {
      await _db.collection('eventos').add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _db.collection('eventos').doc(id).set(data, SetOptions(merge: true));
    }
  }

  /// 🔹 Escuchar un evento junto con sus ponencias (sesiones)
  Stream<EventView> watchEventWithSessions(String eventId) async* {
    await for (final evSnap in _db.collection('eventos').doc(eventId).snapshots()) {
      if (!evSnap.exists) {
        yield EventView(
          id: eventId,
          name: '',
          venue: null,
          start: null,
          end: null,
          sessions: const [],
        );
        continue;
      }

      // Cargar las sesiones (ponencias) del evento
      final sesQS = await _db
          .collection('eventos')
          .doc(eventId)
          .collection('sesiones')
          .orderBy('horaInicio', descending: false)
          .get();

      final d = evSnap.data() as Map<String, dynamic>;
      final sessions = sesQS.docs.map((s) {
        final sd = s.data();
        return SessionView(
          id: s.id,
          titulo: (sd['titulo'] ?? '').toString(),
          ponenteNombre: (sd['ponenteNombre'] ?? '').toString(),
          dia: (sd['dia'] ?? '').toString(),
          horaInicio: (sd['horaInicio'] as Timestamp?) ?? Timestamp.now(),
          horaFin: (sd['horaFin'] as Timestamp?) ?? Timestamp.now(),
          modalidad: (sd['modalidad'] ?? 'Presencial').toString(),
          sala: (sd['sala'] ?? '').toString(),
          link: (sd['link'] ?? '').toString(),
        );
      }).toList();

      yield EventView(
        id: evSnap.id,
        name: (d['nombre'] ?? d['title'] ?? '').toString(),
        venue: (d['lugarGeneral'] ?? d['venue'])?.toString(),
        start: _toDate(d['fechaInicio'] ?? d['startAt']),
        end: _toDate(d['fechaFin'] ?? d['endAt']),
        sessions: sessions,
      );
    }
  }
}

/// 🔸 Modelo simplificado para la vista del evento en detalle (solo lectura)
class EventView {
  final String id;
  final String name;
  final String? venue;
  final DateTime? start;
  final DateTime? end;
  final List<SessionView> sessions;

  EventView({
    required this.id,
    required this.name,
    required this.venue,
    required this.start,
    required this.end,
    required this.sessions,
  });
}

/// 🔸 Modelo de cada ponencia o sesión
class SessionView {
  final String id;
  final String titulo;
  final String ponenteNombre;
  final String dia;
  final Timestamp horaInicio;
  final Timestamp horaFin;
  final String modalidad;
  final String? sala;
  final String? link;

  SessionView({
    required this.id,
    required this.titulo,
    required this.ponenteNombre,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.modalidad,
    this.sala,
    this.link,
  });
}
