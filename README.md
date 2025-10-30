# EVENTOS EPIS - UPT

Sistema de gestión de eventos para la Escuela Profesional de Ingeniería de Sistemas de la Universidad Privada de Tacna.

## 📱 Descripción

Aplicación Flutter multiplataforma para gestionar eventos académicos, ponencias, inscripciones y asistencia de estudiantes, docentes y ponentes.

## ✨ Características

### 👥 Roles de Usuario

- **Administrador**: Gestión completa de eventos, ponentes, sesiones y usuarios
- **Estudiante**: Inscripción a eventos, visualización de ponencias y historial
- **Docente**: Acceso a reportes y gestión de eventos
- **Ponente**: Visualización de sus ponencias programadas

### 🎯 Funcionalidades Principales

#### Panel de Administración
- ✅ Gestión de eventos (CATEC, Software Libre, Microsoft, etc.)
- ✅ Administración de ponentes con información detallada
- ✅ Creación y edición de sesiones/ponencias
- ✅ Control de usuarios y roles
- ✅ Reportes y estadísticas
- ✅ Datos de demostración (seed)

#### Para Estudiantes
- ✅ Visualización de eventos disponibles
- ✅ Inscripción a ponencias
- ✅ Historial de participación
- ✅ Generación de códigos QR para asistencia
- ✅ Vista detallada de eventos y sesiones

#### Autenticación
- ✅ Login con correo y contraseña (usuarios externos)
- ✅ Login con Google (usuarios institucionales @virtual.upt.pe)
- ✅ Recuperación de contraseña
- ✅ Registro de nuevos usuarios

#### Sistema de Asistencia
- ✅ Generación de QR por sesión
- ✅ Escaneo de QR para registro de asistencia
- ✅ Control de aforo

## 🚀 Tecnologías

- **Framework**: Flutter 3.32.8 / Dart 3.8.1
- **Backend**: Firebase
  - Authentication (Email/Password + Google Sign-In)
  - Firestore Database
  - Cloud Storage
  - Cloud Functions
- **State Management**: Riverpod
- **UI**: Material Design 3

## 📦 Dependencias Principales

```yaml
firebase_core: ^4.2.0
firebase_auth: ^6.1.1
cloud_firestore: ^6.0.3
firebase_storage: ^13.0.3
flutter_riverpod: ^3.0.3
google_fonts: ^6.3.2
google_sign_in: ^7.2.0
qr_flutter: ^4.1.0
mobile_scanner: ^7.1.2
```

## 🛠️ Instalación Rápida

Para comenzar rápidamente:

```bash
# 1. Clonar el repositorio
git clone https://github.com/javierpool/eventos-epis.git
cd eventos-epis

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar la aplicación
flutter run
```

**📖 Para instrucciones completas de instalación y configuración, ver [Guía de Instalación](docs/INSTALLATION.md)**

## 📁 Estructura del Proyecto

```
lib/
├── app/                    # Configuración de la app
│   ├── app_theme.dart      # Tema Material Design
│   ├── router_by_rol.dart  # Navegación por roles
│   └── utils.dart
├── features/               # Características por módulos
│   ├── admin/             # Panel de administración
│   │   ├── forms/         # Formularios
│   │   ├── models/        # Modelos de datos
│   │   ├── services/      # Servicios de Firebase
│   │   └── widgets/       # Widgets reutilizables
│   ├── auth/              # Autenticación
│   ├── events/            # Gestión de eventos
│   ├── student/           # Panel de estudiantes
│   └── attendance/        # Sistema de asistencia QR
├── models/                # Modelos globales
├── services/              # Servicios compartidos
└── main.dart              # Punto de entrada
```

## 🔐 Configuración de Seguridad

### Reglas de Firestore Recomendadas

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Eventos: lectura pública, escritura solo admins
    match /eventos/{eventId} {
      allow read: if true;
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Usuarios: lectura propia o admin
    match /usuarios/{userId} {
      allow read: if request.auth != null && 
                     (request.auth.uid == userId || 
                      get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.role == 'admin');
      allow write: if request.auth != null && 
                      get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## 👥 Usuarios de Prueba

Para crear el primer usuario admin, registra un usuario y luego modifica su rol en Firestore:

```javascript
// Ir a Firestore > usuarios > [tu-usuario-id]
{
  "email": "admin@virtual.upt.pe",
  "role": "admin",
  "rol": "admin",
  "active": true
}
```

## 🎨 Capturas de Pantalla

_(Agrega capturas de pantalla de tu aplicación aquí)_

---

## 📚 Documentación Completa

Este proyecto cuenta con documentación detallada para diferentes audiencias:

### Para Usuarios

- **[📖 Guía de Usuario](docs/USER_GUIDE.md)** - Cómo usar la aplicación paso a paso
  - Panel de Administrador
  - Panel de Estudiante
  - Panel de Docente
  - Sistema de Asistencia QR
  - Preguntas Frecuentes

### Para Desarrolladores

- **[🛠️ Guía de Instalación](docs/INSTALLATION.md)** - Configuración del entorno de desarrollo
  - Requisitos del sistema
  - Instalación paso a paso
  - Configuración de Firebase
  - Solución de problemas

- **[🔧 Documentación de API](docs/API_DOCUMENTATION.md)** - Documentación técnica completa
  - Arquitectura del sistema
  - Modelos de datos
  - Servicios y APIs
  - Firebase Collections
  - Cloud Functions
  - Ejemplos de uso

- **[🤝 Guía de Contribución](docs/CONTRIBUTING.md)** - Cómo contribuir al proyecto
  - Código de conducta
  - Estándares de código
  - Flujo de trabajo con Git
  - Guías de commits
  - Tests y calidad

- **[🚀 Guía de Despliegue](docs/DEPLOYMENT.md)** - Despliegue en producción
  - Despliegue Web (Firebase, Netlify, Vercel)
  - Despliegue Android (Play Store)
  - Despliegue iOS (App Store)
  - Despliegue Windows (Microsoft Store)
  - CI/CD con GitHub Actions
  - Monitoreo y mantenimiento

---

## 📝 Notas de Desarrollo

- **AuthWrapper**: Maneja automáticamente el estado de autenticación y redirección por roles
- **Timestamp de Firebase**: Todas las fechas se guardan con `serverTimestamp()` para consistencia
- **Formato de fechas**: Se muestra tiempo relativo (ej: "Hace 2 horas") para mejor UX
- **Validaciones**: Emails institucionales solo para @virtual.upt.pe

## 🐛 Problemas Conocidos

- Chrome en Windows puede tener problemas de conexión en debug. Usar Edge o Windows desktop.
- En Windows, habilitar "Modo Desarrollador" para symlinks.

## 🤝 Contribuir

¿Quieres contribuir al proyecto? ¡Excelente! 

Lee nuestra **[Guía de Contribución](docs/CONTRIBUTING.md)** para conocer:
- Cómo configurar tu entorno
- Estándares de código
- Proceso de Pull Requests
- Cómo reportar bugs
- Cómo sugerir mejoras

Pasos rápidos:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'feat: add amazing feature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto es privado y pertenece a la Universidad Privada de Tacna - EPIS.

## 👨‍💻 Autor

Desarrollado para la Escuela Profesional de Ingeniería de Sistemas - UPT

## 📧 Soporte

Para soporte técnico: eventos-epis@upt.pe

---

**Universidad Privada de Tacna**  
Escuela Profesional de Ingeniería de Sistemas
