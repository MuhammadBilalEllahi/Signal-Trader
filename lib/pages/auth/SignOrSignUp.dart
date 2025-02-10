import 'package:flutter/material.dart';
import 'package:tradingapp/pages/auth/SignIn.dart';
import 'package:tradingapp/pages/auth/SignUp.dart';

class SignInOrSign extends StatefulWidget {
  const SignInOrSign({super.key});

  @override
  State<SignInOrSign> createState() => _SignInOrSignState();
}

class _SignInOrSignState extends State<SignInOrSign> {
  bool _isSignIn = true;



  _changeSignIn(){
    setState(() {
      _isSignIn=!_isSignIn;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isSignIn?SignIn(changeSignIn: ()=>_changeSignIn()):SignUp(changeSignUp: ()=>_changeSignIn()),
    );
  }
}
