# 👥 Guía de Usuario - EVENTOS EPIS

Guía completa para usar el sistema de gestión de eventos de EPIS-UPT.

## 📑 Tabla de Contenidos

- [Inicio de Sesión](#-inicio-de-sesión)
- [Panel de Administrador](#-panel-de-administrador)
- [Panel de Estudiante](#-panel-de-estudiante)
- [Panel de Docente](#-panel-de-docente)
- [Sistema de Asistencia QR](#-sistema-de-asistencia-qr)
- [Preguntas Frecuentes](#-preguntas-frecuentes)

---

## 🔐 Inicio de Sesión

### Registro de Nuevo Usuario

1. Abre la aplicación
2. Haz clic en **"Crear cuenta"**
3. Completa el formulario:
   - **Nombre completo**
   - **Correo electrónico**
   - **Contraseña** (mínimo 6 caracteres)
   - **Confirmar contraseña**
4. Acepta los términos y condiciones
5. Haz clic en **"Registrarse"**
6. Recibirás un correo de verificación

### Iniciar Sesión con Correo

1. Ingresa tu correo electrónico
2. Ingresa tu contraseña
3. Haz clic en **"Iniciar Sesión"**

### Iniciar Sesión con Google

1. Haz clic en **"Continuar con Google"**
2. Selecciona tu cuenta institucional @virtual.upt.pe
3. Autoriza la aplicación
4. Serás redirigido automáticamente

> **Nota:** Los correos @virtual.upt.pe tienen acceso prioritario al sistema

### Recuperar Contraseña

1. Haz clic en **"¿Olvidaste tu contraseña?"**
2. Ingresa tu correo electrónico
3. Haz clic en **"Enviar"**
4. Revisa tu correo y sigue las instrucciones
5. Crea una nueva contraseña

---

## 👨‍💼 Panel de Administrador

Los administradores tienen control completo del sistema.

### Dashboard Principal

Al iniciar sesión como admin verás:
- **Estadísticas generales** (eventos, usuarios, inscripciones)
- **Eventos próximos**
- **Actividad reciente**
- **Accesos rápidos**

### Gestión de Eventos

#### Crear Nuevo Evento

1. Ve a **"Eventos"** en el menú lateral
2. Haz clic en **"+ Nuevo Evento"**
3. Completa el formulario:

   **Información Básica:**
   - Nombre del evento
   - Descripción
   - Tipo de evento (CATEC, Software Libre, Microsoft, etc.)
   - Fecha de inicio
   - Fecha de fin
   - Ubicación

   **Configuración:**
   - Aforo máximo
   - Requiere inscripción (sí/no)
   - Visible para estudiantes (sí/no)
   - Estado (activo/inactivo)

4. Haz clic en **"Guardar"**

#### Editar Evento

1. Ve a la lista de eventos
2. Haz clic en el evento que deseas editar
3. Haz clic en el botón **"Editar"** (ícono de lápiz)
4. Modifica los campos necesarios
5. Haz clic en **"Guardar cambios"**

#### Eliminar Evento

1. Ve a la lista de eventos
2. Haz clic en el evento
3. Haz clic en **"Eliminar"** (ícono de papelera)
4. Confirma la eliminación

> ⚠️ **Advertencia:** Eliminar un evento también eliminará todas sus sesiones e inscripciones

### Gestión de Ponentes

#### Agregar Ponente

1. Ve a **"Ponentes"** en el menú
2. Haz clic en **"+ Nuevo Ponente"**
3. Completa la información:
   - Nombre completo
   - Email
   - Especialidad
   - Biografía
   - Foto de perfil (opcional)
   - Redes sociales (LinkedIn, Twitter, etc.)
4. Haz clic en **"Guardar"**

#### Editar/Eliminar Ponente

Similar al proceso de eventos

### Gestión de Sesiones/Ponencias

#### Crear Nueva Sesión

1. Selecciona un evento
2. Ve a la pestaña **"Sesiones"**
3. Haz clic en **"+ Nueva Sesión"**
4. Completa el formulario:
   - Título de la sesión
   - Descripción
   - Ponente (selecciona de la lista)
   - Fecha y hora de inicio
   - Duración
   - Sala/Ubicación
   - Aforo
   - Modalidad (presencial/virtual/híbrido)
   - Link de sesión virtual (si aplica)
5. Haz clic en **"Guardar"**

#### Generar Código QR para Asistencia

1. Ve a la sesión
2. Haz clic en **"Código QR"**
3. Se generará un código único para esa sesión
4. Los estudiantes pueden escanearlo para registrar asistencia

### Gestión de Usuarios

#### Ver Lista de Usuarios

1. Ve a **"Usuarios"** en el menú
2. Verás todos los usuarios registrados
3. Puedes filtrar por:
   - Rol (admin, estudiante, docente, ponente)
   - Estado (activo/inactivo)
   - Fecha de registro

#### Editar Rol de Usuario

1. Selecciona un usuario
2. Haz clic en **"Editar"**
3. Cambia el rol en el dropdown
4. Haz clic en **"Guardar"**

Roles disponibles:
- **admin**: Acceso completo
- **estudiante**: Inscripción a eventos
- **docente**: Acceso a reportes
- **ponente**: Ver sus ponencias

#### Activar/Desactivar Usuario

1. Selecciona un usuario
2. Haz clic en el switch **"Activo"**
3. Confirma la acción

### Reportes y Estadísticas

#### Ver Reportes

1. Ve a **"Reportes"** en el menú
2. Selecciona el tipo de reporte:
   - **Asistencias por evento**
   - **Inscripciones por periodo**
   - **Usuarios activos**
   - **Ponencias más populares**

#### Exportar Datos

1. En cualquier reporte, haz clic en **"Exportar"**
2. Selecciona el formato:
   - Excel (.xlsx)
   - CSV (.csv)
   - PDF (.pdf)
3. El archivo se descargará automáticamente

### Datos de Demostración (Seed Data)

Para poblar la base de datos con datos de ejemplo:

1. Ve a **"Configuración"** > **"Datos de Prueba"**
2. Haz clic en **"Cargar Datos de Demostración"**
3. Espera a que se completen las inserciones
4. Verás eventos, ponentes y sesiones de ejemplo

> ⚠️ **Solo para desarrollo:** No usar en producción

---

## 👨‍🎓 Panel de Estudiante

Los estudiantes pueden inscribirse y participar en eventos.

### Dashboard de Estudiante

Al iniciar sesión verás:
- **Mis próximos eventos**
- **Eventos disponibles**
- **Historial de participación**
- **Certificados disponibles**

### Explorar Eventos

#### Ver Eventos Disponibles

1. Ve a **"Eventos"** o permanece en el dashboard
2. Verás tarjetas con todos los eventos activos
3. Cada tarjeta muestra:
   - Nombre del evento
   - Fecha
   - Ubicación
   - Número de sesiones
   - Estado de inscripción

#### Ver Detalles de Evento

1. Haz clic en cualquier evento
2. Verás información completa:
   - Descripción detallada
   - Cronograma de sesiones
   - Ponentes participantes
   - Requisitos
   - Ubicación

### Inscripción a Eventos

#### Inscribirse a un Evento

1. Abre un evento que te interese
2. Revisa las sesiones disponibles
3. Selecciona las sesiones que deseas asistir
4. Haz clic en **"Inscribirse"**
5. Confirma tu inscripción
6. Recibirás una confirmación por correo

#### Cancelar Inscripción

1. Ve a **"Mis Eventos"**
2. Encuentra el evento
3. Haz clic en **"Cancelar Inscripción"**
4. Confirma la cancelación

> 📌 **Nota:** Puedes cancelar hasta 24 horas antes del evento

### Asistencia a Sesiones

#### Registrar Asistencia con QR

1. Llega a la sesión puntualmente
2. Abre la app
3. Ve a **"Mis Eventos"** > Selecciona el evento
4. Haz clic en **"Escanear QR"**
5. Apunta la cámara al código QR mostrado
6. Recibirás confirmación de asistencia

#### Ver Mis Asistencias

1. Ve a **"Historial"**
2. Selecciona un evento pasado
3. Verás todas las sesiones y tu asistencia
4. Ícono verde ✅ = Asististe
5. Ícono rojo ❌ = No asististe

### Certificados

#### Descargar Certificado

1. Ve a **"Certificados"**
2. Verás eventos completados
3. Haz clic en **"Descargar Certificado"**
4. El PDF se generará y descargará

Requisitos para obtener certificado:
- Haber asistido al 80% de las sesiones
- Evento finalizado
- Certificado generado por el admin

---

## 👨‍🏫 Panel de Docente

Los docentes tienen acceso a reportes y gestión limitada.

### Dashboard de Docente

- Vista de eventos activos
- Estadísticas de asistencia
- Reportes rápidos

### Ver Reportes

1. Ve a **"Reportes"**
2. Selecciona el evento o periodo
3. Visualiza estadísticas de:
   - Asistencia por sesión
   - Inscripciones
   - Participación estudiantil

### Exportar Datos

Similar al proceso de administrador, pero limitado a datos de lectura.

---

## 📱 Sistema de Asistencia QR

### Para Administradores (Generar QR)

1. Ve al evento activo
2. Selecciona la sesión en curso
3. Haz clic en **"Mostrar QR de Asistencia"**
4. Se generará un código QR único
5. Muéstralo en pantalla o proyéctalo
6. El QR es válido solo durante la sesión

### Para Estudiantes (Escanear QR)

1. Abre la app en la sesión
2. Ve a **"Mis Eventos"**
3. Selecciona el evento actual
4. Haz clic en **"Registrar Asistencia"**
5. Escanea el código QR
6. Verás confirmación inmediata

> 🔒 **Seguridad:** Cada QR tiene un token único y expira al finalizar la sesión

### Verificación de Asistencia

El sistema verifica automáticamente:
- ✅ Usuario inscrito en el evento
- ✅ QR válido para la sesión actual
- ✅ Tiempo dentro del horario permitido
- ✅ No registrado previamente en esa sesión

---

## ❓ Preguntas Frecuentes

### Generales

**¿Puedo usar la misma cuenta en varios dispositivos?**
Sí, puedes iniciar sesión desde múltiples dispositivos con la misma cuenta.

**¿Cómo cambio mi contraseña?**
Ve a Perfil > Configuración > Cambiar Contraseña

**¿Puedo cambiar mi correo electrónico?**
No directamente. Contacta al administrador para cambios de correo.

### Para Estudiantes

**¿Puedo inscribirme a un evento que ya comenzó?**
Solo si el administrador lo permite y hay cupos disponibles.

**¿Qué pasa si llego tarde a una sesión?**
Depende de la configuración. Algunos eventos permiten registro tardío (15 min).

**¿Cómo sé si mi asistencia fue registrada?**
Verás una confirmación inmediata en pantalla y un registro en tu historial.

**¿Puedo inscribirme solo a algunas sesiones de un evento?**
Sí, puedes seleccionar sesiones individuales durante la inscripción.

### Para Administradores

**¿Puedo editar un evento después de crear sesiones?**
Sí, pero ten cuidado de no cambiar fechas si ya hay inscritos.

**¿Cómo elimino inscripciones duplicadas?**
Ve a la lista de inscripciones del evento y elimina manualmente.

**¿Puedo importar usuarios masivamente?**
Actualmente no, pero está en desarrollo. Por ahora, los usuarios se registran individualmente.

### Técnicas

**La app no carga, ¿qué hago?**
1. Verifica tu conexión a internet
2. Cierra y vuelve a abrir la app
3. Limpia caché (Configuración > Almacenamiento)
4. Reinstala la app si persiste

**El QR no escanea**
1. Verifica permisos de cámara
2. Asegúrate de tener buena iluminación
3. Limpia el lente de la cámara
4. Prueba con otro dispositivo

**Error "No autorizado"**
Tu sesión expiró. Cierra sesión y vuelve a iniciar.

---

## 📞 Soporte Técnico

### Contacto

- **Email:** eventos-epis@upt.pe
- **Teléfono:** (052) XXX-XXXX
- **Horario:** Lunes a Viernes, 8:00 AM - 6:00 PM

### Reportar un Bug

1. Ve a GitHub Issues
2. Crea un nuevo issue
3. Describe el problema detalladamente
4. Adjunta capturas de pantalla si es posible

---

## 📚 Recursos Adicionales

- [Documentación Técnica](API_DOCUMENTATION.md)
- [Guía de Instalación](INSTALLATION.md)
- [Guía de Contribución](CONTRIBUTING.md)
- [Política de Privacidad](PRIVACY_POLICY.md)

---

**Universidad Privada de Tacna**  
Escuela Profesional de Ingeniería de Sistemas

*Última actualización: Octubre 2025*

