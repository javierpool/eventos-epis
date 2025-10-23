import 'package:flutter/material.dart';
import '../../../services/user_service.dart';
import '../../../models/app_user.dart';
import '../forms/user_form.dart' show UserFormDialog;

class UsersList extends StatelessWidget {
  const UsersList({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = UserService();
    return StreamBuilder<List<AppUser>>(
      stream: svc.watchAll(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final users = snap.data!;
        if (users.isEmpty) return const Center(child: Text('Sin usuarios'));
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final u = users[i];
            return ListTile(
              title: Text(u.displayName ?? u.email),
              subtitle: Text('${u.email} • rol: ${u.role ?? u.rol} • activo: ${u.active ? "sí" : "no"}'
                  '${u.isInstitutional == true ? " • institucional" : ""}'),
              trailing: PopupMenuButton<String>(
                itemBuilder: (_) => const [
                  PopupMenuItem<String>(value: 'role_docente',   child: Text('Hacer DOCENTE')),
                  PopupMenuItem<String>(value: 'role_ponente',   child: Text('Hacer PONENTE')),
                  PopupMenuItem<String>(value: 'role_encargado', child: Text('Hacer ENCARGADO')),
                  PopupMenuItem<String>(value: 'role_estudiante',child: Text('Hacer ESTUDIANTE')),
                  PopupMenuItem<String>(value: 'toggle_active',  child: Text('Activar/Desactivar')),
                ],
                onSelected: (v) async {
                  if (v.startsWith('role_')) {
                    final role = v.split('_').last;
                    await svc.setRole(u.uid, role);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('Rol de ${u.email} → $role')));
                    }
                  } else if (v == 'toggle_active') {
                    await svc.setActive(u.uid, !u.active);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
