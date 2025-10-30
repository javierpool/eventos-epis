# 📦 Guía de Instalación - EVENTOS EPIS

Esta guía te ayudará a configurar el proyecto desde cero en tu máquina local.

## 📋 Requisitos Previos

### Software Necesario

1. **Flutter SDK** (>=3.0.0)
   - Descarga desde: https://flutter.dev/docs/get-started/install
   - Verifica la instalación: `flutter --version`

2. **Dart SDK** (incluido con Flutter)
   - Versión recomendada: 3.8.1 o superior

3. **IDE (Elige uno)**
   - **Visual Studio Code** + extensión Flutter
   - **Android Studio** + Flutter plugin
   - **IntelliJ IDEA** + Flutter plugin

4. **Git**
   - Descarga desde: https://git-scm.com/downloads
   - Verifica: `git --version`

5. **Node.js** (para Firebase Functions)
   - Versión: 18.x o superior
   - Descarga desde: https://nodejs.org/

### Cuentas Requeridas

- **Cuenta de Firebase** (gratuita)
- **Cuenta de Google Cloud** (para algunos servicios)
- **Cuenta de GitHub** (para el código fuente)

---

## 🚀 Instalación Paso a Paso

### 1. Clonar el Repositorio

```bash
# Clonar el repositorio
git clone https://github.com/javierpool/eventos-epis.git

# Entrar al directorio
cd eventos-epis

# Verificar que estás en la rama main
git branch
```

### 2. Instalar Dependencias de Flutter

```bash
# Limpiar caché (opcional pero recomendado)
flutter clean

# Obtener todas las dependencias
flutter pub get

# Verificar que no hay problemas
flutter doctor -v
```

### 3. Configurar Firebase

#### 3.1 Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Haz clic en "Agregar proyecto"
3. Nombre del proyecto: `eventos-epis-upt` (o el que prefieras)
4. Sigue los pasos del asistente

#### 3.2 Configurar Firebase CLI

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Iniciar sesión
firebase login

# Verificar que estás logueado
firebase projects:list
```

#### 3.3 Configurar Aplicaciones en Firebase

##### Para Android:

1. En Firebase Console > Configuración del proyecto
2. Añade una app Android
3. Nombre del paquete: `com.upt.epis.eventos`
4. Descarga `google-services.json`
5. Colócalo en: `android/app/google-services.json`

##### Para iOS:

1. En Firebase Console > Configuración del proyecto
2. Añade una app iOS
3. Bundle ID: `com.upt.epis.eventos`
4. Descarga `GoogleService-Info.plist`
5. Colócalo en: `ios/Runner/GoogleService-Info.plist`

##### Para Web:

1. En Firebase Console > Configuración del proyecto
2. Añade una app Web
3. Copia la configuración
4. El archivo `lib/firebase_options.dart` ya está configurado

#### 3.4 Habilitar Servicios de Firebase

##### Authentication:

1. Ve a Authentication > Sign-in method
2. Habilita los siguientes proveedores:
   - ✅ **Correo electrónico/Contraseña**
   - ✅ **Google** (configura el soporte de OAuth)

Para Google Sign-In:
- Agrega tu email como usuario de prueba
- Descarga el archivo SHA-1 para Android:
  ```bash
  cd android
  ./gradlew signingReport
  ```

##### Firestore Database:

1. Ve a Firestore Database
2. Crea una base de datos
3. Selecciona ubicación: `us-central1` (o la más cercana)
4. Modo: **Producción** (aplicaremos reglas de seguridad)

##### Storage:

1. Ve a Storage
2. Habilita Cloud Storage
3. Ubicación: misma que Firestore

##### Cloud Functions (Opcional):

```bash
cd functions
npm install
```

### 4. Configurar Reglas de Seguridad

#### 4.1 Reglas de Firestore

1. Ve a Firestore > Reglas
2. Copia y pega el contenido de `firestore.rules`:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Función auxiliar para verificar si es admin
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Función auxiliar para verificar si es el usuario actual
    function isOwner(userId) {
      return request.auth != null && request.auth.uid == userId;
    }
    
    // EVENTOS: Lectura pública, escritura solo admins
    match /eventos/{eventId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    // USUARIOS: Lectura propia o admin, escritura solo admin
    match /usuarios/{userId} {
      allow read: if isOwner(userId) || isAdmin();
      allow create, update, delete: if isAdmin();
    }
    
    // INSCRIPCIONES: Lectura propia o admin, creación autenticada
    match /inscripciones/{inscripcionId} {
      allow read: if request.auth != null && 
                     (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update, delete: if isAdmin();
    }
    
    // PONENTES: Lectura pública, escritura solo admins
    match /ponentes/{ponenteId} {
      allow read: if true;
      allow create, update, delete: if isAdmin();
    }
    
    // ASISTENCIAS: Lectura propia o admin, creación autenticada
    match /asistencias/{asistenciaId} {
      allow read: if request.auth != null && 
                     (resource.data.userId == request.auth.uid || isAdmin());
      allow create: if request.auth != null;
      allow update, delete: if isAdmin();
    }
  }
}
```

#### 4.2 Reglas de Storage

1. Ve a Storage > Reglas
2. Copia y pega el contenido de `storage.rules`:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### 5. Crear Primer Usuario Administrador

1. Ejecuta la aplicación
2. Regístrate con un correo (ej: `admin@virtual.upt.pe`)
3. Ve a Firestore Console
4. Busca la colección `usuarios`
5. Encuentra tu usuario por email
6. Edita el documento y añade/modifica:

```json
{
  "email": "admin@virtual.upt.pe",
  "name": "Administrador",
  "role": "admin",
  "rol": "admin",
  "active": true,
  "createdAt": [timestamp actual]
}
```

### 6. Configuración Específica por Plataforma

#### Android

```bash
# Actualizar gradle
cd android
./gradlew clean

# Volver a la raíz
cd ..
```

#### iOS

```bash
# Instalar pods
cd ios
pod install
cd ..
```

#### Windows

- Habilita el "Modo Desarrollador" en Configuración de Windows
- Necesario para symlinks

#### Web

- No requiere configuración adicional

### 7. Ejecutar la Aplicación

```bash
# Verificar dispositivos disponibles
flutter devices

# Para web (Chrome)
flutter run -d chrome

# Para web (Edge)
flutter run -d edge

# Para Android (con dispositivo conectado)
flutter run -d android

# Para iOS (solo en Mac)
flutter run -d ios

# Para Windows
flutter run -d windows

# Para Linux
flutter run -d linux
```

---

## 🔧 Configuración Avanzada

### Variables de Entorno

Crea un archivo `.env` en la raíz (opcional):

```env
FIREBASE_PROJECT_ID=tu-proyecto-id
FIREBASE_API_KEY=tu-api-key
```

### Configuración de Firebase Emulator (Desarrollo Local)

```bash
# Instalar emulators
firebase init emulators

# Ejecutar emulators
firebase emulators:start
```

### Configurar Debug en VS Code

Crea `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "eventos (Chrome)",
      "request": "launch",
      "type": "dart",
      "deviceId": "chrome"
    },
    {
      "name": "eventos (Android)",
      "request": "launch",
      "type": "dart",
      "deviceId": "android"
    }
  ]
}
```

---

## ✅ Verificación de Instalación

### Checklist

- [ ] Flutter instalado y funcionando (`flutter doctor`)
- [ ] Repositorio clonado
- [ ] Dependencias instaladas (`flutter pub get`)
- [ ] Firebase configurado
- [ ] Archivos de configuración en su lugar
  - [ ] `android/app/google-services.json`
  - [ ] `ios/Runner/GoogleService-Info.plist`
- [ ] Authentication habilitado (Email + Google)
- [ ] Firestore Database creado
- [ ] Cloud Storage habilitado
- [ ] Reglas de seguridad aplicadas
- [ ] Primer usuario admin creado
- [ ] Aplicación ejecutándose sin errores

### Comandos de Verificación

```bash
# Verificar Flutter
flutter doctor -v

# Verificar dependencias
flutter pub get

# Analizar código
flutter analyze

# Ejecutar tests
flutter test
```

---

## 🐛 Solución de Problemas Comunes

### Error: "google-services.json not found"

**Solución:** Descarga el archivo desde Firebase Console y colócalo en `android/app/`

### Error: "Pod install failed"

**Solución (iOS):**
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Error: "Firebase not initialized"

**Solución:** Verifica que `firebase_options.dart` existe y ejecuta:
```bash
firebase login
flutterfire configure
```

### Error de permisos en Windows

**Solución:** Ejecuta PowerShell como administrador y habilita el modo desarrollador

### Error: "Gradle build failed"

**Solución:**
```bash
cd android
./gradlew clean
./gradlew build
cd ..
```

### Error de certificados SSL

**Solución:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📞 Soporte

Si encuentras problemas durante la instalación:

1. Revisa la [documentación oficial de Flutter](https://flutter.dev/docs)
2. Consulta [Firebase Documentation](https://firebase.google.com/docs)
3. Abre un issue en GitHub
4. Contacta al equipo de desarrollo

---

## 🎉 ¡Instalación Completa!

Si llegaste hasta aquí sin errores, ¡felicidades! Tu entorno está listo para desarrollar.

Siguiente paso: Lee la [Guía de Usuario](USER_GUIDE.md) para aprender a usar la aplicación.

