// lib/features/admin/forms/session_form.dart
import 'package:flutter/material.dart';
import '../../../models/session.dart';
import '../../../services/session_service.dart';

class SessionFormDialog extends StatefulWidget {
  final SessionModel? initial;
  const SessionFormDialog({super.key, this.initial});

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _abstract = TextEditingController();
  final _eventId = TextEditingController();
  final _room = TextEditingController();
  final _speakerId = TextEditingController();
  DateTime? _startAt;
  DateTime? _endAt;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      _title.text = s.title;
      _abstract.text = s.abstract ?? '';
      _eventId.text = s.eventId;
      _room.text = s.room ?? '';
      _speakerId.text = s.speakerId ?? '';
      _startAt = s.startAt;
      _endAt = s.endAt;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _abstract.dispose();
    _eventId.dispose();
    _room.dispose();
    _speakerId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = SessionService();

    return AlertDialog(
      title: Text(widget.initial == null ? 'Nueva ponencia' : 'Editar ponencia'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _eventId,
                decoration: const InputDecoration(labelText: 'Event ID *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Título *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _abstract,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Resumen'),
              ),
              TextFormField(
                controller: _room,
                decoration: const InputDecoration(labelText: 'Sala'),
              ),
              TextFormField(
                controller: _speakerId,
                decoration: const InputDecoration(labelText: 'Speaker ID'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DateBtn(
                      label: 'Inicio',
                      value: _startAt,
                      onPick: (d) => setState(() => _startAt = d),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DateBtn(
                      label: 'Fin',
                      value: _endAt,
                      onPick: (d) => setState(() => _endAt = d),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () async {
            if (!_form.currentState!.validate()) return;

            // Map listo para update()
            final data = SessionModel(
              id: widget.initial?.id ?? '',
              eventId: _eventId.text.trim(),
              title: _title.text.trim(),
              abstract: _abstract.text.trim().isEmpty ? null : _abstract.text.trim(),
              room: _room.text.trim().isEmpty ? null : _room.text.trim(),
              speakerId: _speakerId.text.trim().isEmpty ? null : _speakerId.text.trim(),
              startAt: _startAt,
              endAt: _endAt,
            ).toMap();

            if (widget.initial == null) {
              // Create: pasa un modelo completo
              await svc.create(SessionModel(
                id: '',
                eventId: _eventId.text.trim(),
                title: _title.text.trim(),
                abstract: _abstract.text.trim().isEmpty ? null : _abstract.text.trim(),
                room: _room.text.trim().isEmpty ? null : _room.text.trim(),
                speakerId: _speakerId.text.trim().isEmpty ? null : _speakerId.text.trim(),
                startAt: _startAt,
                endAt: _endAt,
              ));
            } else {
              // Update por id con map
              await svc.update(widget.initial!.id, data);
            }

            if (mounted) Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _DateBtn extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onPick;
  const _DateBtn({required this.label, required this.value, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? '—'
        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year} '
          '${value!.hour.toString().padLeft(2, '0')}:${value!.minute.toString().padLeft(2, '0')}';

    return OutlinedButton(
      onPressed: () async {
        final now = DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 3),
        );
        if (date == null) return;
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(value ?? now),
        );
        onPick(DateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? 0,
          time?.minute ?? 0,
        ));
      },
      child: Align(alignment: Alignment.centerLeft, child: Text('$label: $text')),
    );
  }
}
