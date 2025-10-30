# 🚀 Guía de Despliegue - EVENTOS EPIS

Guía completa para desplegar la aplicación en diferentes plataformas.

## 📑 Tabla de Contenidos

- [Preparación General](#-preparación-general)
- [Despliegue Web](#-despliegue-web)
- [Despliegue Android](#-despliegue-android)
- [Despliegue iOS](#-despliegue-ios)
- [Despliegue Windows](#-despliegue-windows)
- [Firebase Hosting](#-firebase-hosting)
- [CI/CD](#-cicd)
- [Monitoreo y Mantenimiento](#-monitoreo-y-mantenimiento)

---

## 🎯 Preparación General

### 1. Configuración de Versión

Actualiza `pubspec.yaml`:

```yaml
version: 1.0.0+1
# Formato: MAJOR.MINOR.PATCH+BUILD_NUMBER
# 1.0.0 = versión semántica
# +1 = build number
```

### 2. Verificación Pre-Despliegue

```bash
# Análisis de código
flutter analyze

# Tests
flutter test

# Compilar para verificar
flutter build apk --debug
```

### 3. Configurar Firebase para Producción

#### Reglas de Firestore

Asegúrate de tener reglas de seguridad apropiadas:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // No permitir lectura/escritura pública en producción
    match /{document=**} {
      allow read, write: if false;
    }
    
    // Implementar reglas específicas por colección
    match /usuarios/{userId} {
      allow read: if request.auth != null && 
                     (request.auth.uid == userId || isAdmin());
      allow write: if isAdmin();
    }
    
    // Función helper
    function isAdmin() {
      return request.auth != null && 
             get(/databases/$(database)/documents/usuarios/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

#### Reglas de Storage

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /public/{allPaths=**} {
      allow read: if true;
    }
    
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /events/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && isAdmin();
    }
  }
}
```

### 4. Variables de Entorno

Crea archivos de configuración por ambiente:

**lib/config/env_config.dart**:

```dart
class EnvConfig {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static const bool isProduction = environment == 'production';
  static const bool isDevelopment = environment == 'development';
  
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api-dev.eventos-epis.com',
  );
}
```

---

## 🌐 Despliegue Web

### 1. Configurar para Web

**web/index.html** - Verifica metadatos:

```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="Sistema de gestión de eventos EPIS-UPT">
  <title>EVENTOS EPIS - UPT</title>
  
  <!-- PWA -->
  <link rel="manifest" href="manifest.json">
  <link rel="icon" type="image/png" href="favicon.png"/>
  
  <!-- Theme Color -->
  <meta name="theme-color" content="#0D47A1">
</head>
<body>
  <script src="flutter.js" defer></script>
</body>
</html>
```

**web/manifest.json**:

```json
{
  "name": "EVENTOS EPIS",
  "short_name": "EPIS Events",
  "description": "Sistema de gestión de eventos EPIS-UPT",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#FFFFFF",
  "theme_color": "#0D47A1",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/Icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/Icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

### 2. Build para Web

```bash
# Build de producción
flutter build web --release

# Build con configuración custom
flutter build web --release \
  --dart-define=ENVIRONMENT=production \
  --dart-define=API_URL=https://api.eventos-epis.com

# Build optimizado
flutter build web --release \
  --web-renderer canvaskit \
  --pwa-strategy offline-first
```

Opciones de renderer:
- `auto`: Detecta automáticamente (por defecto)
- `canvaskit`: Mejor rendimiento, mayor tamaño
- `html`: Menor tamaño, menos características

### 3. Optimizaciones Web

**Comprimir Assets**:

```bash
# Instalar gzip
sudo apt-get install gzip

# Comprimir archivos build
cd build/web
find . -type f \( -name '*.js' -o -name '*.css' -o -name '*.html' \) \
  -exec gzip -k {} \;
```

**Service Worker para PWA**:

Ya incluido automáticamente con `flutter build web`

### 4. Hosting Options

#### Opción A: Firebase Hosting

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar
firebase init hosting

# Desplegar
firebase deploy --only hosting
```

**firebase.json**:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  }
}
```

#### Opción B: Netlify

```bash
# Instalar Netlify CLI
npm install -g netlify-cli

# Login
netlify login

# Desplegar
netlify deploy --dir=build/web --prod
```

**netlify.toml**:

```toml
[build]
  publish = "build/web"
  command = "flutter build web --release"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

#### Opción C: Vercel

```bash
# Instalar Vercel CLI
npm i -g vercel

# Desplegar
vercel --prod
```

**vercel.json**:

```json
{
  "buildCommand": "flutter build web --release",
  "outputDirectory": "build/web",
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.html"
    }
  ]
}
```

---

## 📱 Despliegue Android

### 1. Configurar App Signing

#### Generar Keystore

```bash
keytool -genkey -v -keystore ~/eventos-epis-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias eventos-epis

# Te pedirá:
# - Contraseña del keystore
# - Nombre, organización, etc.
# - Contraseña de la key
```

#### Configurar Gradle

**android/key.properties**:

```properties
storePassword=tu-password-keystore
keyPassword=tu-password-key
keyAlias=eventos-epis
storeFile=/ruta/a/eventos-epis-key.jks
```

**android/app/build.gradle.kts**:

```kotlin
// Antes de android {
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 2. Configurar AndroidManifest.xml

**android/app/src/main/AndroidManifest.xml**:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.upt.epis.eventos">
    
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    
    <application
        android:label="EVENTOS EPIS"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 3. Build APK/AAB

```bash
# APK para pruebas
flutter build apk --release

# APK separado por ABI (menor tamaño)
flutter build apk --split-per-abi

# Android App Bundle (para Play Store)
flutter build appbundle --release

# Con configuración
flutter build appbundle --release \
  --dart-define=ENVIRONMENT=production \
  --obfuscate \
  --split-debug-info=build/app/outputs/symbols
```

Los archivos estarán en:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### 4. Publicar en Play Store

#### Preparación

1. **Crear cuenta de desarrollador**: https://play.google.com/console
2. **Pagar tarifa única**: $25 USD
3. **Crear aplicación** en Play Console

#### Assets Requeridos

- **Ícono de app**: 512x512 px
- **Feature graphic**: 1024x500 px
- **Screenshots**: Mínimo 2 por dispositivo
  - Teléfono: 16:9 o 9:16
  - Tablet 7": 16:9 o 9:16
  - Tablet 10": 16:9 o 9:16

#### Información de la App

```
Título: EVENTOS EPIS
Descripción corta: Sistema de gestión de eventos académicos UPT

Descripción completa:
EVENTOS EPIS es la aplicación oficial para gestionar eventos académicos
de la Escuela Profesional de Ingeniería de Sistemas de la Universidad
Privada de Tacna.

Características:
• Inscripción a eventos y ponencias
• Sistema de asistencia con QR
• Notificaciones de eventos
• Certificados digitales
• Historial de participación

Categoría: Educación
Clasificación de contenido: PEGI 3
```

#### Proceso de Publicación

1. Sube el AAB
2. Completa información de la app
3. Sube assets gráficos
4. Configura precios y distribución
5. Completa cuestionario de contenido
6. Envía para revisión

Tiempo de revisión: 1-7 días

---

## 🍎 Despliegue iOS

### 1. Requisitos

- **Mac** con macOS 12 o superior
- **Xcode** 14 o superior
- **Apple Developer Account** ($99/año)
- **CocoaPods** instalado

### 2. Configurar Xcode

```bash
# Abrir proyecto
open ios/Runner.xcworkspace

# O desde terminal
cd ios
pod install
cd ..
```

En Xcode:
1. Selecciona `Runner` en el navegador
2. Ve a **Signing & Capabilities**
3. Selecciona tu Team
4. Configura Bundle Identifier: `com.upt.epis.eventos`

### 3. Configurar Info.plist

**ios/Runner/Info.plist**:

```xml
<dict>
    <key>CFBundleDisplayName</key>
    <string>EVENTOS EPIS</string>
    
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    
    <key>NSCameraUsageDescription</key>
    <string>Necesitamos acceso a la cámara para escanear códigos QR</string>
    
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Necesitamos acceso a fotos para seleccionar imagen de perfil</string>
</dict>
```

### 4. Build para iOS

```bash
# Build para dispositivo
flutter build ios --release

# Build con configuración
flutter build ios --release \
  --dart-define=ENVIRONMENT=production \
  --obfuscate \
  --split-debug-info=build/ios/symbols
```

### 5. Crear IPA con Xcode

1. Abre `ios/Runner.xcworkspace`
2. Selecciona `Product` > `Archive`
3. Espera a que termine
4. En Organizer, selecciona el archive
5. Click en `Distribute App`
6. Selecciona `App Store Connect`
7. Sigue los pasos del asistente

### 6. Publicar en App Store

#### App Store Connect

1. Ve a https://appstoreconnect.apple.com
2. Click en `My Apps` > `+` > `New App`
3. Completa información:
   - Plataforma: iOS
   - Nombre: EVENTOS EPIS
   - Idioma principal: Español
   - Bundle ID: com.upt.epis.eventos
   - SKU: eventos-epis-upt

#### Assets Requeridos

- **App Icon**: 1024x1024 px (sin transparencia)
- **Screenshots**:
  - iPhone 6.5": 1242x2688 px (mínimo 3)
  - iPhone 5.5": 1242x2208 px (mínimo 3)
  - iPad Pro 12.9": 2048x2732 px (mínimo 3)

#### Información de la App

```
Nombre: EVENTOS EPIS
Subtítulo: Gestión de eventos UPT
Categoría principal: Educación
Categoría secundaria: Productividad

Descripción:
[Misma que Android]

Keywords: eventos, universidad, epis, upt, educación

URL de soporte: https://eventos-epis.upt.pe
URL de marketing: https://www.upt.pe
```

#### TestFlight (Beta Testing)

1. En App Store Connect > TestFlight
2. Añade testers internos (hasta 100)
3. O externos (con revisión de Apple)
4. Envía invitaciones
5. Recolecta feedback

#### Enviar para Revisión

1. Completa toda la información
2. Sube build desde Xcode
3. Selecciona build en App Store Connect
4. Responde cuestionario de privacidad
5. Envía para revisión

Tiempo de revisión: 1-3 días

---

## 🪟 Despliegue Windows

### 1. Build para Windows

```bash
# Build de release
flutter build windows --release

# Resultado en: build/windows/runner/Release/
```

### 2. Crear Instalador con MSIX

**pubspec.yaml** - Añade:

```yaml
dev_dependencies:
  msix: ^3.16.0

msix_config:
  display_name: EVENTOS EPIS
  publisher_display_name: Universidad Privada de Tacna
  identity_name: com.upt.epis.eventos
  msix_version: 1.0.0.0
  logo_path: assets/images/logo.png
  capabilities: internetClient, webcam
```

Generar MSIX:

```bash
flutter pub run msix:create
```

### 3. Microsoft Store

1. Registra cuenta: https://partner.microsoft.com/dashboard
2. Reserva nombre de app
3. Crea submission
4. Sube MSIX
5. Completa información
6. Envía para certificación

### 4. Distribución Alternativa

Crea instalador con **Inno Setup**:

**installer.iss**:

```iss
[Setup]
AppName=EVENTOS EPIS
AppVersion=1.0.0
DefaultDirName={pf}\EVENTOS EPIS
DefaultGroupName=EVENTOS EPIS
OutputBaseFilename=EventosEPIS-Setup
Compression=lzma2
SolidCompression=yes

[Files]
Source: "build\windows\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs

[Icons]
Name: "{group}\EVENTOS EPIS"; Filename: "{app}\eventos.exe"
Name: "{commondesktop}\EVENTOS EPIS"; Filename: "{app}\eventos.exe"
```

Compilar:
```bash
iscc installer.iss
```

---

## 🔥 Firebase Hosting

### Configuración Completa

**firebase.json**:

```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**",
        "headers": [
          {
            "key": "X-Content-Type-Options",
            "value": "nosniff"
          },
          {
            "key": "X-Frame-Options",
            "value": "DENY"
          },
          {
            "key": "X-XSS-Protection",
            "value": "1; mode=block"
          }
        ]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp|css|js)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      }
    ]
  },
  "firestore": {
    "rules": "firestore.rules",
    "indexes": "firestore.indexes.json"
  },
  "storage": {
    "rules": "storage.rules"
  }
}
```

### Despliegue

```bash
# Preview
firebase hosting:channel:deploy preview

# Producción
firebase deploy --only hosting

# Todo
firebase deploy
```

### Dominio Custom

1. En Firebase Console > Hosting
2. Click en `Add custom domain`
3. Ingresa tu dominio: `eventos-epis.upt.pe`
4. Verifica propiedad (DNS TXT record)
5. Configura registros DNS:
   ```
   Type  Name  Value
   A     @     151.101.1.195
   A     @     151.101.65.195
   ```
6. Espera propagación (24-48 hrs)

---

## 🔄 CI/CD

### GitHub Actions

**.github/workflows/deploy.yml**:

```yaml
name: Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.8'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Analyze
        run: flutter analyze
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  deploy-web:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.8'
      
      - name: Build web
        run: flutter build web --release
      
      - name: Deploy to Firebase
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only hosting
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}

  deploy-android:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          distribution: 'zulu'
          java-version: '11'
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.8'
      
      - name: Decode keystore
        run: |
          echo "${{ secrets.KEYSTORE_BASE64 }}" | base64 --decode > android/app/keystore.jks
      
      - name: Create key.properties
        run: |
          echo "storePassword=${{ secrets.STORE_PASSWORD }}" > android/key.properties
          echo "keyPassword=${{ secrets.KEY_PASSWORD }}" >> android/key.properties
          echo "keyAlias=${{ secrets.KEY_ALIAS }}" >> android/key.properties
          echo "storeFile=keystore.jks" >> android/key.properties
      
      - name: Build AAB
        run: flutter build appbundle --release
      
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: com.upt.epis.eventos
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
```

---

## 📊 Monitoreo y Mantenimiento

### Firebase Analytics

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void logEvent(String name, Map<String, dynamic>? parameters) {
    _analytics.logEvent(name: name, parameters: parameters);
  }

  void logScreenView(String screenName) {
    _analytics.logScreenView(screenName: screenName);
  }
}
```

### Firebase Crashlytics

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(MyApp());
}
```

### Performance Monitoring

```dart
import 'package:firebase_performance/firebase_performance.dart';

Future<void> loadEvents() async {
  final trace = FirebasePerformance.instance.newTrace('load_events');
  await trace.start();

  // Tu código aquí
  await eventService.getAllEvents();

  await trace.stop();
}
```

---

## 📝 Checklist de Despliegue

### Pre-Despliegue
- [ ] Todos los tests pasan
- [ ] Código analizado sin errores
- [ ] Documentación actualizada
- [ ] Versión actualizada en pubspec.yaml
- [ ] Changelog actualizado
- [ ] Reglas de Firebase verificadas
- [ ] Secrets y API keys seguros
- [ ] Assets optimizados

### Web
- [ ] Build de producción exitoso
- [ ] PWA funcional offline
- [ ] Performance > 90 en Lighthouse
- [ ] SEO configurado
- [ ] Dominio configurado
- [ ] SSL activo

### Android
- [ ] APK firmado correctamente
- [ ] Permisos apropiados
- [ ] Probado en múltiples dispositivos
- [ ] Screenshots actualizados
- [ ] Store listing completo

### iOS
- [ ] Build archive exitoso
- [ ] Certificates y provisioning profiles válidos
- [ ] Probado en dispositivos físicos
- [ ] Screenshots actualizados
- [ ] App Store listing completo

### Post-Despliegue
- [ ] Monitoreo activo
- [ ] Analytics configurado
- [ ] Crash reporting activo
- [ ] Feedback de usuarios
- [ ] Plan de actualizaciones

---

**Universidad Privada de Tacna**  
Escuela Profesional de Ingeniería de Sistemas

*Última actualización: Octubre 2025*

