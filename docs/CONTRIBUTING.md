# 🤝 Guía de Contribución - EVENTOS EPIS

¡Gracias por tu interés en contribuir al proyecto EVENTOS EPIS! Esta guía te ayudará a comenzar.

## 📋 Tabla de Contenidos

- [Código de Conducta](#-código-de-conducta)
- [Cómo Puedo Contribuir](#-cómo-puedo-contribuir)
- [Configuración del Entorno](#-configuración-del-entorno)
- [Flujo de Trabajo](#-flujo-de-trabajo)
- [Estándares de Código](#-estándares-de-código)
- [Commits y Pull Requests](#-commits-y-pull-requests)
- [Reportar Bugs](#-reportar-bugs)
- [Sugerir Mejoras](#-sugerir-mejoras)

---

## 📜 Código de Conducta

Este proyecto sigue un código de conducta que todos los contribuyentes deben respetar:

### Nuestros Valores

- **Respeto**: Trata a todos con respeto y consideración
- **Colaboración**: Trabaja en equipo y ayuda a otros
- **Profesionalismo**: Mantén un ambiente profesional
- **Inclusión**: Todos son bienvenidos sin importar su experiencia

### Comportamiento Inaceptable

- Lenguaje ofensivo o discriminatorio
- Acoso de cualquier tipo
- Publicación de información privada de terceros
- Comportamiento disruptivo

---

## 💡 Cómo Puedo Contribuir

### Tipos de Contribuciones

1. **Reportar Bugs**
   - Encuentra y reporta errores
   - Proporciona pasos para reproducir el problema

2. **Sugerir Mejoras**
   - Propón nuevas características
   - Mejora la documentación
   - Optimiza el rendimiento

3. **Escribir Código**
   - Corrige bugs
   - Implementa nuevas características
   - Mejora código existente

4. **Revisar Pull Requests**
   - Revisa código de otros contribuyentes
   - Prueba cambios propuestos
   - Proporciona feedback constructivo

5. **Mejorar Documentación**
   - Corrige errores tipográficos
   - Añade ejemplos
   - Traduce documentación

---

## 🛠️ Configuración del Entorno

### 1. Fork y Clone

```bash
# Fork el repositorio en GitHub
# Luego clona tu fork

git clone https://github.com/TU-USUARIO/eventos-epis.git
cd eventos-epis

# Añade el repositorio original como upstream
git remote add upstream https://github.com/javierpool/eventos-epis.git
```

### 2. Instala Dependencias

```bash
# Flutter
flutter pub get

# Firebase Functions (si contribuyes al backend)
cd functions
npm install
cd ..
```

### 3. Configura Pre-commit Hooks

Crea `.git/hooks/pre-commit`:

```bash
#!/bin/sh

# Analizar código
flutter analyze

# Formatear código
dart format lib/ test/

# Ejecutar tests
flutter test

if [ $? -ne 0 ]; then
  echo "❌ Pre-commit checks failed"
  exit 1
fi

echo "✅ Pre-commit checks passed"
```

Hazlo ejecutable:
```bash
chmod +x .git/hooks/pre-commit
```

### 4. Configura tu IDE

#### VS Code

Instala extensiones recomendadas:
- Flutter
- Dart
- GitLens
- Error Lens

Configuración en `.vscode/settings.json`:

```json
{
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  },
  "[dart]": {
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": false
  }
}
```

---

## 🔄 Flujo de Trabajo

### 1. Sincroniza con Upstream

```bash
git checkout main
git fetch upstream
git merge upstream/main
git push origin main
```

### 2. Crea una Rama

```bash
# Nomenclatura: tipo/descripcion-breve
# Tipos: feature, bugfix, hotfix, docs, refactor

# Ejemplo para nueva característica
git checkout -b feature/agregar-notificaciones

# Ejemplo para corrección de bug
git checkout -b bugfix/corregir-login-error

# Ejemplo para documentación
git checkout -b docs/actualizar-readme
```

### 3. Realiza Cambios

```bash
# Haz tus cambios
# Asegúrate de seguir los estándares de código

# Verifica tus cambios
flutter analyze
flutter test
```

### 4. Commit y Push

```bash
git add .
git commit -m "feat: agregar sistema de notificaciones push"
git push origin feature/agregar-notificaciones
```

### 5. Crea Pull Request

1. Ve a GitHub
2. Crea Pull Request desde tu rama a `main`
3. Completa la plantilla de PR
4. Espera revisión

---

## 📏 Estándares de Código

### Convenciones de Nomenclatura

#### Archivos y Carpetas

```dart
// Archivos: snake_case
user_service.dart
event_list_widget.dart

// Carpetas: snake_case
lib/features/admin/
lib/services/
```

#### Clases y Tipos

```dart
// Clases: PascalCase
class EventService { }
class AppUser { }

// Interfaces: PascalCase con prefijo "I" (opcional)
abstract class IAuthService { }
```

#### Variables y Funciones

```dart
// Variables: camelCase
String userName = 'Juan';
int totalEvents = 0;

// Funciones: camelCase
void getUserById() { }
Future<Event> fetchEventData() { }

// Constantes: camelCase o UPPER_SNAKE_CASE
const maxUsers = 100;
const MAX_FILE_SIZE = 1024 * 1024;
```

#### Privadas

```dart
// Variables y métodos privados: prefijo _
String _privateVariable;
void _privateMethod() { }
```

### Estructura de Archivos

```dart
// 1. Imports - ordenados alfabéticamente
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

// 2. Constantes
const String kAppName = 'EVENTOS EPIS';

// 3. Clase principal
class MyWidget extends StatelessWidget {
  // 3.1 Campos
  final String title;
  final VoidCallback? onPressed;

  // 3.2 Constructor
  const MyWidget({
    Key? key,
    required this.title,
    this.onPressed,
  }) : super(key: key);

  // 3.3 Métodos públicos
  @override
  Widget build(BuildContext context) {
    return _buildContent();
  }

  // 3.4 Métodos privados
  Widget _buildContent() {
    return Container();
  }
}
```

### Documentación de Código

```dart
/// Servicio para gestionar eventos.
///
/// Este servicio proporciona métodos para CRUD de eventos
/// y manejo de sesiones asociadas.
///
/// Ejemplo:
/// ```dart
/// final eventService = EventService();
/// final events = await eventService.getAllEvents();
/// ```
class EventService {
  /// Obtiene todos los eventos activos.
  ///
  /// Retorna un Stream de [List<Event>] ordenados por fecha.
  /// Lanza [FirebaseException] si hay error de conexión.
  Stream<List<Event>> getAllEvents() {
    // Implementación
  }
}
```

### Manejo de Errores

```dart
// ✅ Bueno: Específico y manejado
try {
  await eventService.createEvent(event);
} on FirebaseException catch (e) {
  print('Error de Firebase: ${e.message}');
  rethrow;
} catch (e) {
  print('Error inesperado: $e');
  rethrow;
}

// ❌ Malo: Genérico y silenciado
try {
  await eventService.createEvent(event);
} catch (e) {
  // No hacer nada
}
```

### Widgets

```dart
// ✅ Bueno: Widgets pequeños y reutilizables
class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    Key? key,
    required this.event,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(event.name),
        subtitle: Text(event.description),
        onTap: onTap,
      ),
    );
  }
}

// ❌ Malo: Widget gigante con múltiples responsabilidades
class EventScreen extends StatefulWidget {
  // 500+ líneas de código...
}
```

### Performance

```dart
// ✅ Bueno: Usar const constructors cuando sea posible
const Text('Hola Mundo')
const SizedBox(height: 16)

// ✅ Bueno: Extraer widgets que no cambian
final _staticHeader = const Header();

// ❌ Malo: Reconstruir widgets estáticos
Text('Hola Mundo')
```

---

## 📝 Commits y Pull Requests

### Formato de Commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org/):

```
<tipo>[ámbito opcional]: <descripción>

[cuerpo opcional]

[footer(s) opcional]
```

#### Tipos de Commits

- `feat`: Nueva característica
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formateo, punto y coma faltantes, etc.
- `refactor`: Refactorización de código
- `test`: Añadir o modificar tests
- `chore`: Cambios en build, dependencias, etc.
- `perf`: Mejoras de rendimiento

#### Ejemplos

```bash
# Nueva característica
git commit -m "feat: agregar sistema de notificaciones push"

# Corrección de bug
git commit -m "fix: corregir error en login con Google"

# Documentación
git commit -m "docs: actualizar guía de instalación"

# Con ámbito
git commit -m "feat(admin): agregar panel de estadísticas"

# Con cuerpo
git commit -m "fix: corregir validación de email

El regex anterior no validaba correctamente emails institucionales.
Se actualiza para permitir @virtual.upt.pe y @upt.edu.pe"

# Breaking change
git commit -m "feat!: cambiar estructura de modelo User

BREAKING CHANGE: El campo 'rol' ahora es 'role'"
```

### Plantilla de Pull Request

Al crear un PR, usa esta plantilla:

```markdown
## Descripción

Descripción breve de los cambios.

## Tipo de Cambio

- [ ] Bug fix (corrección de error)
- [ ] Nueva característica (feature)
- [ ] Breaking change (cambio que rompe compatibilidad)
- [ ] Documentación
- [ ] Refactorización

## ¿Cómo se ha probado?

Describe las pruebas realizadas.

- [ ] Test unitarios
- [ ] Test de integración
- [ ] Test manual

## Checklist

- [ ] Mi código sigue los estándares del proyecto
- [ ] He realizado auto-revisión del código
- [ ] He comentado código complejo
- [ ] He actualizado la documentación
- [ ] Mis cambios no generan warnings
- [ ] He añadido tests
- [ ] Tests nuevos y existentes pasan localmente
- [ ] He verificado en dispositivos Android/iOS/Web

## Screenshots (si aplica)

Añade capturas de pantalla.

## Issues Relacionados

Cierra #123
Relacionado con #456
```

---

## 🐛 Reportar Bugs

### Antes de Reportar

1. Verifica que no sea un duplicado
2. Asegúrate de usar la última versión
3. Intenta reproducir en un entorno limpio

### Plantilla de Bug Report

```markdown
## Descripción del Bug

Descripción clara y concisa.

## Para Reproducir

Pasos para reproducir:
1. Ve a '...'
2. Haz clic en '....'
3. Scroll hasta '....'
4. Ver error

## Comportamiento Esperado

Qué esperabas que sucediera.

## Capturas de Pantalla

Si aplica, añade capturas.

## Entorno

- OS: [e.g. Windows 11, macOS 14]
- Flutter: [e.g. 3.32.8]
- Dart: [e.g. 3.8.1]
- Dispositivo: [e.g. Pixel 7, iPhone 14]
- Navegador (si web): [e.g. Chrome 120]

## Logs

```
Pega aquí logs relevantes
```

## Contexto Adicional

Cualquier otra información relevante.
```

---

## 💡 Sugerir Mejoras

### Plantilla de Feature Request

```markdown
## ¿Está relacionado con un problema?

Descripción clara del problema. Ej: "Es frustrante cuando..."

## Solución Propuesta

Descripción clara de lo que quieres que suceda.

## Alternativas Consideradas

Otras soluciones que has considerado.

## Contexto Adicional

Mockups, ejemplos, referencias, etc.
```

---

## 🧪 Tests

### Escribir Tests

```dart
// test/services/event_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:eventos/services/event_service.dart';

void main() {
  group('EventService', () {
    late EventService eventService;

    setUp(() {
      eventService = EventService();
    });

    test('debe crear un evento correctamente', () async {
      final event = Event(
        name: 'Test Event',
        // ... otros campos
      );

      final eventId = await eventService.createEvent(event);

      expect(eventId, isNotEmpty);
    });

    test('debe lanzar error con datos inválidos', () async {
      final event = Event(name: ''); // Inválido

      expect(
        () => eventService.createEvent(event),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

### Ejecutar Tests

```bash
# Todos los tests
flutter test

# Test específico
flutter test test/services/event_service_test.dart

# Con coverage
flutter test --coverage

# Ver reporte de coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📞 Contacto

¿Preguntas sobre cómo contribuir?

- **Email**: eventos-epis@upt.pe
- **GitHub Discussions**: [Discussions](https://github.com/javierpool/eventos-epis/discussions)
- **Issues**: [Issues](https://github.com/javierpool/eventos-epis/issues)

---

## 🎉 ¡Gracias!

Gracias por contribuir a EVENTOS EPIS. Tu ayuda es invaluable para mejorar este proyecto.

---

**Universidad Privada de Tacna**  
Escuela Profesional de Ingeniería de Sistemas

*Última actualización: Octubre 2025*

