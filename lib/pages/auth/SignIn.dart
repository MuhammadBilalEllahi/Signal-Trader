import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/AuthService.dart';
import '../services/UserService.dart';

class SignIn extends StatefulWidget {
  final Function() changeSignIn;
  const SignIn({super.key, required this.changeSignIn});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  _signIn(){
    Provider.of<AuthService>(context,listen: false).signIn(_emailController.text, _passwordController.text);
  }

  _signInGoogle(){
    Provider.of<AuthService>(context,listen: false).signInGoogle();
  }





  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextField(
          controller: _emailController,

        ),
        TextField(
          controller: _passwordController,
        ),
        ElevatedButton(onPressed: ()=>_signIn(), child: Text("Sign in")),
        TextButton(onPressed: ()=>widget.changeSignIn(), child: Text("Sign Up")),
        TextButton(onPressed: ()=>_signInGoogle(), child: Text('Google Auth'))
      ],
    );
  }
}
