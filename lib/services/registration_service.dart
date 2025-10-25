// lib/services/registration_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import 'attendance_service.dart';

class RegistrationService {
  final _db = FirebaseFirestore.instance;

  /* =================== CRUD básico de inscripciones =================== */

  // Stream sencillo por usuario (si lo necesitas en otros lados)
  Stream<QuerySnapshot<Map<String, dynamic>>> watchByUser(String uid) {
    return _db
        .collection('registrations')
        .where('uid', isEqualTo: uid)
        .snapshots();
  }

  String _docId(String eventId, String uid, [String? sessionId]) {
    // Sin sesión:   evento_uid
    // Con sesión:   evento_sesion_uid
    return sessionId == null ? '${eventId}_$uid' : '${eventId}_${sessionId}_$uid';
  }

  Future<void> register(String uid, String eventId, [String? sessionId]) async {
    final id = _docId(eventId, uid, sessionId);
    await _db.collection('registrations').doc(id).set({
      'id': id,
      'eventId': eventId,
      'uid': uid,
      if (sessionId != null) 'sessionId': sessionId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> unregister(String uid, String eventId, [String? sessionId]) async {
    final id = _docId(eventId, uid, sessionId);
    await _db.collection('registrations').doc(id).delete();
  }

  Future<bool> isRegistered(String uid, String eventId, [String? sessionId]) async {
    final id = _docId(eventId, uid, sessionId);
    final doc = await _db.collection('registrations').doc(id).get();
    return doc.exists;
  }

  /* =================== Historial para StudentHome =================== */
  /// Devuelve un stream con el historial del usuario combinando:
  /// - Inscripción (registrations)
  /// - Datos del evento (eventos/{eventId})
  /// - Datos de la ponencia si existe (eventos/{eventId}/ponencias/{sessionId})
  /// - Estado de asistencia (attendance)
  ///
  /// Ajusta los nombres de campos/colecciones si en tu Firestore son distintos.
  Stream<List<UserRegistrationView>> watchUserHistory(String uid) {
    final baseStream = _db
        .collection('registrations')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    final attendanceSvc = AttendanceService();

    return baseStream.asyncMap((snap) async {
      final futures = snap.docs.map((d) async {
        final data = d.data();
        final String eventId = (data['eventId'] ?? '').toString();
        final String? sessionId = (data['sessionId'] as String?);

        // 1) Evento
        final evDoc = await _db.collection('eventos').doc(eventId).get();
        final ev = evDoc.data() ?? {};
        final String eventName = (ev['nombre'] ?? '').toString();

        // Defaults (si no hay sesión)
        String titulo = eventName.isNotEmpty ? eventName : 'Evento';
        String dia = '';
        Timestamp horaInicioTs = (ev['fechaInicio'] is Timestamp)
            ? ev['fechaInicio'] as Timestamp
            : Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(0));
        Timestamp horaFinTs = (ev['fechaFin'] is Timestamp)
            ? ev['fechaFin'] as Timestamp
            : horaInicioTs;

        // 2) Sesión opcional
        if (sessionId != null && sessionId.isNotEmpty) {
          final sesDoc = await _db
              .collection('eventos')
              .doc(eventId)
              .collection('ponencias')
              .doc(sessionId)
              .get();
          final ses = sesDoc.data() ?? {};
          titulo = (ses['titulo'] ?? titulo).toString();
          dia = (ses['dia'] ?? '').toString();
          if (ses['horaInicio'] is Timestamp) {
            horaInicioTs = ses['horaInicio'] as Timestamp;
          }
          if (ses['horaFin'] is Timestamp) {
            horaFinTs = ses['horaFin'] as Timestamp;
          }
        }

        // 3) Asistencia
        final attended = await attendanceSvc.wasMarked(eventId, uid, sessionId);

        return UserRegistrationView(
          eventId: eventId,
          sessionId: sessionId,
          eventName: eventName,
          titulo: titulo,
          dia: dia,
          horaInicio: horaInicioTs,
          horaFin: horaFinTs,
          attended: attended,
        );
      }).toList();

      final list = await Future.wait(futures);
      // Orden por horaInicio descendente (opcional, ya viene por createdAt desc)
      list.sort((a, b) => b.horaInicio.compareTo(a.horaInicio));
      return list;
    });
  }

  /* =================== Estado para una sesión concreta =================== */
  Future<UserSessionStatus> statusForUserSession(
    String? uid,
    String eventId,
    String sessionId,
  ) async {
    if (uid == null || uid.isEmpty) {
      return const UserSessionStatus(registered: false, attended: false);
    }
    final registered = await isRegistered(uid, eventId, sessionId);
    final attended = await AttendanceService().wasMarked(eventId, uid, sessionId);
    return UserSessionStatus(registered: registered, attended: attended);
  }
}

/* =================== Modelos usados por la UI =================== */

class UserRegistrationView {
  final String eventId;
  final String? sessionId;
  final String eventName;
  final String titulo;      // Título de la ponencia o del evento
  final String dia;         // Texto como "Lunes 21" (si lo manejas así)
  final Timestamp horaInicio;
  final Timestamp horaFin;
  final bool attended;

  UserRegistrationView({
    required this.eventId,
    required this.sessionId,
    required this.eventName,
    required this.titulo,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.attended,
  });

  bool get finished => horaFin.toDate().isBefore(DateTime.now());
}

class UserSessionStatus {
  final bool registered;
  final bool attended;
  const UserSessionStatus({required this.registered, required this.attended});
}
