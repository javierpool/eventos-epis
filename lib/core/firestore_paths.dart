class FirestorePaths {
  // Colecciones (ES)
  static const String users    = 'usuarios';
  static const String eventos  = 'eventos';
  static const String ponentes = 'ponentes';

  // Si el módulo de estudiante usa “events”, mantenlo también:
  static const String events   = 'events';

  // Helpers
  static String user(String uid) => '$users/$uid';

  // events (inglés) - módulo alumno
  static String event(String eventId) => '$events/$eventId';
  static String registrations(String eventId) => '$events/$eventId/registrations';
  static String registration(String eventId, String uid) => '$events/$eventId/registrations/$uid';
  static String attendances(String eventId) => '$events/$eventId/attendances';
  static String attendance(String eventId, String uid) => '$events/$eventId/attendances/$uid';
}
