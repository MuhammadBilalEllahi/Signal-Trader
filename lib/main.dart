import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/auth/AuthGate.dart';
import 'package:tradingapp/pages/services/AuthService.dart';
import 'package:tradingapp/pages/services/UserService.dart';
import 'package:tradingapp/pages/services/firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (create)=>UserService()),
        ChangeNotifierProvider(create: (create)=>AuthService())
      ]
      ,
      child:const MyApp()));
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
