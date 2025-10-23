import 'package:cloud_functions/cloud_functions.dart';

class AdminFunctionsService {
  final _fn = FirebaseFunctions.instance.httpsCallable('createUserByAdmin');

  Future<Map<String, dynamic>> createUser({
    required String email,
    String? displayName,
    required String role, // 'ponente' | 'docente' | 'encargado' | (opcional) 'admin'
    String? tempPassword,
  }) async {
    final res = await _fn.call({
      'email': email,
      'displayName': displayName,
      'role': role,
      if (tempPassword != null && tempPassword.trim().isNotEmpty)
        'password': tempPassword.trim(),
    });
    return Map<String, dynamic>.from(res.data as Map);
  }
}
