import 'package:cloud_firestore/cloud_firestore.dart';

class Certificate {
  final String uid; // docId
  final String code;
  final Timestamp issuedAt;
  final String pdfUrl;
  final String hash;

  Certificate({
    required this.uid,
    required this.code,
    required this.issuedAt,
    required this.pdfUrl,
    required this.hash,
  });

  factory Certificate.fromMap(Map<String, dynamic> m, String id) => Certificate(
    uid: id,
    code: m['code'] ?? '',
    issuedAt: (m['issuedAt'] as Timestamp?) ?? Timestamp.now(),
    pdfUrl: m['pdfUrl'] ?? '',
    hash: m['hash'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'code': code,
    'issuedAt': issuedAt,
    'pdfUrl': pdfUrl,
    'hash': hash,
  };
}
