import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/registration_service.dart';

class RegisterButton extends StatefulWidget {
  final String eventId;
  final String sessionId; // ponencia/sesión específica

  const RegisterButton({
    super.key,
    required this.eventId,
    required this.sessionId,
  });

  @override
  State<RegisterButton> createState() => _RegisterButtonState();
}

class _RegisterButtonState extends State<RegisterButton> {
  final _auth = FirebaseAuth.instance;
  final _svc = RegistrationService();

  bool _loading = false;
  bool _registered = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final u = _auth.currentUser;
    if (u == null) return;
    final reg = await _svc.isRegistered(u.uid, widget.eventId, widget.sessionId);
    if (!mounted) return;
    setState(() => _registered = reg);
  }

  Future<void> _doRegister() async {
    final u = _auth.currentUser;
    if (u == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para inscribirte.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _svc.register(u.uid, widget.eventId, widget.sessionId);
      if (!mounted) return;
      setState(() => _registered = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscripción registrada correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: (_loading || _registered) ? null : _doRegister,
      child: _loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(_registered ? 'Inscrito' : 'Inscribirme'),
    );
  }
}
