import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  bool isInstitutional(String email) {
    final e = email.trim().toLowerCase();
    return e.endsWith('@upt.pe') || e.endsWith('@virtual.upt.pe');
  }
}
