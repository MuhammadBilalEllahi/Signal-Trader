import 'package:flutter/material.dart';
import 'package:tradingapp/pages/auth/AuthGate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trading App',
      theme: ThemeData(useMaterial3: true,),
      home: const AuthGate(),
    );
  }
}
