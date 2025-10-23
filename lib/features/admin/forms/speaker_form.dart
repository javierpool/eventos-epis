// lib/features/admin/forms/speaker_form.dart
import 'package:flutter/material.dart';
import '../../../models/speaker.dart';
import '../../../services/speaker_service.dart';

class SpeakerFormDialog extends StatefulWidget {
  final SpeakerModel? initial;
  const SpeakerFormDialog({super.key, this.initial});

  @override
  State<SpeakerFormDialog> createState() => _SpeakerFormDialogState();
}

class _SpeakerFormDialogState extends State<SpeakerFormDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _org = TextEditingController();
  final _bio = TextEditingController();
  bool _external = false;

  @override
  void initState() {
    super.initState();
    final s = widget.initial;
    if (s != null) {
      _name.text = s.name;
      _email.text = s.email ?? '';
      _org.text = s.organization ?? '';
      _bio.text = s.bio ?? '';
      _external = s.external;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _org.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Nuevo ponente' : 'Editar ponente'),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nombre *'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Obligatorio' : null,
              ),
              TextFormField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _org,
                decoration: const InputDecoration(labelText: 'Institución'),
              ),
              TextFormField(
                controller: _bio,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Bio'),
              ),
              SwitchListTile(
                title: const Text('Ponente externo'),
                value: _external,
                onChanged: (v) => setState(() => _external = v),
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            if (!_form.currentState!.validate()) return;

            final payload = SpeakerModel(
              id: widget.initial?.id ?? '',
              name: _name.text.trim(),
              email: _email.text.trim().isEmpty ? null : _email.text.trim(),
              organization: _org.text.trim().isEmpty ? null : _org.text.trim(),
              bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
              external: _external,
            );

            final svc = SpeakerService();
            if (widget.initial == null) {
              // Crear
              await svc.create(payload);
            } else {
              // Actualizar
              await svc.update(widget.initial!.id, payload.toMap());
            }

            if (mounted) Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
