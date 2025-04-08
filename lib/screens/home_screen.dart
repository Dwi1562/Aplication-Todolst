import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home - Task Planner")),
      body: const Center(
        child: Text("Welcome to your To-Do Planner", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
