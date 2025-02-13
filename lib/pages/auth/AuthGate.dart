import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/auth/OnBoardingScreen.dart';
import 'package:tradingapp/pages/auth/SignOrSignUp.dart';
import 'package:tradingapp/pages/root/Layout.dart';
import 'package:tradingapp/pages/services/UserService.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // Firebase Auth  (set up)
  // User Service (limited -> uid)
  // Sign Up/In Screen
  // FirebaseAuth -> Date shift to  user service (uid etc) -> FireStore -> Data shift to user service (more data)
  // Firestore : data: ->  first name, last name, phone, address, gender(trans), dob, identity[]

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: _firebaseAuth.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text("Error Occurred"));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center();
              }
              if (snapshot.hasData) {
                // print("USER DATA is ${snapshot.data}\n\n");
                Future.microtask(() {
                  Provider.of<UserService>(context, listen: false)
                      .setUser(snapshot.data);
                });

                return Layout();
              } else {
                return OnBoardingScreen();
              }
            }));
  }
}
