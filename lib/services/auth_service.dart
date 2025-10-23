import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
final _auth = FirebaseAuth.instance;


User? get currentUser => _auth.currentUser;


Stream<User?> authState() => _auth.authStateChanges();
}