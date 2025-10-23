import 'package:cloud_firestore/cloud_firestore.dart';


class SessionModel {
final String id;
final String eventId;
final String title;
final String? abstract;
final String? room;
final String? speakerId;
final DateTime? startAt;
final DateTime? endAt;


SessionModel({
required this.id,
required this.eventId,
required this.title,
this.abstract,
this.room,
this.speakerId,
this.startAt,
this.endAt,
});


factory SessionModel.fromMap(String id, Map<String, dynamic> d) => SessionModel(
id: id,
eventId: d['eventId'] ?? '',
title: d['title'] ?? '',
abstract: d['abstract'],
room: d['room'],
speakerId: d['speakerId'],
startAt: (d['startAt'] as Timestamp?)?.toDate(),
endAt: (d['endAt'] as Timestamp?)?.toDate(),
);


Map<String, dynamic> toMap() => {
'eventId': eventId,
'title': title,
'abstract': abstract,
'room': room,
'speakerId': speakerId,
'startAt': startAt != null ? Timestamp.fromDate(startAt!) : null,
'endAt': endAt != null ? Timestamp.fromDate(endAt!) : null,
}..removeWhere((k, v) => v == null);
}