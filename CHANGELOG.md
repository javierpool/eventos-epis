# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.0.0/),
y este proyecto adhiere a [Versionado Semántico](https://semver.org/lang/es/).

## [Unreleased]

### Planeado
- Sistema de notificaciones push
- Generación automática de certificados PDF
- Exportación avanzada de reportes (Excel, PDF)
- Chat en vivo durante eventos
- Encuestas de satisfacción post-evento

---

## [1.0.0] - 2025-10-30

### 🎉 Lanzamiento Inicial

Primera versión estable del sistema de gestión de eventos EPIS-UPT.

### ✨ Agregado

#### Autenticación
- Login con correo electrónico y contraseña
- Login con Google Sign-In
- Soporte para emails institucionales @virtual.upt.pe
- Recuperación de contraseña
- Registro de nuevos usuarios
- Gestión de sesiones persistentes

#### Panel de Administración
- Dashboard con estadísticas generales
- CRUD completo de eventos
- CRUD completo de ponentes
- CRUD completo de sesiones/ponencias
- Gestión de usuarios y roles
- Asignación de permisos
- Reportes de asistencia
- Exportación de datos
- Sistema de datos de demostración (seed)

#### Panel de Estudiantes
- Vista de eventos disponibles
- Inscripción a eventos y sesiones
- Historial de participación
- Sistema de asistencia con QR
- Vista detallada de eventos
- Cancelación de inscripciones

#### Panel de Docentes
- Acceso a reportes
- Vista de eventos activos
- Estadísticas de asistencia

#### Sistema de Asistencia
- Generación de códigos QR únicos por sesión
- Escaneo de QR con cámara
- Validación de inscripción
- Control de horarios
- Registro automático en Firestore
- Prevención de duplicados

#### Gestión de Eventos
- Creación y edición de eventos
- Múltiples tipos de eventos (CATEC, Software Libre, Microsoft)
- Gestión de aforo
- Control de visibilidad
- Estados de eventos (activo, inactivo, completado)
- Asignación de ubicaciones

#### Gestión de Ponentes
- Registro de ponentes con biografía
- Carga de fotos de perfil
- Enlaces a redes sociales
- Asignación a sesiones

#### UI/UX
- Tema Material Design 3
- Diseño responsive (web, móvil, tablet)
- Navegación intuitiva por roles
- Animaciones fluidas
- Feedback visual para acciones
- Modo de carga optimizado
- Manejo de errores con mensajes claros

#### Seguridad
- Reglas de Firestore por rol
- Reglas de Storage seguras
- Validación de permisos en frontend
- Autenticación obligatoria para acciones sensibles
- Protección contra inyección XSS

### 🔧 Técnico

#### Arquitectura
- Clean Architecture con separación de capas
- Patrón Repository para servicios
- State Management con Riverpod
- Inyección de dependencias

#### Firebase
- Firestore Database configurado
- Authentication con múltiples proveedores
- Cloud Storage para imágenes
- Security Rules implementadas
- Índices de Firestore optimizados

#### Desarrollo
- Análisis estático con flutter_lints
- Formateo automático de código
- Estructura modular por features
- Modelos de datos tipados
- Manejo de errores centralizado

### 📚 Documentación

#### Documentación Completa Agregada
- README.md principal actualizado
- Guía de Instalación (INSTALLATION.md)
- Guía de Usuario (USER_GUIDE.md)
- Documentación de API (API_DOCUMENTATION.md)
- Guía de Contribución (CONTRIBUTING.md)
- Guía de Despliegue (DEPLOYMENT.md)
- Índice de Documentación (docs/README.md)
- Este Changelog

#### Assets Incluidos
- Logo horizontal
- Isotipo
- Íconos de aplicación
- Imagen de fondo de login

---

## [0.9.0] - 2025-10-25

### Beta Testing

#### Agregado
- Sistema base de eventos
- Autenticación básica
- Panel de administración inicial
- Inscripciones básicas

#### Corregido
- Problemas de permisos en Firebase
- Errores de autenticación con Google
- Bugs en formularios de eventos
- Problemas de rendimiento en listas grandes

---

## [0.5.0] - 2025-10-20

### Alpha Release

#### Agregado
- Prototipo funcional
- Firebase configurado
- Login básico
- CRUD de eventos inicial

---

## Tipos de Cambios

Los cambios se categorizan de la siguiente manera:

- **Agregado** (`Added`) - para nuevas funcionalidades
- **Cambiado** (`Changed`) - para cambios en funcionalidad existente
- **Deprecado** (`Deprecated`) - para funcionalidad que será removida
- **Removido** (`Removed`) - para funcionalidad removida
- **Corregido** (`Fixed`) - para corrección de bugs
- **Seguridad** (`Security`) - para vulnerabilidades

---

## Versionado

Usamos [SemVer](https://semver.org/lang/es/) para el versionado:

- **MAJOR** (X.0.0) - Cambios incompatibles con versiones anteriores
- **MINOR** (0.X.0) - Nuevas funcionalidades compatible con versiones anteriores
- **PATCH** (0.0.X) - Corrección de bugs

---

## Enlaces

- [Repositorio](https://github.com/javierpool/eventos-epis)
- [Issues](https://github.com/javierpool/eventos-epis/issues)
- [Pull Requests](https://github.com/javierpool/eventos-epis/pulls)
- [Documentación](docs/README.md)

---

**Universidad Privada de Tacna**  
Escuela Profesional de Ingeniería de Sistemas

