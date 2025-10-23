// lib/app/router_by_rol.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Importa los NOMBRES REALES de las pantallas
import '../features/admin/admin_home_screen.dart';     // clase: AdminHomeScreen
import '../features/events/event_list_screen.dart';    // clase: EventListScreen

// Temporales si aún no tienes estas pantallas
class DocenteHome extends StatelessWidget {
  const DocenteHome({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Panel Docente')));
}

class PonenteHome extends StatelessWidget {
  const PonenteHome({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Panel Ponente')));
}

/// Crea doc por defecto si no existe (rol: estudiante)
Future<Map<String, dynamic>> _ensureUserDoc(User u) async {
  final ref = FirebaseFirestore.instance.collection('usuarios').doc(u.uid);
  final snap = await ref.get();

  if (!snap.exists) {
    final data = {
      'email': u.email ?? '',
      'displayName': u.displayName,
      'rol': 'estudiante',
      'active': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }..removeWhere((k, v) => v == null);

    await ref.set(data, SetOptions(merge: true));
    return data;
  }

  final data = snap.data() ?? {};
  if (!data.containsKey('rol')) {
    await ref.set(
      {'rol': 'estudiante', 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    data['rol'] = 'estudiante';
  }
  return data;
}

/// Lee `usuarios/{uid}` y navega según `rol`.
Future<void> goHomeByRol(BuildContext context) async {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) return;

  try {
    final data = await _ensureUserDoc(u);
    final rol = (data['rol'] ?? 'estudiante').toString().toLowerCase();

    Widget home;
    switch (rol) {
      case 'admin':
        home = const AdminHomeScreen();
        break;
      case 'docente':
        home = const DocenteHome();
        break;
      case 'ponente':
        home = const PonenteHome();
        break;
      case 'estudiante':
      default:
        home = const EventListScreen();
        break;
    }

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => home),
        (_) => false,
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo determinar el rol: $e')),
    );
  }
}
