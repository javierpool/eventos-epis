import 'package:cloud_firestore/cloud_firestore.dart';


class EventModel {
final String id;
final String title;
final String? description;
final String? venue;
final String status; // draft | published | closed
final DateTime? startAt;
final DateTime? endAt;


EventModel({
required this.id,
required this.title,
this.description,
this.venue,
this.status = 'draft',
this.startAt,
this.endAt,
});


factory EventModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
final d = doc.data()!;
return EventModel(
id: doc.id,
title: d['title'] ?? '',
description: d['description'],
venue: d['venue'],
status: d['status'] ?? 'draft',
startAt: (d['startAt'] as Timestamp?)?.toDate(),
endAt: (d['endAt'] as Timestamp?)?.toDate(),
);
}


Map<String, dynamic> toMap() => {
'title': title,
'description': description,
'venue': venue,
'status': status,
'startAt': startAt != null ? Timestamp.fromDate(startAt!) : null,
'endAt': endAt != null ? Timestamp.fromDate(endAt!) : null,
'updatedAt': FieldValue.serverTimestamp(),
}..removeWhere((k, v) => v == null);
}