class FirestorePaths {
static const users = 'users';
static const events = 'events';
static const speakers = 'speakers';
static const sessions = 'sessions';
static const registrations = 'registrations';
static const attendance = 'attendance';
static const certificates = 'certificates';


static String event(String id) => '$events/$id';
static String speaker(String id) => '$speakers/$id';
static String session(String id) => '$sessions/$id';
static String registration(String id) => '$registrations/$id';
}