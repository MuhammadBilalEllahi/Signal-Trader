import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
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
  late bool _showPassword = false;


  _signIn(){
    if(_emailController.text.isEmpty||_passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Email and Password")));
      return;
    }
    Provider.of<AuthService>(context,listen: false).signIn(_emailController.text, _passwordController.text);
  }

  _signInGoogle(){
    Provider.of<AuthService>(context,listen: false).signInGoogle();
  }





  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      children: [
        TextField(
            cursorColor: Theme.of(context).textTheme.bodySmall!.color,
            style: Theme.of(context).textTheme.bodyMedium,
            onSubmitted: (e)=>_signIn(),
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.alternate_email_outlined),
              hintText: "email",
            )),
        SizedBox(height: 10),
        TextField(
        cursorColor: Theme.of(context).textTheme.bodySmall!.color,
        style: Theme.of(context).textTheme.bodyMedium,
        onSubmitted: (e)=>_signIn(),
        controller: _passwordController,
        obscureText: !_showPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.password),
          suffixIcon: IconButton(onPressed: (){setState(() {_showPassword=!_showPassword;});}, icon: _showPassword ? const Icon(CupertinoIcons.eye_slash_fill) : const Icon(CupertinoIcons.eye_fill)),
          hintText: "Password",
        )),
        SizedBox(height: 25),
        ElevatedButton(onPressed: ()=>_signIn(), child: Text("Sign in")),
        SizedBox(height: 20),
        GoogleAuthButton(
          text: "Sign in with Google",
          style: AuthButtonStyle(padding: EdgeInsets.symmetric(vertical: 18)),
          onPressed: ()=>_signInGoogle(),),
        const SizedBox(height: 25),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Don't have an account?", style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color,fontWeight: FontWeight.w400),),
          const SizedBox(width: 4),
          GestureDetector(onTap: ()=>widget.changeSignIn(), child: Text("Sign Up", style: TextStyle(fontWeight: FontWeight.w400, color: HexColor("#f7cf56")))),
        ]),
      ],
    );
  }
}
