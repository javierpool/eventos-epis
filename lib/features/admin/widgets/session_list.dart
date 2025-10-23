import 'package:flutter/material.dart';
import '../../../services/session_service.dart';
import '../../../models/session.dart';
import '../forms/session_form.dart' show SessionFormDialog;

class SessionList extends StatefulWidget {
  const SessionList({super.key});
  @override
  State<SessionList> createState() => _SessionListState();
}

class _SessionListState extends State<SessionList> {
  final _svc = SessionService();
  final _eventIdCtrl = TextEditingController();
  String? _eventId;

  @override
  void dispose() {
    _eventIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFilter = (_eventId != null && _eventId!.trim().isNotEmpty);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _eventIdCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Event ID',
                    hintText: 'Ej.: abc123…',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: () => setState(() => _eventId = _eventIdCtrl.text.trim()),
                icon: const Icon(Icons.filter_list),
                label: const Text('Aplicar'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  _eventIdCtrl.clear();
                  setState(() => _eventId = null);
                },
                child: const Text('Limpiar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: hasFilter
              ? _SessionsForEvent(eventId: _eventId!)
              : Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Filtra por evento para ver ponencias.'),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => const SessionFormDialog(),
                          );
                        },
                        child: const Text('Crear ponencia rápida'),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _SessionsForEvent extends StatelessWidget {
  final String eventId;
  const _SessionsForEvent({required this.eventId});

  @override
  Widget build(BuildContext context) {
    final svc = SessionService();
    return StreamBuilder<List<SessionModel>>(
      stream: svc.watchByEvent(eventId),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data ?? const <SessionModel>[];
        if (items.isEmpty) {
          return const Center(child: Text('No hay ponencias para este evento'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final s = items[i];
            final when =
                '${_fmtDateTime(s.startAt)} ${s.endAt != null ? '– ${_fmtDateTime(s.endAt)}' : ''}';
            final parts = <String>[
              if ((s.room ?? '').isNotEmpty) 'Sala: ${s.room}',
              if ((s.speakerId ?? '').isNotEmpty) 'Ponente: ${s.speakerId}',
              if (s.startAt != null || s.endAt != null) when,
            ];
            return ListTile(
              title: Text(s.title),
              subtitle: Text(parts.where((e) => e.isNotEmpty).join('  •  ')),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => const [
                  PopupMenuItem<String>(value: 'edit', child: Text('Editar')),
                  PopupMenuItem<String>(value: 'delete', child: Text('Eliminar')),
                ],
                onSelected: (v) async {
                  if (v == 'edit') {
                    // ignore: use_build_context_synchronously
                    await showDialog(
                      context: context,
                      builder: (_) => SessionFormDialog(initial: s),
                    );
                  } else if (v == 'delete') {
                    await svc.delete(s.id);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

String _fmtDateTime(DateTime? dt) {
  if (dt == null) return '—';
  final dd = dt.day.toString().padLeft(2, '0');
  final mm = dt.month.toString().padLeft(2, '0');
  final hh = dt.hour.toString().padLeft(2, '0');
  final mi = dt.minute.toString().padLeft(2, '0');
  return '$dd/$mm/${dt.year} $hh:$mi';
}
