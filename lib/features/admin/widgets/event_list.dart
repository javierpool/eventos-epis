import 'package:flutter/material.dart';
import '../../../services/event_service.dart';
import '../../../models/event.dart';
// Cambiamos a la pantalla que ya tienes creada:
import '../../events/event_form_screen.dart';

class EventList extends StatelessWidget {
  const EventList({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = EventService();
    return StreamBuilder<List<EventModel>>(
      stream: svc.watchAll(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return const Center(child: Text('Sin eventos'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final e = items[i];
            return ListTile(
              title: Text(e.title),
              subtitle: Text('${e.venue ?? ''} • ${e.status}'),
              trailing: PopupMenuButton<String>(
                // 👇 sin const para evitar el error; además tipamos <String>
                itemBuilder: (_) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Eliminar'),
                  ),
                ],
                onSelected: (String v) async {
                  if (v == 'edit') {
                    // Abrimos la pantalla de edición que ya tienes
                    // ignore: use_build_context_synchronously
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventFormScreen(
                          docId: e.id,
                          initial: e.toMap(), // pasamos el map actual
                        ),
                      ),
                    );
                  } else if (v == 'delete') {
                    await EventService().delete(e.id);
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
