# 🔧 Documentación de API - EVENTOS EPIS

Documentación técnica de servicios, modelos de datos y arquitectura del sistema.

## 📑 Tabla de Contenidos

- [Arquitectura del Sistema](#-arquitectura-del-sistema)
- [Modelos de Datos](#-modelos-de-datos)
- [Servicios](#-servicios)
- [Autenticación](#-autenticación)
- [Firebase Collections](#-firebase-collections)
- [Cloud Functions](#-cloud-functions)
- [Ejemplos de Uso](#-ejemplos-de-uso)

---

## 🏗️ Arquitectura del Sistema

### Stack Tecnológico

```
┌─────────────────────────────────────┐
│         Flutter App (Frontend)       │
│  • Material Design 3                 │
│  • Riverpod (State Management)      │
│  • Flutter Hooks                     │
└──────────────┬──────────────────────┘
               │
               │ Firebase SDK
               │
┌──────────────▼──────────────────────┐
│         Firebase (Backend)           │
│  • Authentication                    │
│  • Firestore Database                │
│  • Cloud Storage                     │
│  • Cloud Functions                   │
└─────────────────────────────────────┘
```

### Estructura de Carpetas

```
lib/
├── app/                    # Configuración de la aplicación
│   ├── app_theme.dart      # Tema Material Design 3
│   ├── router_by_rol.dart  # Enrutamiento basado en roles
│   └── utils.dart          # Utilidades globales
│
├── core/                   # Núcleo del sistema
│   ├── constants.dart      # Constantes globales
│   ├── error_handler.dart  # Manejo de errores
│   └── firestore_paths.dart # Rutas de Firestore
│
├── models/                 # Modelos de datos
│   ├── app_user.dart       # Usuario de la aplicación
│   ├── event.dart          # Evento
│   └── registration.dart   # Inscripción
│
├── services/               # Servicios de Firebase
│   ├── admin_functions_service.dart
│   ├── attendance_service.dart
│   ├── event_service.dart
│   ├── registration_service.dart
│   └── user_service.dart
│
├── features/               # Características por módulos
│   ├── admin/             # Panel administrativo
│   ├── auth/              # Autenticación
│   ├── events/            # Gestión de eventos
│   ├── student/           # Panel de estudiantes
│   ├── attendance/        # Sistema de asistencia
│   └── shared/            # Componentes compartidos
│
└── main.dart              # Punto de entrada
```

---

## 📊 Modelos de Datos

### User (Usuario)

**Collection:** `usuarios`

```dart
class AppUser {
  final String id;
  final String email;
  final String name;
  final String role;          // 'admin', 'estudiante', 'docente', 'ponente'
  final bool active;
  final DateTime createdAt;
  final String? photoURL;
  final String? phone;
  final Map<String, dynamic>? metadata;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.active = true,
    required this.createdAt,
    this.photoURL,
    this.phone,
    this.metadata,
  });

  // Serialización
  factory AppUser.fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toFirestore();
}
```

**Ejemplo JSON:**
```json
{
  "id": "user123",
  "email": "estudiante@virtual.upt.pe",
  "name": "Juan Pérez",
  "role": "estudiante",
  "active": true,
  "createdAt": {"_seconds": 1698765432, "_nanoseconds": 0},
  "photoURL": "https://...",
  "phone": "+51987654321",
  "metadata": {
    "faculty": "EPIS",
    "code": "2020-123456"
  }
}
```

### Event (Evento)

**Collection:** `eventos`

```dart
class Event {
  final String id;
  final String name;
  final String description;
  final String type;          // 'CATEC', 'Software Libre', 'Microsoft'
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final int maxCapacity;
  final bool requiresRegistration;
  final bool isVisible;
  final String status;        // 'active', 'inactive', 'completed'
  final String? imageUrl;
  final List<String>? tags;
  final DateTime createdAt;
  final String createdBy;

  Event({...});

  factory Event.fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toFirestore();
}
```

**Ejemplo JSON:**
```json
{
  "id": "event123",
  "name": "CATEC 2025",
  "description": "Congreso de Tecnología y Computación",
  "type": "CATEC",
  "startDate": {"_seconds": 1698765432},
  "endDate": {"_seconds": 1698851832},
  "location": "Auditorio Principal",
  "maxCapacity": 500,
  "requiresRegistration": true,
  "isVisible": true,
  "status": "active",
  "imageUrl": "https://...",
  "tags": ["tecnología", "computación", "IA"],
  "createdAt": {"_seconds": 1698765432},
  "createdBy": "admin123"
}
```

### Session (Sesión/Ponencia)

**Sub-collection:** `eventos/{eventId}/sesiones`

```dart
class Session {
  final String id;
  final String eventId;
  final String title;
  final String description;
  final String speakerId;
  final DateTime startTime;
  final int durationMinutes;
  final String room;
  final int maxCapacity;
  final String modality;     // 'presencial', 'virtual', 'híbrido'
  final String? virtualLink;
  final String? qrCode;       // Token único para asistencia
  final DateTime createdAt;

  Session({...});
}
```

**Ejemplo JSON:**
```json
{
  "id": "session123",
  "eventId": "event123",
  "title": "Inteligencia Artificial en el 2025",
  "description": "Tendencias y aplicaciones prácticas",
  "speakerId": "speaker123",
  "startTime": {"_seconds": 1698765432},
  "durationMinutes": 90,
  "room": "Sala A",
  "maxCapacity": 100,
  "modality": "híbrido",
  "virtualLink": "https://meet.google.com/...",
  "qrCode": "eyJhbGc...",
  "createdAt": {"_seconds": 1698765432}
}
```

### Speaker (Ponente)

**Collection:** `ponentes`

```dart
class Speaker {
  final String id;
  final String name;
  final String email;
  final String specialty;
  final String bio;
  final String? photoURL;
  final Map<String, String>? socialMedia;
  final DateTime createdAt;

  Speaker({...});
}
```

**Ejemplo JSON:**
```json
{
  "id": "speaker123",
  "name": "Dr. María González",
  "email": "maria@example.com",
  "specialty": "Inteligencia Artificial",
  "bio": "PhD en IA con 15 años de experiencia...",
  "photoURL": "https://...",
  "socialMedia": {
    "linkedin": "linkedin.com/in/mariagonzalez",
    "twitter": "@mariagonzalez"
  },
  "createdAt": {"_seconds": 1698765432}
}
```

### Registration (Inscripción)

**Collection:** `inscripciones`

```dart
class Registration {
  final String id;
  final String userId;
  final String eventId;
  final List<String> sessionIds;
  final DateTime registrationDate;
  final String status;        // 'confirmed', 'cancelled', 'waiting'
  final Map<String, dynamic>? metadata;

  Registration({...});
}
```

**Ejemplo JSON:**
```json
{
  "id": "reg123",
  "userId": "user123",
  "eventId": "event123",
  "sessionIds": ["session123", "session456"],
  "registrationDate": {"_seconds": 1698765432},
  "status": "confirmed",
  "metadata": {
    "source": "mobile",
    "notes": "Interesado en el certificado"
  }
}
```

### Attendance (Asistencia)

**Collection:** `asistencias`

```dart
class Attendance {
  final String id;
  final String userId;
  final String eventId;
  final String sessionId;
  final DateTime timestamp;
  final String method;        // 'qr', 'manual'
  final String? verifiedBy;

  Attendance({...});
}
```

**Ejemplo JSON:**
```json
{
  "id": "att123",
  "userId": "user123",
  "eventId": "event123",
  "sessionId": "session123",
  "timestamp": {"_seconds": 1698765432},
  "method": "qr",
  "verifiedBy": "admin123"
}
```

---

## 🛠️ Servicios

### UserService

**Archivo:** `lib/services/user_service.dart`

#### Métodos Principales

```dart
class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener usuario por ID
  Future<AppUser?> getUserById(String userId) async {
    final doc = await _db.collection('usuarios').doc(userId).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  // Crear usuario
  Future<void> createUser(AppUser user) async {
    await _db.collection('usuarios').doc(user.id).set(user.toFirestore());
  }

  // Actualizar usuario
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _db.collection('usuarios').doc(userId).update(data);
  }

  // Cambiar rol de usuario
  Future<void> changeUserRole(String userId, String newRole) async {
    await updateUser(userId, {'role': newRole, 'rol': newRole});
  }

  // Obtener todos los usuarios
  Stream<List<AppUser>> getAllUsers() {
    return _db.collection('usuarios').snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList()
    );
  }

  // Buscar usuarios por rol
  Future<List<AppUser>> getUsersByRole(String role) async {
    final snapshot = await _db.collection('usuarios')
        .where('role', isEqualTo: role)
        .get();
    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
  }
}
```

### EventService

**Archivo:** `lib/services/event_service.dart`

```dart
class EventService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener todos los eventos
  Stream<List<Event>> getAllEvents() {
    return _db.collection('eventos')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList()
        );
  }

  // Obtener evento por ID
  Future<Event?> getEventById(String eventId) async {
    final doc = await _db.collection('eventos').doc(eventId).get();
    if (!doc.exists) return null;
    return Event.fromFirestore(doc);
  }

  // Crear evento
  Future<String> createEvent(Event event) async {
    final docRef = await _db.collection('eventos').add(event.toFirestore());
    return docRef.id;
  }

  // Actualizar evento
  Future<void> updateEvent(String eventId, Map<String, dynamic> data) async {
    await _db.collection('eventos').doc(eventId).update(data);
  }

  // Eliminar evento
  Future<void> deleteEvent(String eventId) async {
    // Eliminar sesiones
    final sessions = await _db.collection('eventos')
        .doc(eventId)
        .collection('sesiones')
        .get();
    
    for (var session in sessions.docs) {
      await session.reference.delete();
    }

    // Eliminar evento
    await _db.collection('eventos').doc(eventId).delete();
  }

  // Obtener eventos activos
  Stream<List<Event>> getActiveEvents() {
    return _db.collection('eventos')
        .where('status', isEqualTo: 'active')
        .where('isVisible', isEqualTo: true)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList()
        );
  }

  // Obtener sesiones de un evento
  Stream<List<Session>> getEventSessions(String eventId) {
    return _db.collection('eventos')
        .doc(eventId)
        .collection('sesiones')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Session.fromFirestore(doc)).toList()
        );
  }
}
```

### RegistrationService

**Archivo:** `lib/services/registration_service.dart`

```dart
class RegistrationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Inscribirse a un evento
  Future<String> registerToEvent({
    required String userId,
    required String eventId,
    required List<String> sessionIds,
  }) async {
    // Verificar aforo
    final event = await EventService().getEventById(eventId);
    if (event == null) throw Exception('Evento no encontrado');

    final currentRegistrations = await getEventRegistrations(eventId);
    if (currentRegistrations.length >= event.maxCapacity) {
      throw Exception('Aforo completo');
    }

    // Verificar si ya está inscrito
    final existingRegistration = await getUserEventRegistration(userId, eventId);
    if (existingRegistration != null) {
      throw Exception('Ya estás inscrito en este evento');
    }

    // Crear inscripción
    final registration = Registration(
      id: '',
      userId: userId,
      eventId: eventId,
      sessionIds: sessionIds,
      registrationDate: DateTime.now(),
      status: 'confirmed',
    );

    final docRef = await _db.collection('inscripciones')
        .add(registration.toFirestore());
    
    return docRef.id;
  }

  // Obtener inscripciones de un usuario
  Stream<List<Registration>> getUserRegistrations(String userId) {
    return _db.collection('inscripciones')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snapshot) => 
            snapshot.docs.map((doc) => Registration.fromFirestore(doc)).toList()
        );
  }

  // Obtener inscripciones de un evento
  Future<List<Registration>> getEventRegistrations(String eventId) async {
    final snapshot = await _db.collection('inscripciones')
        .where('eventId', isEqualTo: eventId)
        .where('status', isEqualTo: 'confirmed')
        .get();
    
    return snapshot.docs.map((doc) => Registration.fromFirestore(doc)).toList();
  }

  // Cancelar inscripción
  Future<void> cancelRegistration(String registrationId) async {
    await _db.collection('inscripciones')
        .doc(registrationId)
        .update({'status': 'cancelled'});
  }
}
```

### AttendanceService

**Archivo:** `lib/services/attendance_service.dart`

```dart
class AttendanceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generar código QR para sesión
  Future<String> generateSessionQR(String sessionId) async {
    final token = _generateUniqueToken();
    
    await _db.collection('eventos')
        .doc(eventId)
        .collection('sesiones')
        .doc(sessionId)
        .update({'qrCode': token});
    
    return token;
  }

  // Registrar asistencia con QR
  Future<void> registerAttendanceWithQR({
    required String userId,
    required String qrToken,
  }) async {
    // Buscar sesión por token QR
    final sessionsSnapshot = await _db.collectionGroup('sesiones')
        .where('qrCode', isEqualTo: qrToken)
        .get();

    if (sessionsSnapshot.docs.isEmpty) {
      throw Exception('Código QR inválido');
    }

    final sessionDoc = sessionsSnapshot.docs.first;
    final session = Session.fromFirestore(sessionDoc);

    // Verificar horario
    final now = DateTime.now();
    final sessionEnd = session.startTime.add(
        Duration(minutes: session.durationMinutes)
    );
    
    if (now.isBefore(session.startTime) || now.isAfter(sessionEnd)) {
      throw Exception('Fuera del horario de la sesión');
    }

    // Verificar inscripción
    final registration = await RegistrationService()
        .getUserEventRegistration(userId, session.eventId);
    
    if (registration == null) {
      throw Exception('No estás inscrito en este evento');
    }

    // Verificar si ya registró asistencia
    final existingAttendance = await _db.collection('asistencias')
        .where('userId', isEqualTo: userId)
        .where('sessionId', isEqualTo: session.id)
        .get();

    if (existingAttendance.docs.isNotEmpty) {
      throw Exception('Ya registraste tu asistencia');
    }

    // Registrar asistencia
    final attendance = Attendance(
      id: '',
      userId: userId,
      eventId: session.eventId,
      sessionId: session.id,
      timestamp: DateTime.now(),
      method: 'qr',
    );

    await _db.collection('asistencias').add(attendance.toFirestore());
  }

  // Obtener asistencias de un usuario en un evento
  Future<List<Attendance>> getUserEventAttendances(
    String userId,
    String eventId,
  ) async {
    final snapshot = await _db.collection('asistencias')
        .where('userId', isEqualTo: userId)
        .where('eventId', isEqualTo: eventId)
        .get();
    
    return snapshot.docs.map((doc) => Attendance.fromFirestore(doc)).toList();
  }

  // Token único
  String _generateUniqueToken() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           Random().nextInt(10000).toString();
  }
}
```

---

## 🔐 Autenticación

### AuthService

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Login con email y contraseña
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Login con Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Crear usuario en Firestore si no existe
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _createUserInFirestore(userCredential.user!);
      }

      return userCredential.user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Registro con email
  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _createUserInFirestore(credential.user!, name: name);
      }

      return credential.user;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }

  // Recuperar contraseña
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Crear usuario en Firestore
  Future<void> _createUserInFirestore(User user, {String? name}) async {
    final appUser = AppUser(
      id: user.uid,
      email: user.email!,
      name: name ?? user.displayName ?? 'Usuario',
      role: 'estudiante', // Rol por defecto
      active: true,
      createdAt: DateTime.now(),
      photoURL: user.photoURL,
    );

    await _userService.createUser(appUser);
  }

  // Manejo de errores
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'Usuario no encontrado';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'email-already-in-use':
          return 'El correo ya está registrado';
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'invalid-email':
          return 'Correo inválido';
        default:
          return 'Error de autenticación: ${e.message}';
      }
    }
    return 'Error desconocido';
  }
}
```

---

## 📁 Firebase Collections

### Estructura de Colecciones

```
firestore/
├── usuarios/
│   └── {userId}
│
├── eventos/
│   └── {eventId}/
│       └── sesiones/
│           └── {sessionId}
│
├── ponentes/
│   └── {speakerId}
│
├── inscripciones/
│   └── {registrationId}
│
└── asistencias/
    └── {attendanceId}
```

### Índices Recomendados

```javascript
// En Firebase Console > Firestore > Índices

// Eventos por estado y fecha
eventos: {
  fields: ['status', 'startDate'],
  order: ['status: ASC', 'startDate: DESC']
}

// Inscripciones por usuario y estado
inscripciones: {
  fields: ['userId', 'status'],
  order: ['userId: ASC', 'status: ASC']
}

// Asistencias por usuario y evento
asistencias: {
  fields: ['userId', 'eventId'],
  order: ['userId: ASC', 'eventId: ASC']
}
```

---

## ☁️ Cloud Functions

**Archivo:** `functions/index.js`

### Función: Notificar Nueva Inscripción

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Enviar notificación cuando hay nueva inscripción
exports.onNewRegistration = functions.firestore
  .document('inscripciones/{registrationId}')
  .onCreate(async (snap, context) => {
    const registration = snap.data();
    
    // Obtener datos del evento
    const eventDoc = await admin.firestore()
      .collection('eventos')
      .doc(registration.eventId)
      .get();
    
    const event = eventDoc.data();
    
    // Enviar email de confirmación
    // (implementar con SendGrid, Mailgun, etc.)
    
    return null;
  });

// Generar certificado automáticamente
exports.generateCertificate = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Usuario no autenticado'
    );
  }

  const { userId, eventId } = data;

  // Verificar asistencias
  const attendances = await admin.firestore()
    .collection('asistencias')
    .where('userId', '==', userId)
    .where('eventId', '==', eventId)
    .get();

  // Obtener sesiones del evento
  const sessions = await admin.firestore()
    .collection('eventos')
    .doc(eventId)
    .collection('sesiones')
    .get();

  const attendancePercentage = (attendances.size / sessions.size) * 100;

  if (attendancePercentage >= 80) {
    // Generar certificado (implementar con PDF generator)
    return { 
      success: true, 
      certificateUrl: '...' 
    };
  } else {
    throw new functions.https.HttpsError(
      'failed-precondition',
      'Asistencia insuficiente'
    );
  }
});
```

---

## 💡 Ejemplos de Uso

### Ejemplo 1: Inscribirse a un Evento

```dart
try {
  final registrationService = RegistrationService();
  
  final registrationId = await registrationService.registerToEvent(
    userId: currentUser.id,
    eventId: 'event123',
    sessionIds: ['session1', 'session2'],
  );

  print('Inscripción exitosa: $registrationId');
} catch (e) {
  print('Error: $e');
}
```

### Ejemplo 2: Escanear QR y Registrar Asistencia

```dart
// En el widget de escaneo QR
void onQRScanned(String qrCode) async {
  try {
    final attendanceService = AttendanceService();
    
    await attendanceService.registerAttendanceWithQR(
      userId: currentUser.id,
      qrToken: qrCode,
    );

    showSuccessMessage('Asistencia registrada');
  } catch (e) {
    showErrorMessage(e.toString());
  }
}
```

### Ejemplo 3: Obtener Eventos con Riverpod

```dart
final eventServiceProvider = Provider((ref) => EventService());

final activeEventsProvider = StreamProvider<List<Event>>((ref) {
  final eventService = ref.watch(eventServiceProvider);
  return eventService.getActiveEvents();
});

// En el Widget
Consumer(
  builder: (context, ref, child) {
    final eventsAsync = ref.watch(activeEventsProvider);

    return eventsAsync.when(
      data: (events) => EventsList(events: events),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  },
)
```

---

## 🔍 Consultas Comunes

### Obtener próximos eventos

```dart
Stream<List<Event>> getUpcomingEvents() {
  return _db.collection('eventos')
      .where('startDate', isGreaterThan: Timestamp.now())
      .where('status', isEqualTo: 'active')
      .orderBy('startDate')
      .limit(10)
      .snapshots()
      .map((snapshot) => 
          snapshot.docs.map((doc) => Event.fromFirestore(doc)).toList()
      );
}
```

### Obtener top ponentes (más sesiones)

```dart
Future<List<Speaker>> getTopSpeakers({int limit = 10}) async {
  // Implementar lógica de agregación
  // Contar sesiones por ponente
}
```

### Estadísticas de asistencia

```dart
Future<Map<String, int>> getEventAttendanceStats(String eventId) async {
  final sessions = await getEventSessions(eventId);
  final stats = <String, int>{};

  for (var session in sessions) {
    final attendances = await _db.collection('asistencias')
        .where('sessionId', isEqualTo: session.id)
        .get();
    
    stats[session.title] = attendances.size;
  }

  return stats;
}
```

---

## 📚 Recursos Adicionales

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Riverpod Documentation](https://riverpod.dev/)
- [Material Design 3](https://m3.material.io/)

---

**Universidad Privada de Tacna**  
Escuela Profesional de Ingeniería de Sistemas

*Última actualización: Octubre 2025*

