// lib/features/student/student_home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/registration_service.dart';
import 'student_event_detail_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Eventos EPIS'),
          actions: [
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout_rounded),
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Disponibles'),
              Tab(text: 'Mi historial'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AvailableEventsTab(),
            _MyHistoryTab(),
          ],
        ),
        backgroundColor: cs.surface,
      ),
    );
  }
}

class _AvailableEventsTab extends StatelessWidget {
  const _AvailableEventsTab();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    // eventos (colección: 'eventos') ordenados por fechaInicio
    final q = FirebaseFirestore.instance
        .collection('eventos')
        .orderBy('fechaInicio'); // evitamos índice compuesto

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: q.snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = (snap.data?.docs ?? [])
            .where((d) {
              final data = d.data();
              final estado = (data['estado'] ?? 'borrador').toString();
              final fi = _toDate(data['fechaInicio']);
              return estado == 'activo' && (fi == null || !fi.isBefore(now));
            })
            .toList();

        if (docs.isEmpty) {
          return const _EmptyState(
            icon: Icons.event_available_outlined,
            title: 'No hay eventos disponibles',
            subtitle: 'Cuando se publique uno nuevo, aparecerá aquí.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final d = docs[i].data();
            final id = docs[i].id;
            final nombre = (d['nombre'] ?? '').toString();
            final lugar = (d['lugarGeneral'] ?? '').toString();
            final fi = _toDate(d['fechaInicio']);
            final ff = _toDate(d['fechaFin']);

            final when = '${_fmt(fi)}${ff != null ? ' – ${_fmt(ff)}' : ''}';
            final subtitleParts = <String>[when];
            if (lugar.isNotEmpty) subtitleParts.add(lugar);

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: const Icon(Icons.event_outlined),
                title: Text(
                  nombre,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(subtitleParts.join(' • ')),
                trailing: FilledButton.tonalIcon(
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Ver detalles'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentEventDetailScreen(eventId: id),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _MyHistoryTab extends StatelessWidget {
  const _MyHistoryTab();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const _EmptyState(
        icon: Icons.lock_outline,
        title: 'Debes iniciar sesión',
        subtitle: 'Ingresa con tu cuenta para ver tu historial.',
      );
    }

    return StreamBuilder<List<UserRegistrationView>>(
      stream: RegistrationService().watchUserHistory(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const <UserRegistrationView>[];
        if (items.isEmpty) {
          return const _EmptyState(
            icon: Icons.history_toggle_off_outlined,
            title: 'Sin historial aún',
            subtitle: 'Cuando te inscribas a ponencias, aparecerán aquí.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final it = items[i];
            final rango = '${_hm(it.horaInicio)} – ${_hm(it.horaFin)}';
            final estadoAsistencia = it.attended
                ? 'Asistido'
                : it.finished
                    ? 'Finalizado'
                    : 'Inscrito';

            final subtitleParts = <String>[
              it.eventName,
              if (it.dia.isNotEmpty) it.dia,
              rango,
            ];

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
              ),
              child: ListTile(
                leading: const Icon(Icons.schedule_outlined),
                title: Text(
                  it.titulo,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(subtitleParts.join(' • ')),
                trailing: FilledButton.tonalIcon(
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: Text(estadoAsistencia),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentEventDetailScreen(eventId: it.eventId),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/* helpers */
DateTime? _toDate(dynamic v) {
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return null;
}

String _fmt(DateTime? dt) {
  if (dt == null) return '—';
  final dd = dt.day.toString().padLeft(2, '0');
  final mm = dt.month.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mi = dt.minute.toString().padLeft(2, '0');
  return '$dd/$mm/${dt.year} $hh:$mi';
}

String _hm(Timestamp ts) {
  final d = ts.toDate();
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: cs.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
