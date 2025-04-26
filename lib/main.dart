import 'package:flutter/material.dart';
import 'package:todolist_ukk/screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService.initDb(); // Pastikan DB sudah siap
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Doto',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(), // <-- ganti jadi SplashScreen
    );
  }
}
