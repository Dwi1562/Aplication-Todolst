import 'package:flutter/material.dart';
import 'package:todolist_ukk/models/user_model.dart';
import 'package:todolist_ukk/screens/login_screen.dart';
import 'package:todolist_ukk/services/db_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBService.initDb();
  await DBService.registerUser(UserModel(username: "admin", password: "admin"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo',
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
