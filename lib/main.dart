import 'package:flutter/material.dart';
import 'welcome_screen.dart'; // ← исправленный импорт

void main() {
  runApp(const ReLiveApp());
}

class ReLiveApp extends StatelessWidget {
  const ReLiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReLive',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const WelcomeScreen(),
    );
  }
}