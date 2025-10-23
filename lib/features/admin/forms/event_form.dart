// lib/features/admin/forms/event_form.dart
import 'package:flutter/material.dart';
import '../../../models/event.dart';
import '../../../services/event_service.dart';

class EventFormDialog extends StatefulWidget {
  final EventModel? initial;
  const EventFormDialog({super.key, this.initial});

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _venue = TextEditingController();
  String _status = 'draft';
  DateTime? _startAt;
  DateTime? _endAt;

  @override
  void initState() {
    super.initState();
    final e = widget.initial;
    if (e != null) {
      _title.text = e.title;
      _desc.text = e.description ?? '';
      _venue.text = e.venue ?? '';
      _status = e.status;
      _startAt = e.startAt;
      _endAt = e.endAt;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _venue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = EventService();

    return AlertDialog(
      title: Text(widget.initial == null ? 'Nuevo evento' : 'Editar evento'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Título *'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _desc,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              TextFormField(
                controller: _venue,
                decoration: const InputDecoration(labelText: 'Sede / Lugar'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Estado'),
                items: const [
                  DropdownMenuItem(value: 'draft', child: Text('Borrador')),
                  DropdownMenuItem(value: 'published', child: Text('Publicado')),
                  DropdownMenuItem(value: 'closed', child: Text('Cerrado')),
                ],
                onChanged: (v) => setState(() => _status = v ?? 'draft'),
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
            if (_startAt != null && _endAt != null && _endAt!.isBefore(_startAt!)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fin no puede ser anterior al inicio')),
              );
              return;
            }

            // Map listo para update()
            final data = EventModel(
              id: widget.initial?.id ?? '',
              title: _title.text.trim(),
              description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
              venue: _venue.text.trim().isEmpty ? null : _venue.text.trim(),
              status: _status,
              startAt: _startAt,
              endAt: _endAt,
            ).toMap();

            if (widget.initial == null) {
              // Create: pasa un modelo completo
              await svc.create(EventModel(
                id: '',
                title: _title.text.trim(),
                description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
                venue: _venue.text.trim().isEmpty ? null : _venue.text.trim(),
                status: _status,
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
