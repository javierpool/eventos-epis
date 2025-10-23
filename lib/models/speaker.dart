class SpeakerModel {
final String id;
final String name;
final String? email;
final String? organization;
final String? bio;
final bool external;


SpeakerModel({
required this.id,
required this.name,
this.email,
this.organization,
this.bio,
this.external = false,
});


factory SpeakerModel.fromMap(String id, Map<String, dynamic> d) => SpeakerModel(
id: id,
name: d['name'] ?? '',
email: d['email'],
organization: d['organization'],
bio: d['bio'],
external: d['external'] ?? false,
);


Map<String, dynamic> toMap() => {
'name': name,
'email': email,
'organization': organization,
'bio': bio,
'external': external,
}..removeWhere((k, v) => v == null);
}