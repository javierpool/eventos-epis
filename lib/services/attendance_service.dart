// lib/services/attendance_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  final _db = FirebaseFirestore.instance;

  String _docId(String eventId, String uid, [String? sessionId]) {
    return sessionId == null ? '${eventId}_$uid' : '${eventId}_${sessionId}_$uid';
  }

  Future<void> mark(String eventId, String uid, [String? sessionId]) async {
    final id = _docId(eventId, uid, sessionId);
    await _db.collection('attendance').doc(id).set({
      'id': id,
      'eventId': eventId,
      'uid': uid,
      if (sessionId != null) 'sessionId': sessionId,
      'markedAt': FieldValue.serverTimestamp(),
      'present': true,
    }, SetOptions(merge: true));
  }

  Future<bool> wasMarked(String eventId, String uid, [String? sessionId]) async {
    final id = _docId(eventId, uid, sessionId);
    final doc = await _db.collection('attendance').doc(id).get();
    return doc.exists && (doc.data()?['present'] == true);
  }

  /// NUEVO: marca asistencia solo si estamos dentro de la ventana de tiempo.
  /// Usa tolerancia: 15 min antes y 30 min después.
  Future<bool> markIfInWindow({
    required String uid,
    required String eventId,
    required String sessionId,
    required DateTime start,
    required DateTime end,
    Duration toleranceBefore = const Duration(minutes: 15),
    Duration toleranceAfter = const Duration(minutes: 30),
  }) async {
    final now = DateTime.now();
    final windowStart = start.subtract(toleranceBefore);
    final windowEnd = end.add(toleranceAfter);

    if (now.isBefore(windowStart) || now.isAfter(windowEnd)) {
      return false;
    }

    await mark(eventId, uid, sessionId);
    return true;
  }
}
