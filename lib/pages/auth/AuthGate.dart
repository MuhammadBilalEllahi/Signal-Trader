import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/auth/OnBoardingScreen.dart';
import 'package:tradingapp/pages/auth/SignOrSignUp.dart';
import 'package:tradingapp/pages/root/Layout.dart';
import 'package:tradingapp/pages/auth/services/UserService.dart';
import 'package:tradingapp/pages/auth/services/AuthService.dart';
import 'package:tradingapp/pages/root/profile/providers/profile_provider.dart';
import 'package:tradingapp/pages/signals/providers/signals_provider.dart';

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
      body: StreamBuilder<User?>(
        stream: _firebaseAuth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error Occurred"));
          }
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data != null) {
            // Update user state in UserService
            // WidgetsBinding.instance.addPostFrameCallback((_) {
              final userService = Provider.of<UserService>(context, listen: false);
              final authService = Provider.of<AuthService>(context, listen: false);
              final profileProvider = Provider.of<ProfileProvider>(context, listen: false); 
              final signalsProvider = Provider.of<SignalsProvider>(context, listen: false);
              
              // Only update if the user is different
              if (userService.user?.uid != snapshot.data?.uid) {
                userService.setUser(snapshot.data);
                // Check 2FA status
                authService.is2FAEnabled().then((isEnabled) {
                  if (isEnabled) {
                    authService.reset2FARequirement();
                  }
                });
              }
            // });

            return const Layout();
          } else {
            return const OnBoardingScreen();
          }
        },
      ),
    );
  }
}
