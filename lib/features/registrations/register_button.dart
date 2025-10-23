import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/registration_service.dart';
import '../../models/registration.dart';

class RegisterButton extends StatefulWidget {
  final String eventId;
  const RegisterButton({required this.eventId, super.key});

  @override
  State<RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<RegisterButton> {
  final _auth = FirebaseAuth.instance;
  final _svc = RegistrationService();
  bool _loading = false;

  Future<void> _doRegister() async {
    final u = _auth.currentUser;
    if (u == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para inscribirte.')),
      );
      return;
    }

    setState(() => _loading = true);
    await _svc.create(RegistrationModel(
      id: '',
      eventId: widget.eventId,
      userId: u.uid,
      createdAt: DateTime.now(),
    ));

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inscripción registrada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _loading ? null : _doRegister,
        child: _loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Inscribirme'),
      ),
    );
  }
}
