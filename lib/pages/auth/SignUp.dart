import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/AuthService.dart';

class SignUp extends StatefulWidget {
  final Function() changeSignUp;
  const SignUp({super.key, required this.changeSignUp});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();



  _signUp(){
    Provider.of<AuthService>(context,listen: false).signUp(_emailController.text, _passwordController.text);
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
        ElevatedButton(onPressed: ()=>_signUp(), child: Text("Sign up")),
        TextButton(onPressed: ()=>widget.changeSignUp(), child: Text("Sign In"))
      ],
    );
  }
}
