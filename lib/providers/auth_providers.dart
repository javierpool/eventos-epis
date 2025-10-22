import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/auth_providers.dart';
import 'pantalla_login.dart';

class PantallaPerfil extends ConsumerStatefulWidget {
  const PantallaPerfil({super.key});

  static const routeName = '/perfil';

  @override
  ConsumerState<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends ConsumerState<PantallaPerfil> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  Uint8List? _fotoTemporal;
  String? _fotoNombre;
  String? _fotoContentType;
  bool _datosInicialesAsignados = false;

  @override
  void initState() {
    super.initState();

    ref.listen<AuthOperationState>(authControllerProvider, (previous, next) {
      if (!mounted) return;

      if (next.errorMessage != null && next.errorMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.errorMessage!)),
          );
      } else if (next.infoMessage != null && next.infoMessage!.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.infoMessage!)),
          );

        setState(() {
          _fotoTemporal = null;
          _fotoNombre = null;
          _fotoContentType = null;
        });
      }
    });

    ref.listen<AsyncValue<Map<String, dynamic>?>>(userDataProvider, (previous, next) {
      next.whenData((data) {
        if (!mounted) {
          return;
        }

        final nombre = (data?['nombre'] ?? '') as String;
        final telefono = data?['telefono']?.toString() ?? '';

        if (!_datosInicialesAsignados || _nombreController.text != nombre) {
          _nombreController.text = nombre;
        }

        if (!_datosInicialesAsignados || _telefonoController.text != telefono) {
          _telefonoController.text = telefono;
        }

        _datosInicialesAsignados = true;
      });
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (pickedFile == null) {
      return;
    }

    final bytes = await pickedFile.readAsBytes();

    if (!mounted) {
      return;
    }

    setState(() {
      _fotoTemporal = bytes;
      _fotoNombre = pickedFile.name;
      _fotoContentType = _contentTypeFromName(pickedFile.name);
    });
  }

  String _contentTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.bmp')) return 'image/bmp';
    return 'image/jpeg';
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    await ref.read(authControllerProvider.notifier).updateProfile(
          nombre: _nombreController.text.trim(),
          telefono: _telefonoController.text.trim().isEmpty
              ? null
              : _telefonoController.text.trim(),
          fotoBytes: _fotoTemporal,
          contentType: _fotoContentType,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateChangesProvider);
    final operacionAuth = ref.watch(authControllerProvider);

    return authAsync.when(
      data: (user) {
        if (user == null) {
          return const PantallaLogin();
        }

        final userDataAsync = ref.watch(userDataProvider);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mi perfil'),
            actions: [
              IconButton(
                tooltip: 'Cerrar sesión',
                onPressed: operacionAuth.isLoading
                    ? null
                    : () => ref.read(authControllerProvider.notifier).signOut(),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: userDataAsync.when(
            data: (data) {
              final fotoUrl = data?['fotoUrl'] as String? ?? user.photoURL;
              final rol = data?['rol']?.toString() ?? 'sin rol';
              final dominioValido = data?['dominioValido'] == true;
              final autorizado = data?['autorizado'] == true;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 56,
                              backgroundImage: _fotoTemporal != null
                                  ? MemoryImage(_fotoTemporal!)
                                  : (fotoUrl != null && fotoUrl.isNotEmpty)
                                      ? NetworkImage(fotoUrl)
                                          as ImageProvider<Object>
                                      : null,
                              child: (_fotoTemporal == null && (fotoUrl == null || fotoUrl.isEmpty))
                                  ? const Icon(Icons.person_outline, size: 48)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 4,
                              child: FloatingActionButton.small(
                                heroTag: 'editar_foto',
                                onPressed: operacionAuth.isLoading ? null : _seleccionarFoto,
                                child: const Icon(Icons.photo_camera_outlined),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_fotoNombre != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Foto seleccionada: $_fotoNombre',
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        alignment: WrapAlignment.start,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.verified_user, size: 18),
                            label: Text(rol.toUpperCase()),
                          ),
                          Chip(
                            avatar: const Icon(Icons.domain_verification_outlined, size: 18),
                            label: Text(
                              dominioValido ? 'Dominio UPT válido' : 'Dominio externo',
                            ),
                          ),
                          Chip(
                            avatar: Icon(
                              autorizado ? Icons.check_circle_outline : Icons.pending_outlined,
                              size: 18,
                            ),
                            label: Text(
                              autorizado ? 'Cuenta aprobada' : 'Pendiente de aprobación',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nombreController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Nombre completo',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _telefonoController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: user.email,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: operacionAuth.isLoading ? null : _guardarCambios,
                        icon: operacionAuth.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text('Guardar cambios'),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'No fue posible cargar tu información.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text('$error', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: operacionAuth.isLoading
                          ? null
                          : () => ref.read(authControllerProvider.notifier).signOut(),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar sesión'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Ocurrió un problema al autenticarse.',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text('$error', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}