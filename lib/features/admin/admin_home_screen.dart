import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'forms/event_form.dart';
import 'forms/session_form.dart';
import 'forms/speaker_form.dart';
import 'forms/user_form.dart';

import 'models/admin_event_model.dart';
import 'models/admin_session_model.dart';
import 'models/admin_speaker_model.dart';

import 'services/admin_event_service.dart';
import 'services/admin_session_service.dart';
import 'services/admin_speaker_service.dart';
import 'services/admin_seed_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

enum _Tab { dashboard, eventos, ponencias, ponentes, usuarios, reportes }

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  _Tab _tab = _Tab.dashboard;

  // Estado compartido
  final _eventSvc = AdminEventService();
  final _sesSvc   = AdminSessionService();
  final _spkSvc   = AdminSpeakerService();

  String? _selectedEventId; // para filtrar Ponencias

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final wide = MediaQuery.of(context).size.width > 1100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel — Admin EPIS'),
        actions: [
          IconButton(
            tooltip: 'Sembrar datos demo',
            onPressed: () async {
              await AdminSeedService.bootstrapFirestore();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos demo creados.')),
              );
            },
            icon: const Icon(Icons.auto_fix_high_rounded),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.admin_panel_settings, color: cs.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.logout_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _tab.index,
            onDestinationSelected: (i) => setState(() => _tab = _Tab.values[i]),
            extended: wide,
            labelType: wide ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Tooltip(
                message: FirebaseAuth.instance.currentUser?.email ?? '',
                child: const Icon(Icons.account_circle_rounded),
              ),
            ),
            destinations: const [
              NavigationRailDestination(icon: Icon(Icons.dashboard_outlined),  label: Text('Dashboard')),
              NavigationRailDestination(icon: Icon(Icons.event_rounded),       label: Text('Eventos')),
              NavigationRailDestination(icon: Icon(Icons.schedule_rounded),    label: Text('Ponencias')),
              NavigationRailDestination(icon: Icon(Icons.record_voice_over),   label: Text('Ponentes')),
              NavigationRailDestination(icon: Icon(Icons.people_alt_rounded),  label: Text('Usuarios')),
              NavigationRailDestination(icon: Icon(Icons.bar_chart_rounded),   label: Text('Reportes')),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: switch (_tab) {
                _Tab.dashboard => _Dashboard(cs: cs),
                _Tab.eventos   => _EventosTab(eventSvc: _eventSvc),
                _Tab.ponencias => _PonenciasTab(
                  eventSvc: _eventSvc,
                  sesSvc: _sesSvc,
                  selectedEventId: _selectedEventId,
                  onSelectEvent: (id) => setState(() => _selectedEventId = id),
                ),
                _Tab.ponentes  => _PonentesTab(spkSvc: _spkSvc),
                _Tab.usuarios  => const _UsuariosTab(),
                _Tab.reportes  => const _ReportesTab(),
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- DASHBOARD ---------------- */

class _Dashboard extends StatelessWidget {
  final ColorScheme cs;
  const _Dashboard({required this.cs});

  @override
  Widget build(BuildContext context) {
    final card = (String title, IconData icon, Stream<int> stream) => StreamBuilder<int>(
      stream: stream,
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return _MetricCard(
            title: title,
            value: 0,
            icon: icon,
            isLoading: true,
          );
        }
        if (s.hasError) {
          // ignore: avoid_print
          print('❌ Error en $title: ${s.error}');
          return _MetricCard(
            title: title,
            value: 0,
            icon: icon,
            hasError: true,
          );
        }
        return _MetricCard(
          title: title,
          value: s.data ?? 0,
          icon: icon,
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          // Usando los nombres correctos de las colecciones de Firebase
          card('Eventos activos', Icons.event_rounded, _count('events', where: ['estado','==','activo'])),
          card('Ponencias',      Icons.schedule_rounded, _countNested('events','sesiones')),
          card('Ponentes',       Icons.record_voice_over, _count('speakers')),
          card('Usuarios',       Icons.people_alt_rounded, _count('usuarios')),
        ],
      ),
    );
  }

  Stream<int> _count(String col, {List<Object>? where}) {
    final colRef = FirebaseFirestore.instance.collection(col);
    final q = (where != null && where.length == 3)
        ? colRef.where(where[0] as String, isEqualTo: where[2])
        : colRef;
    return q.snapshots().map((s) => s.size);
  }

  Stream<int> _countNested(String parentCol, String childCol) {
    return FirebaseFirestore.instance.collection(parentCol).snapshots().asyncMap((parent) async {
      int total = 0;
      try {
        for (final d in parent.docs) {
          try {
            final n = await d.reference.collection(childCol).count().get();
            total += n.count ?? 0;
          } catch (e) {
            // ignore: avoid_print
            print('⚠️ Error contando $childCol en ${d.id}: $e');
          }
        }
        // ignore: avoid_print
        print('✅ Total de $childCol: $total');
      } catch (e) {
        // ignore: avoid_print
        print('❌ Error contando colección anidada $parentCol/$childCol: $e');
      }
      return total;
    });
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final bool isLoading;
  final bool hasError;
  
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isLoading = false,
    this.hasError = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: cs.primary.withOpacity(.12),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    )
                  : Icon(icon, color: cs.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  if (hasError)
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.error,
                      ),
                    )
                  else
                    Row(
                      children: [
                        Text(
                          '$value',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          ),
                        ),
                        if (isLoading) ...[
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- EVENTOS ---------------- */

class _EventosTab extends StatelessWidget {
  final AdminEventService eventSvc;
  const _EventosTab({required this.eventSvc});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        _Toolbar(
          title: 'Eventos',
          onAdd: () => showDialog(context: context, builder: (_) => const EventFormDialog()),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<AdminEventModel>>(
            stream: eventSvc.streamAll(),
            builder: (_, s) {
              final items = s.data ?? const [];
              if (s.hasError) return _empty('Error: ${s.error}');
              if (items.isEmpty) return _empty('Sin eventos. Crea el primero.');
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i) {
                  final e = items[i];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(e.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${e.tipo} • ${e.lugarGeneral} • ${e.estado.toUpperCase()}'),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => EventFormDialog(existing: e),
                            ),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              await eventSvc.delete(e.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento eliminado')));
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: items.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ---------------- PONENCIAS ---------------- */

class _PonenciasTab extends StatelessWidget {
  final AdminEventService eventSvc;
  final AdminSessionService sesSvc;
  final String? selectedEventId;
  final ValueChanged<String?> onSelectEvent;

  const _PonenciasTab({
    required this.eventSvc,
    required this.sesSvc,
    required this.selectedEventId,
    required this.onSelectEvent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        _Toolbar(
          title: 'Ponencias',
          actionBuilder: (ctx) => StreamBuilder<List<AdminEventModel>>(
            stream: eventSvc.streamAll(),
            builder: (ctx, s) {
              final events = s.data ?? const [];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 280,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedEventId,
                      items: events
                          .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nombre)))
                          .toList(),
                      onChanged: onSelectEvent,
                      decoration: const InputDecoration(
                        labelText: 'Evento',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: selectedEventId == null
                        ? null
                        : () => showDialog(
                              context: context,
                              // 👉 Si tu SessionFormDialog acepta eventId, pásalo:
                             builder: (_) => const SessionFormDialog(),
                            ),
                    icon: const Icon(Icons.add),
                    label: const Text('Nueva ponencia'),
                  ),
                ],
              );
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: selectedEventId == null
              ? _empty('Selecciona un evento para ver sus ponencias.')
              : StreamBuilder<List<AdminSessionModel>>(
                  stream: sesSvc.streamByEvent(selectedEventId!),
                  builder: (_, s) {
                    final items = s.data ?? const [];
                    if (s.hasError) return _empty('Error: ${s.error}');
                    if (items.isEmpty) return _empty('Sin ponencias para este evento.');
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemBuilder: (_, i) {
                        final p = items[i];
                        final rango = '${_fmt(p.horaInicio)} – ${_fmt(p.horaFin)}';
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: cs.outlineVariant),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            title: Text(p.titulo, style: const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text('${p.ponenteNombre} • ${p.modalidad} • ${p.dia} • $rango'),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (_) => SessionFormDialog(existing: p),
                                  ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  onPressed: () async {
                                    await sesSvc.delete(p.eventoId, p.id);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ponencia eliminada')));
                                  },
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: items.length,
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _fmt(Timestamp ts) {
    final d = ts.toDate();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

/* ---------------- PONENTES ---------------- */

class _PonentesTab extends StatelessWidget {
  final AdminSpeakerService spkSvc;
  const _PonentesTab({required this.spkSvc});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        _Toolbar(
          title: 'Ponentes',
          onAdd: () => showDialog(context: context, builder: (_) => const SpeakerFormDialog()),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<List<AdminSpeakerModel>>(
            stream: spkSvc.streamAll(),
            builder: (_, s) {
              final items = s.data ?? const [];
              if (s.hasError) return _empty('Error: ${s.error}');
              if (items.isEmpty) return _empty('Sin ponentes.');
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i) {
                  final p = items[i];
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: cs.primaryContainer,
                        child: Icon(Icons.person_rounded, color: cs.onPrimaryContainer),
                      ),
                      title: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.institucion.isNotEmpty || p.contacto.isNotEmpty)
                            Text([p.institucion, p.contacto].where((e) => e.isNotEmpty).join(' • ')),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_rounded, size: 14, color: cs.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Registrado: ${_formatDateTime(p.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: 'Editar',
                            onPressed: () => showDialog(
                              context: context,
                              builder: (_) => SpeakerFormDialog(existing: p),
                            ),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                          IconButton(
                            tooltip: 'Eliminar',
                            onPressed: () async {
                              await spkSvc.delete(p.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ponente eliminado')));
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: items.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ---------------- USUARIOS ---------------- */

class _UsuariosTab extends StatelessWidget {
  const _UsuariosTab();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        _Toolbar(
          title: 'Usuarios',
          onAdd: () => showDialog(context: context, builder: (_) => const UserFormDialog()),
        ),
        const Divider(height: 1),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('usuarios').orderBy('createdAt', descending: true).snapshots(),
            builder: (_, s) {
              if (s.hasError) return _empty('Error: ${s.error}');
              final docs = s.data?.docs ?? const [];
              if (docs.isEmpty) return _empty('Sin usuarios.');
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemBuilder: (_, i) {
                  final d = docs[i].data();
                  final rol = (d['rol'] ?? d['role'] ?? '—').toString();
                  return Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: cs.outlineVariant),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(child: Text((d['email'] ?? '??')[0].toUpperCase())),
                      title: Text(d['email'] ?? ''),
                      subtitle: Text('${d['estado'] ?? '—'} • $rol'),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemCount: docs.length,
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ---------------- REPORTES ---------------- */

class _ReportesTab extends StatelessWidget {
  const _ReportesTab();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 72, color: cs.primary),
          const SizedBox(height: 12),
          const Text('Reportes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
          const SizedBox(height: 8),
          const Text('Aquí puedes enlazar tus pantallas de reportes.'),
        ],
      ),
    );
  }
}

/* ---------------- UI Helpers ---------------- */

class _Toolbar extends StatelessWidget {
  final String title;
  final VoidCallback? onAdd;
  final Widget Function(BuildContext context)? actionBuilder;

  const _Toolbar({required this.title, this.onAdd, this.actionBuilder});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: cs.surfaceContainerHighest,
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const Spacer(),
          if (actionBuilder != null) actionBuilder!(context),
          if (onAdd != null) ...[
            const SizedBox(width: 8),
            FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Nuevo')),
          ],
        ],
      ),
    );
  }
}

Widget _empty(String msg) => Center(
  child: Padding(
    padding: const EdgeInsets.all(24.0),
    child: Text(msg, style: const TextStyle(color: Colors.black54)),
  ),
);

String _formatDateTime(DateTime? dt) {
  if (dt == null) return 'Sin fecha';
  
  final now = DateTime.now();
  final diff = now.difference(dt);
  
  // Si fue hace menos de 1 minuto
  if (diff.inSeconds < 60) {
    return 'Hace ${diff.inSeconds} seg';
  }
  
  // Si fue hace menos de 1 hora
  if (diff.inMinutes < 60) {
    return 'Hace ${diff.inMinutes} min';
  }
  
  // Si fue hace menos de 24 horas
  if (diff.inHours < 24) {
    return 'Hace ${diff.inHours} h';
  }
  
  // Si fue hace menos de 7 días
  if (diff.inDays < 7) {
    return 'Hace ${diff.inDays} días';
  }
  
  // Si fue hace menos de 30 días
  if (diff.inDays < 30) {
    final weeks = (diff.inDays / 7).floor();
    return 'Hace ${weeks} ${weeks == 1 ? "semana" : "semanas"}';
  }
  
  // Si fue hace menos de 365 días
  if (diff.inDays < 365) {
    final months = (diff.inDays / 30).floor();
    return 'Hace ${months} ${months == 1 ? "mes" : "meses"}';
  }
  
  // Si fue hace más de un año
  final years = (diff.inDays / 365).floor();
  return 'Hace ${years} ${years == 1 ? "año" : "años"}';
}
