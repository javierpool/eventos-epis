// lib/app/router_by_rol.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/firestore_paths.dart';
import '../features/admin/admin_home_screen.dart';
import '../features/events/student_home_screen.dart';

// Stubs (si los tienes ya, quita esto)
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

// Función que devuelve el widget según el rol (para AuthWrapper)
Future<Widget> goHomeByRolWidget(BuildContext context, User user) async {
  try {
    // ignore: avoid_print
    print('[router_by_rol] uid=${user.uid} email=${user.email}');

    final ref = FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(user.uid);

    final snap = await ref.get(const GetOptions(source: Source.server));
    if (!snap.exists) {
      // ignore: avoid_print
      print('[router_by_rol] Documento NO existe: usuarios/${user.uid}');
      // Crear documento si no existe
      await ref.set({
        'email': user.email?.toLowerCase() ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'role': 'estudiante',
        'rol': 'estudiante',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const StudentHomeScreen();
    }

    final data = Map<String, dynamic>.from(snap.data() ?? {});
    final roleRaw = (data['role'] ?? data['rol'])?.toString() ?? 'estudiante';
    final role = roleRaw.toLowerCase().trim();
    final active = (data['active'] ?? true) == true;

    // ignore: avoid_print
    print('[router_by_rol] role="$role" active=$active');

    if (!active) {
      await FirebaseAuth.instance.signOut();
      return const Scaffold(
        body: Center(
          child: Text('Tu cuenta está pendiente de activación.'),
        ),
      );
    }

    return switch (role) {
      'admin'   => const AdminHomeScreen(),
      'docente' => const DocenteHome(),
      'ponente' => const PonenteHome(),
      _         => const StudentHomeScreen(),
    };
  } catch (e) {
    // ignore: avoid_print
    print('[router_by_rol] Error: $e');
    return const Scaffold(
      body: Center(
        child: Text('Error al cargar tu perfil'),
      ),
    );
  }
}

// Función original de navegación (compatible con el código existente)
Future<void> goHomeByRol(BuildContext context) async {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) return;

  try {
    // ignore: avoid_print
    print('[router_by_rol] uid=${u.uid} email=${u.email}');

    if (FirestorePaths.users != 'usuarios') {
      // ignore: avoid_print
      print('[router_by_rol] FirestorePaths.users = ${FirestorePaths.users}  (DEBE SER "usuarios")');
    }

    final ref = FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(u.uid);

    final snap = await ref.get(const GetOptions(source: Source.server));
    if (!snap.exists) {
      // ignore: avoid_print
      print('[router_by_rol] Documento NO existe: usuarios/${u.uid}');
      throw 'No existe tu perfil en Firestore (usuarios/${u.uid}).';
    }

    final data = Map<String, dynamic>.from(snap.data() ?? {});
    final roleRaw = (data['role'] ?? data['rol'])?.toString() ?? 'estudiante';
    final role = roleRaw.toLowerCase().trim();
    final active = (data['active'] ?? true) == true;

    // ignore: avoid_print
    print('[router_by_rol] data=$data');
    // ignore: avoid_print
    print('[router_by_rol] role="$role" active=$active');

    if (!active) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu cuenta está pendiente de activación.')),
      );
      await FirebaseAuth.instance.signOut();
      return;
    }

    final Widget home = switch (role) {
      'admin'   => const AdminHomeScreen(),
      'docente' => const DocenteHome(),
      'ponente' => const PonenteHome(),
      _         => const StudentHomeScreen(),
    };

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => home),
      (_) => false,
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo determinar el rol: $e')),
    );
  }
}
