import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/firestore_paths.dart';


class CertificateService {
final col = FirebaseFirestore.instance.collection(FirestorePaths.certificates);


Future<void> issue({required String eventId, required String userId, required String code}) async {
await col.doc(code).set({
'eventId': eventId,
'userId': userId,
'issuedAt': FieldValue.serverTimestamp(),
'code': code,
'valid': true,
});
}


Future<bool> validate(String code) async {
final d = await col.doc(code).get();
return d.exists && (d.data()?['valid'] == true);
}
}