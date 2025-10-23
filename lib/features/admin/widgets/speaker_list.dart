import 'package:flutter/material.dart';
import '../../../services/speaker_service.dart';
import '../../../models/speaker.dart';
import '../forms/speaker_form.dart' show SpeakerFormDialog;

class SpeakerList extends StatelessWidget {
  const SpeakerList({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = SpeakerService();
    return StreamBuilder<List<SpeakerModel>>(
      stream: svc.watchAll(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final items = snap.data!;
        if (items.isEmpty) {
          return const Center(child: Text('Sin ponentes'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final s = items[i];
            return ListTile(
              title: Text(s.name),
              subtitle: Text(
                '${s.organization ?? ''} • ${s.email ?? ''} • ${s.external ? 'Externo' : 'Interno'}',
              ),
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
                      builder: (_) => SpeakerFormDialog(initial: s),
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
