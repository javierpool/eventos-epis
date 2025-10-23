import 'package:flutter/material.dart';
import '../../services/event_service.dart';
import '../../models/event.dart';
import '../registrations/register_button.dart';

class EventDetailScreen extends StatefulWidget {
  final String eventId;
  const EventDetailScreen({required this.eventId, super.key});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _svc = EventService();
  EventModel? _event;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final e = await _svc.porId(widget.eventId); // ahora existe
    if (!mounted) return;
    setState(() => _event = e);
  }

  @override
  Widget build(BuildContext context) {
    final e = _event;
    if (e == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text(e.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((e.description ?? '').isNotEmpty)
              Text(e.description!),
            const SizedBox(height: 8),
            Text('Cuándo: ${_fmtDateTime(e.startAt)} ${e.endAt != null ? '— ${_fmtDateTime(e.endAt)}' : ''}'),
            Text('Dónde: ${e.venue ?? '—'}'),
            Text('Estado: ${e.status}'),
            const Spacer(),
            // Si por alguna razón tu modelo tuviera id nullable, usa: e.id ?? widget.eventId
            RegisterButton(eventId: e.id),
          ],
        ),
      ),
    );
  }

  String _fmtDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mi = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/${dt.year} $hh:$mi';
  }
}
