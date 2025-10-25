import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error_handler.dart';
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

  String? _selectedEventGroup; // para filtrar Ponencias por grupo de eventos

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
                  selectedEventGroup: _selectedEventGroup,
                  onSelectEventGroup: (group) => setState(() => _selectedEventGroup = group),
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
          card('Eventos activos', Icons.event_rounded, _count('eventos', where: ['estado','==','activo'])),
          card('Ponencias',      Icons.schedule_rounded, _countNested('eventos','sesiones')),
          card('Ponentes',       Icons.record_voice_over, _count('ponentes')),
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
    // Escucha cambios en la colección padre y cuenta todas las sesiones en paralelo
    return FirebaseFirestore.instance
        .collection(parentCol)
        .snapshots()
        .asyncMap((parentSnapshot) async {
      if (parentSnapshot.docs.isEmpty) {
        AppLogger.warning('No hay documentos en $parentCol');
        return 0;
      }

      try {
        // Crear todas las consultas de conteo en paralelo
        final countFutures = parentSnapshot.docs.map((doc) {
          return doc.reference
              .collection(childCol)
              .get()
              .then((snapshot) => snapshot.docs.length);
        }).toList();

        // Esperar a que todas terminen
        final counts = await Future.wait(countFutures);
        final total = counts.fold<int>(0, (sum, count) => sum + count);

        AppLogger.success('Total de $childCol: $total (de ${parentSnapshot.docs.length} $parentCol)');
        return total;
      } catch (e, st) {
        AppLogger.error('Error contando $childCol', e, st);
        return 0;
      }
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
  final String? selectedEventGroup;
  final ValueChanged<String?> onSelectEventGroup;

  const _PonenciasTab({
    required this.eventSvc,
    required this.sesSvc,
    required this.selectedEventGroup,
    required this.onSelectEventGroup,
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
              final allEvents = s.data ?? const [];
              
              // Agrupar eventos por nombre base (sin años ni ediciones)
              final eventGroups = <String, List<AdminEventModel>>{};
              for (final event in allEvents) {
                // Extraer el nombre base eliminando años, números y palabras comunes
                final groupName = _extractBaseName(event.nombre);
                eventGroups.putIfAbsent(groupName, () => []).add(event);
              }
              
              // Obtener lista de grupos ordenada
              final groups = eventGroups.keys.toList()..sort();
              
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 320,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: selectedEventGroup,
                      items: groups.map((groupName) {
                        final eventsInGroup = eventGroups[groupName]!;
                        final eventCount = eventsInGroup.length;
                        final activeCount = eventsInGroup.where((e) => e.estado == 'activo').length;
                        
                        return DropdownMenuItem(
                          value: groupName,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  groupName,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  eventCount == 1 
                                    ? '1 evento' 
                                    : '$eventCount eventos',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: onSelectEventGroup,
                      decoration: const InputDecoration(
                        labelText: 'Grupo de Eventos',
                        border: OutlineInputBorder(),
                        isDense: true,
                        prefixIcon: Icon(Icons.folder_outlined),
                      ),
                      hint: const Text('Selecciona un grupo de eventos'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: selectedEventGroup == null
                        ? null
                        : () => showDialog(
                              context: context,
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
          child: selectedEventGroup == null
              ? _empty('Selecciona un grupo de eventos para ver sus ponencias.')
              : StreamBuilder<List<AdminEventModel>>(
                  stream: eventSvc.streamAll(),
                  builder: (ctx, eventSnapshot) {
                    if (eventSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final allEvents = eventSnapshot.data ?? const [];
                    
                    // Filtrar eventos del grupo seleccionado usando nombre base
                    final eventsInGroup = allEvents
                        .where((e) => _extractBaseName(e.nombre) == selectedEventGroup)
                        .toList();
                    
                    if (eventsInGroup.isEmpty) {
                      return _empty('No se encontraron eventos en este grupo.');
                    }
                    
                    // Obtener IDs de todos los eventos del grupo
                    final eventIds = eventsInGroup.map((e) => e.id).toList();
                    
                    // Combinar ponencias de todos los eventos del grupo
                    return _GroupSessionsView(
                      sesSvc: sesSvc,
                      eventIds: eventIds,
                      groupName: selectedEventGroup!,
                      cs: cs,
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Widget que muestra todas las ponencias de múltiples eventos agrupados
class _GroupSessionsView extends StatelessWidget {
  final AdminSessionService sesSvc;
  final List<String> eventIds;
  final String groupName;
  final ColorScheme cs;

  const _GroupSessionsView({
    required this.sesSvc,
    required this.eventIds,
    required this.groupName,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    // Crear streams para cada evento y combinarlos
    final streams = eventIds.map((id) => sesSvc.streamByEvent(id)).toList();
    
    return StreamBuilder<List<List<AdminSessionModel>>>(
      stream: _combineStreams(streams),
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return _empty('Error: ${snapshot.error}');
        }
        
        // Combinar todas las ponencias
        final allSessions = <AdminSessionModel>[];
        for (final sessionList in snapshot.data ?? []) {
          allSessions.addAll(sessionList);
        }
        
        // Ordenar por fecha/hora de inicio
        allSessions.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));
        
        if (allSessions.isEmpty) {
          return _empty('Sin ponencias para "$groupName".\nAgrega la primera ponencia.');
        }
        
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (_, i) {
            final p = allSessions[i];
            final rango = '${_fmt(p.horaInicio)} – ${_fmt(p.horaFin)}';
            
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: cs.primaryContainer,
                  child: Icon(Icons.school, color: cs.onPrimaryContainer),
                ),
                title: Text(
                  p.titulo,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('👤 ${p.ponenteNombre}'),
                    Text('📍 ${p.modalidad} • ${p.dia} • $rango'),
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
                        builder: (_) => SessionFormDialog(existing: p),
                      ),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Eliminar',
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirmar eliminación'),
                            content: Text('¿Eliminar la ponencia "${p.titulo}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          await sesSvc.delete(p.eventoId, p.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ Ponencia eliminada')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemCount: allSessions.length,
        );
      },
    );
  }
  
  // Combinar múltiples streams en uno solo
  Stream<List<List<AdminSessionModel>>> _combineStreams(
    List<Stream<List<AdminSessionModel>>> streams,
  ) async* {
    await for (final _ in Stream.periodic(const Duration(milliseconds: 500))) {
      final results = <List<AdminSessionModel>>[];
      for (final stream in streams) {
        await for (final data in stream.take(1)) {
          results.add(data);
        }
      }
      yield results;
    }
  }

  String _fmt(Timestamp ts) {
    final d = ts.toDate();
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}

/// Extrae el nombre base de un evento eliminando años, ediciones y números
/// 
/// Ejemplos:
/// - "CATEC 2025" → "CATEC"
/// - "CATEC 2024" → "CATEC"
/// - "Microsoft 2023" → "Microsoft"
/// - "Software Libre - Edición 5" → "Software Libre"
String _extractBaseName(String eventName) {
  // Eliminar años (2020-2099)
  String cleaned = eventName.replaceAll(RegExp(r'\b20\d{2}\b'), '').trim();
  
  // Eliminar palabras comunes de edición
  cleaned = cleaned.replaceAll(RegExp(r'\b(Edición|Edition|Ed\.|Vol\.|Volumen)\s*\d*\b', caseSensitive: false), '').trim();
  
  // Eliminar números romanos al final (I, II, III, IV, V, etc.)
  cleaned = cleaned.replaceAll(RegExp(r'\b[IVX]+\s*$'), '').trim();
  
  // Eliminar guiones, puntos y espacios extra al final
  cleaned = cleaned.replaceAll(RegExp(r'[\s\-\.]+$'), '').trim();
  
  // Si quedó vacío, devolver el nombre original
  if (cleaned.isEmpty) {
    return eventName.trim();
  }
  
  return cleaned;
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
