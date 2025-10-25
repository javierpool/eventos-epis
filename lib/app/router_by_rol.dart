// lib/app/router_by_rol.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/firestore_paths.dart';
import '../core/constants.dart';
import '../core/error_handler.dart';
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

/// Determina si un usuario debería ser admin automáticamente
/// 
/// TEMPORAL: Configura aquí los emails que deberían ser admin
bool _shouldBeAdmin(String? email) {
  if (email == null) return false;
  
  final emailLower = email.toLowerCase().trim();
  
  // Lista de emails que deberían ser admin
  const adminEmails = [
    // Agrega aquí tu email de administrador
    // Ejemplo: 'admin@virtual.upt.pe',
  ];
  
  // Si está en la lista de admins
  if (adminEmails.contains(emailLower)) return true;
  
  // TEMPORAL: El primer usuario con email institucional es admin
  // (Puedes comentar esto después de configurar el primer admin)
  if (emailLower.endsWith('@virtual.upt.pe')) {
    // Solo para el primer usuario - después comenta esto
    return true;
  }
  
  return false;
}

/// Función que devuelve el widget de home según el rol del usuario
/// 
/// Esta función es usada por [AuthWrapper] para determinar a qué pantalla
/// redirigir al usuario después de autenticarse.
Future<Widget> goHomeByRolWidget(BuildContext context, User user) async {
  try {
    AppLogger.info('Determinando pantalla home para ${user.email}');

    final ref = FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(user.uid);

    final snap = await ref.get(const GetOptions(source: Source.server));
    
    if (!snap.exists) {
      AppLogger.warning('Documento de usuario no existe, creando: ${user.uid}');
      
      // TEMPORAL: Auto-asignar admin al primer usuario o a emails específicos
      final isAutoAdmin = _shouldBeAdmin(user.email);
      
      // Crear documento si no existe
      await ref.set({
        'email': user.email?.toLowerCase() ?? '',
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'role': isAutoAdmin ? UserRoles.admin : UserRoles.student,
        'rol': isAutoAdmin ? UserRoles.admin : UserRoles.student,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      if (isAutoAdmin) {
        AppLogger.success('✨ Usuario creado como ADMINISTRADOR: ${user.email}');
        return const AdminHomeScreen();
      }
      
      AppLogger.success('Usuario creado como estudiante: ${user.email}');
      return const StudentHomeScreen();
    }

    final data = Map<String, dynamic>.from(snap.data() ?? {});
    
    // TEMPORAL: Actualizar a admin si el usuario debería serlo pero no lo es
    final isAutoAdmin = _shouldBeAdmin(user.email);
    final currentRole = (data['role'] ?? data['rol'])?.toString() ?? UserRoles.student;
    
    if (isAutoAdmin && currentRole.toLowerCase() != UserRoles.admin) {
      AppLogger.info('🔄 Actualizando usuario a ADMIN: ${user.email}');
      await ref.update({
        'role': UserRoles.admin,
        'rol': UserRoles.admin,
        'active': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      AppLogger.success('✅ Usuario actualizado a ADMINISTRADOR');
      return const AdminHomeScreen();
    }
    
    final roleRaw = (data['role'] ?? data['rol'])?.toString() ?? UserRoles.student;
    final role = roleRaw.toLowerCase().trim();
    final active = (data['active'] ?? true) == true;

    AppLogger.debug('Usuario ${user.email}: role=$role, active=$active');

    if (!active) {
      AppLogger.warning('Cuenta inactiva: ${user.email}');
      await FirebaseAuth.instance.signOut();
      return const Scaffold(
        body: Center(
          child: Text('Tu cuenta está pendiente de activación.'),
        ),
      );
    }

    final Widget home = switch (role) {
      UserRoles.admin   => const AdminHomeScreen(),
      UserRoles.teacher => const DocenteHome(),
      UserRoles.speaker => const PonenteHome(),
      _                 => const StudentHomeScreen(),
    };
    
    AppLogger.success('Redirigiendo a pantalla: ${home.runtimeType}');
    return home;
  } catch (e, st) {
    AppLogger.error('Error al determinar rol de usuario', e, st);
    return Scaffold(
      body: Center(
        child: Text('Error al cargar tu perfil: ${ErrorHandler.handleError(e)}'),
      ),
    );
  }
}

/// Función de navegación imperativa (compatible con el código existente)
/// 
/// Esta función navega programáticamente a la pantalla de home según el rol.
/// Usa [Navigator.pushAndRemoveUntil] para eliminar el stack de navegación.
Future<void> goHomeByRol(BuildContext context) async {
  final u = FirebaseAuth.instance.currentUser;
  if (u == null) {
    AppLogger.warning('goHomeByRol llamado sin usuario autenticado');
    return;
  }

  try {
    AppLogger.info('Navegando por rol para usuario: ${u.email}');

    final ref = FirebaseFirestore.instance
        .collection(FirestorePaths.users)
        .doc(u.uid);

    final snap = await ref.get(const GetOptions(source: Source.server));
    
    if (!snap.exists) {
      AppLogger.error('Perfil de usuario no encontrado: ${u.uid}');
      throw 'No existe tu perfil en Firestore.';
    }

    final data = Map<String, dynamic>.from(snap.data() ?? {});
    final roleRaw = (data['role'] ?? data['rol'])?.toString() ?? UserRoles.student;
    final role = roleRaw.toLowerCase().trim();
    final active = (data['active'] ?? true) == true;

    AppLogger.debug('Datos de usuario: role=$role, active=$active');

    if (!active) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu cuenta está pendiente de activación.')),
      );
      await FirebaseAuth.instance.signOut();
      AppLogger.warning('Cuenta inactiva, sesión cerrada');
      return;
    }

    final Widget home = switch (role) {
      UserRoles.admin   => const AdminHomeScreen(),
      UserRoles.teacher => const DocenteHome(),
      UserRoles.speaker => const PonenteHome(),
      _                 => const StudentHomeScreen(),
    };

    if (!context.mounted) return;
    
    AppLogger.success('Navegando a: ${home.runtimeType}');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => home),
      (_) => false,
    );
  } catch (e, st) {
    AppLogger.error('Error al navegar por rol', e, st);
    
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ErrorHandler.handleError(e))),
    );
  }
}
