import 'package:cloud_firestore/cloud_firestore.dart';


class RegistrationModel {
final String id;
final String eventId;
final String userId;
final DateTime createdAt;


RegistrationModel({
required this.id,
required this.eventId,
required this.userId,
required this.createdAt,
});


factory RegistrationModel.fromMap(String id, Map<String, dynamic> d) => RegistrationModel(
id: id,
eventId: d['eventId'] ?? '',
userId: d['userId'] ?? '',
createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
);


Map<String, dynamic> toMap() => {
'eventId': eventId,
'userId': userId,
'createdAt': Timestamp.fromDate(createdAt),
};
}