class AppUser {
final String uid;
final String email;
final String? displayName;
final String role; // admin | docente | estudiante | externo
final bool active;


AppUser({
required this.uid,
required this.email,
this.displayName,
required this.role,
this.active = true,
});


factory AppUser.fromMap(String id, Map<String, dynamic> map) => AppUser(
uid: id,
email: map['email'] ?? '',
displayName: map['displayName'],
role: map['role'] ?? 'estudiante',
active: map['active'] ?? true,
);


Map<String, dynamic> toMap() => {
'email': email,
'displayName': displayName,
'role': role,
'active': active,
}..removeWhere((k, v) => v == null);
}