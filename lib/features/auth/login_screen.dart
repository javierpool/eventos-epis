// lib/features/auth/login_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../app/router_by_rol.dart'; // navega según rol

final _auth = FirebaseAuth.instance;
final _fs   = FirebaseFirestore.instance;

/// Usa la API KEY de tu firebase_options.dart (cualquiera funciona para este endpoint)
const String _FIREBASE_API_KEY = 'AIzaSyA1_7Ni2tTPloZLQ_g1tvucNIfpWeFNQY4';

bool _esInstitucional(String email) {
  final e = email.trim().toLowerCase();
  return e.endsWith('@upt.pe') || e.endsWith('@virtual.upt.pe');
}

/// Consulta REST a Firebase Auth para saber proveedores de un email.
Future<List<String>> _fetchSignInMethodsREST(String email) async {
  final url = Uri.parse(
    'https://identitytoolkit.googleapis.com/v1/accounts:createAuthUri?key=$_FIREBASE_API_KEY',
  );
  final resp = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'identifier': email,
      'continueUri': 'http://localhost',
    }),
  );
  if (resp.statusCode == 200) {
    final data = jsonDecode(resp.body);
    return (data['allProviders'] as List?)?.cast<String>() ?? <String>[];
  }
  return <String>[];
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  StreamSubscription<User?>? _authSub;

  bool _obscure = true;
  bool _loading = false;
  bool _modoInstitucional = true;

  @override
  void initState() {
    super.initState();
    // Si vuelve autenticado (por redirect), intentamos navegación por rol
    _authSub = FirebaseAuth.instance.userChanges().listen((u) async {
      if (u != null && mounted) {
        final ok = await _ensureUserDocAndGuard(u);
        if (ok) await goHomeByRol(context);
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _emailCtrl..clear()..dispose();
    _passCtrl..clear()..dispose();
    super.dispose();
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), behavior: SnackBarBehavior.floating),
    );
  }

  /// Crea/actualiza doc en `usuarios/{uid}` y bloquea acceso si `estado != activo`.
  /// Devuelve `true` si puede continuar; `false` si debe salir.
  Future<bool> _ensureUserDocAndGuard(User u) async {
    final uid   = u.uid;
    final mail  = (u.email ?? '').toLowerCase();
    final modo  = _esInstitucional(mail) ? 'institucional' : 'externo';
    final domain = mail.split('@').length == 2 ? mail.split('@')[1] : '';

    final ref = _fs.collection('usuarios').doc(uid);

    await _fs.runTransaction((txn) async {
      final snap = await txn.get(ref);
      if (!snap.exists) {
        txn.set(ref, {
          'email'      : mail,
          'displayName': u.displayName ?? '',
          'photoURL'   : u.photoURL ?? '',
          'domain'     : domain,
          'modo'       : modo,
          'rol'        : 'estudiante',
          // institucional: activo por defecto / externo: pendiente
          'estado'     : (modo == 'institucional') ? 'activo' : 'pendiente',
          'createdAt'  : FieldValue.serverTimestamp(),
          'updateAt'   : FieldValue.serverTimestamp(),
        });
      } else {
        txn.update(ref, {'updateAt': FieldValue.serverTimestamp()});
      }
    });

    final data   = (await ref.get()).data() ?? {};
    final estado = (data['estado'] ?? 'pendiente').toString();

    if (estado != 'activo') {
      // Bloquear acceso si no está activo
      _snack(modo == 'externo'
          ? 'Tu cuenta externa está pendiente de aprobación por el administrador.'
          : 'Tu cuenta no está activa. Contacta al administrador.');
      await FirebaseAuth.instance.signOut();
      return false;
    }
    return true;
  }

  // --------- LOGIN: EMAIL / PASSWORD ----------
  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final email = _emailCtrl.text.trim().toLowerCase();
      final pass  = _passCtrl.text;

      if (_modoInstitucional && !_esInstitucional(email)) {
        _snack('Usa tu correo institucional @upt.pe o @virtual.upt.pe');
        return;
      }

      final methods = await _fetchSignInMethodsREST(email);
      final hasPassword = methods.contains('password');
      final hasGoogle   = methods.contains('google.com');

      // SOLO Google (ejemplo: cuenta UPT creada por Google)
      if (!hasPassword && hasGoogle) {
        _snack('Esta cuenta se registró con Google. Abriendo inicio con Google…');
        await _googleSignIn();
        return;
      }

      if (methods.isEmpty) {
        // No existe en Auth.
        if (_modoInstitucional) {
          // Institucional: forzar Google
          _snack('No existe con password. Usa “Iniciar sesión con Google”.');
          await _googleSignIn();
          return;
        } else {
          // EXTERNO: REGISTRO controlado → queda PENDIENTE hasta que admin apruebe.
          try {
            final cred = await _auth.createUserWithEmailAndPassword(
              email: email, password: pass,
            );
            // Crea doc y marca pendiente
            await _fs.collection('usuarios').doc(cred.user!.uid).set({
              'email'      : email,
              'displayName': cred.user!.displayName ?? '',
              'photoURL'   : cred.user!.photoURL ?? '',
              'domain'     : email.split('@').last,
              'modo'       : 'externo',
              'rol'        : 'estudiante',
              'estado'     : 'pendiente', // 👈 clave
              'createdAt'  : FieldValue.serverTimestamp(),
              'updateAt'   : FieldValue.serverTimestamp(),
            });
            _snack('Cuenta creada. Espera aprobación del administrador.');
            await _auth.signOut();
            return;
          } on FirebaseAuthException catch (e) {
            _snack(_mapAuthError(e));
            return;
          }
        }
      }

      // Existe con password → login
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: pass);
      final ok = await _ensureUserDocAndGuard(cred.user!);
      if (ok && mounted) await goHomeByRol(context);
    } on FirebaseAuthException catch (e) {
      _snack(_mapAuthError(e));
    } catch (_) {
      _snack('Ocurrió un error. Intenta nuevamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // --------- RESET PASSWORD ----------
  Future<void> _reset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _snack('Ingresa tu correo para recuperar la contraseña.');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _snack('Enlace de recuperación enviado a $email');
    } on FirebaseAuthException catch (e) {
      _snack(_mapAuthError(e));
    }
  }

  // --------- GOOGLE SIGN-IN (Web: POPUP, fallback REDIRECT) ----------
  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final provider = GoogleAuthProvider();

      if (kIsWeb) {
        try {
          // POPUP primero
          final cred = await FirebaseAuth.instance.signInWithPopup(provider);
          final email = cred.user?.email?.toLowerCase() ?? '';
          if (_modoInstitucional && !_esInstitucional(email)) {
            await FirebaseAuth.instance.signOut();
            _snack('Solo correos institucionales @upt.pe o @virtual.upt.pe');
            return;
          }
          final ok = await _ensureUserDocAndGuard(cred.user!);
          if (ok && mounted) await goHomeByRol(context);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'popup-blocked' ||
              e.code == 'popup-closed-by-user' ||
              e.code == 'unauthorized-domain') {
            await FirebaseAuth.instance.signInWithRedirect(provider);
            return;
          } else {
            _snack('Google: ${e.code}');
          }
        }
      } else {
        // Android/iOS/desktop
        final cred = await FirebaseAuth.instance.signInWithProvider(provider);
        final email = cred.user?.email?.toLowerCase() ?? '';
        if (_modoInstitucional && !_esInstitucional(email)) {
          await FirebaseAuth.instance.signOut();
          _snack('Solo correos institucionales @upt.pe o @virtual.upt.pe');
          return;
        }
        final ok = await _ensureUserDocAndGuard(cred.user!);
        if (ok && mounted) await goHomeByRol(context);
      }
    } on FirebaseAuthException catch (e) {
      _snack('Google: ${e.code}');
    } catch (e) {
      _snack('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return 'Correo inválido.';
      case 'user-disabled': return 'Usuario deshabilitado.';
      case 'user-not-found': return 'Usuario no registrado.';
      case 'email-already-in-use': return 'Ese correo ya está registrado.';
      case 'weak-password': return 'Contraseña muy débil (mínimo 6).';
      case 'wrong-password':
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Correo o contraseña incorrectos.';
      case 'operation-not-allowed':
        return 'El método Email/Password está deshabilitado en Firebase Auth.';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde.';
      default:
        return 'Error de autenticación: ${e.code}';
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo opcional
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg_login.jpg'),
                fit: BoxFit.cover,
                opacity: 0.32,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _buildCard(context, cs),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, ColorScheme cs) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ESCUELA PROFESIONAL DE INGENIERÍA DE SISTEMAS',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 14),
            CircleAvatar(
              radius: 40,
              backgroundColor: cs.primary.withOpacity(.1),
              child: Icon(Icons.school_rounded, color: cs.primary, size: 44),
            ),
            const SizedBox(height: 12),
            Text(
              'Acceso para docentes, estudiantes y ponentes',
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'EVENTOS EPIS – UPT',
              style: TextStyle(
                color: cs.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),

            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Institucional')),
                ButtonSegment(value: false, label: Text('Externo')),
              ],
              selected: {_modoInstitucional},
              onSelectionChanged: (s) => setState(() => _modoInstitucional = s.first),
            ),
            const SizedBox(height: 16),

            _GoogleButton(onPressed: _loading ? null : _googleSignIn),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: Divider(color: cs.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('o con correo', style: TextStyle(color: cs.onSurfaceVariant)),
                ),
                Expanded(child: Divider(color: cs.outlineVariant)),
              ],
            ),
            const SizedBox(height: 12),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: _modoInstitucional
                          ? 'usuario@virtual.upt.pe'
                          : 'correo@ejemplo.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      final email = (v ?? '').trim();
                      final re = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (email.isEmpty) return 'Ingresa tu correo';
                      if (!re.hasMatch(email)) return 'Correo inválido';
                      if (_modoInstitucional && !_esInstitucional(email)) {
                        return 'Debe ser @upt.pe o @virtual.upt.pe';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => (v ?? '').length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _loading ? null : _reset,
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _loginEmail,
                      child: _loading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Iniciar sesión'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Divider(color: cs.outlineVariant),
            const SizedBox(height: 8),

            Text.rich(
              TextSpan(
                text: 'Soporte: ',
                style: TextStyle(color: cs.onSurfaceVariant),
                children: const [
                  TextSpan(
                    text: 'eventos-epis@upt.pe',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const _GoogleButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget googleIcon() => Image.asset(
          'assets/images/google_logo.png',
          width: 18,
          height: 18,
          errorBuilder: (_, __, ___) => CircleAvatar(
            radius: 10,
            backgroundColor: Colors.white,
            child: Text(
              'G',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                fontSize: 12,
              ),
            ),
          ),
        );

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: googleIcon(),
        label: const Text('Iniciar sesión con Google'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: cs.outlineVariant),
          foregroundColor: cs.onSurface,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
