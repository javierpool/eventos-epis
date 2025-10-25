// lib/features/student/student_event_detail_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/event_service.dart';          // define EventView y SessionView
import '../../services/registration_service.dart';
import '../../services/attendance_service.dart';

class StudentEventDetailScreen extends StatelessWidget {
  final String eventId;
  const StudentEventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de evento')),
      body: _EventDetailBody(eventId: eventId),
    );
  }
}

class _EventDetailBody extends StatelessWidget {
  final String eventId;
  const _EventDetailBody({required this.eventId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<EventView>(
      stream: EventService().watchEventWithSessions(eventId),
      builder: (_, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snap.hasData) {
          return const Center(child: Text('Evento no encontrado'));
        }
        final ev = snap.data!;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Card(
              elevation: 0,
              color: cs.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: cs.outlineVariant),
              ),
              child: ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  ev.name.isEmpty ? '(Sin nombre)' : ev.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${_dmy(ev.start)} – ${_dmy(ev.end)}${ev.venue != null && ev.venue!.isNotEmpty ? ' • ${ev.venue}' : ''}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Ponencias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (ev.sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Aún no hay ponencias para este evento.'),
              ),
            for (final s in ev.sessions)
              _SessionTile(eventId: eventId, s: s, uid: uid),
          ],
        );
      },
    );
  }

  String _dmy(DateTime? dt) {
    if (dt == null) return '—';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} $hh:$mi';
  }
}

class _SessionTile extends StatelessWidget {
  final String eventId;
  final SessionView s;
  final String? uid;
  const _SessionTile({required this.eventId, required this.s, required this.uid});

  bool _inWindow() {
    final now = DateTime.now();
    final start = s.horaInicio.toDate().subtract(const Duration(minutes: 15));
    final end = s.horaFin.toDate().add(const Duration(minutes: 30));
    return now.isAfter(start) && now.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FutureBuilder<UserSessionStatus>(
      future: RegistrationService().statusForUserSession(uid, eventId, s.id),
      builder: (_, st) {
        final registered = st.data?.registered == true;
        final attended = st.data?.attended == true;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: cs.outlineVariant),
          ),
          child: ListTile(
            title: Text(s.titulo.isEmpty ? '(Sin título)' : s.titulo,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(
              '${s.ponenteNombre} • ${s.dia} • ${_hm(s.horaInicio)} – ${_hm(s.horaFin)}',
            ),
            trailing: Wrap(
              spacing: 8,
              children: [
                if (!registered)
                  FilledButton(
                    onPressed: uid == null
                        ? null
                        : () async {
                            await RegistrationService().register(uid!, eventId, s.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Inscrito')),
                              );
                            }
                          },
                    child: const Text('Inscribirme'),
                  ),
                if (registered)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Mi QR'),
                    onPressed: uid == null
                        ? null
                        : () {
                            final exp = DateTime.now()
                                .add(const Duration(minutes: 10))
                                .millisecondsSinceEpoch;
                            final payload = 'ev:$eventId;se:${s.id};u:$uid;exp:$exp';
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('QR de asistencia'),
                                content: QrImageView(data: payload, size: 240),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              ),
                            );
                          },
                  ),
                if (registered && !attended)
                  FilledButton.tonal(
                    onPressed: (_inWindow() && uid != null)
                        ? () async {
                            final ok = await AttendanceService().markIfInWindow(
                              uid: uid!,
                              eventId: eventId,
                              sessionId: s.id,
                              start: s.horaInicio.toDate(),
                              end: s.horaFin.toDate(),
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'Asistencia marcada'
                                      : 'Fuera de ventana de tiempo'),
                                ),
                              );
                            }
                          }
                        : null,
                    child: const Text('Marcar asistencia'),
                  ),
                if (attended) const Icon(Icons.verified, color: Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }

  String _hm(Timestamp ts) {
    final d = ts.toDate();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
