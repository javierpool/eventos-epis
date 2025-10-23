import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/app_theme.dart';
import 'features/auth/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EventosEpisApp());
}

class EventosEpisApp extends StatelessWidget {
  const EventosEpisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EVENTOS EPIS – UPT',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),             // 👈 tema centralizado
      home: const LoginScreen(),          // 👈 tu login actual
    );
  }
}
