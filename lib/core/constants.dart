// lib/core/constants.dart

/// Constantes de colecciones de Firestore
class FirestoreCollections {
  static const String users = 'usuarios';
  static const String events = 'eventos';
  static const String sessions = 'sesiones';
  static const String speakers = 'ponentes';
  static const String registrations = 'inscripciones';
  static const String attendance = 'asistencia';
}

/// Constantes de roles de usuario
class UserRoles {
  static const String admin = 'admin';
  static const String student = 'estudiante';
  static const String teacher = 'docente';
  static const String speaker = 'ponente';
  
  static List<String> get all => [admin, student, teacher, speaker];
  
  static bool isValid(String role) => all.contains(role.toLowerCase());
}

/// Constantes de estados de eventos
class EventStatus {
  static const String active = 'activo';
  static const String draft = 'borrador';
  static const String finished = 'finalizado';
  static const String cancelled = 'cancelado';
  
  static List<String> get all => [active, draft, finished, cancelled];
}

/// Constantes de modalidades de sesiones
class SessionModality {
  static const String inPerson = 'Presencial';
  static const String virtual = 'Virtual';
  static const String hybrid = 'Híbrida';
  
  static List<String> get all => [inPerson, virtual, hybrid];
}

/// Constantes de dominios institucionales
class InstitutionalDomains {
  static const String upt = '@virtual.upt.pe';
  
  static bool isInstitutional(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    return normalizedEmail.endsWith(upt);
  }
}

/// Constantes de validación
class ValidationConstants {
  static const int minPasswordLength = 6;
  static const int maxEventNameLength = 100;
  static const int maxDescriptionLength = 500;
  
  static final RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
}

/// Constantes de la UI
class UIConstants {
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 16.0;
  static const double cardElevation = 0.0;
  static const double maxContentWidth = 420.0;
  
  static const Duration animationDuration = Duration(milliseconds: 220);
  static const Duration snackbarDuration = Duration(seconds: 3);
}

/// Mensajes de error comunes
class ErrorMessages {
  static const String networkError = 'Error de conexión. Verifica tu internet.';
  static const String unknownError = 'Ocurrió un error inesperado.';
  static const String permissionDenied = 'No tienes permisos para esta acción.';
  static const String invalidEmail = 'Correo electrónico inválido.';
  static const String weakPassword = 'La contraseña debe tener al menos 6 caracteres.';
  static const String emailAlreadyInUse = 'Este correo ya está registrado.';
  static const String userNotFound = 'Usuario no encontrado.';
  static const String wrongPassword = 'Contraseña incorrecta.';
  static const String accountDisabled = 'Tu cuenta está desactivada.';
  static const String institutionalOnly = 'Solo se permiten correos institucionales @virtual.upt.pe';
}

/// Mensajes de éxito
class SuccessMessages {
  static const String loginSuccess = 'Inicio de sesión exitoso';
  static const String registerSuccess = 'Registro exitoso';
  static const String updateSuccess = 'Actualización exitosa';
  static const String deleteSuccess = 'Eliminación exitosa';
  static const String passwordResetSent = 'Se ha enviado un correo de recuperación';
}

