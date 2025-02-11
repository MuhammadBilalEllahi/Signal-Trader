import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
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
  late bool _showPassword = false;


  _signUp(){
    if(_emailController.text.isEmpty||_passwordController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Enter Email and Password")));
      return;
    }
    Provider.of<AuthService>(context,listen: false).signUp(_emailController.text, _passwordController.text);
  }



  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 10),
      children: [
        TextField(
            cursorColor: Theme.of(context).textTheme.bodySmall!.color,
            style: Theme.of(context).textTheme.bodyMedium,
            onSubmitted: (e)=>_signUp(),
            controller: _emailController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.alternate_email_outlined),
              hintText: "email",
            )),
        SizedBox(height: 10),
        TextField(
            cursorColor: Theme.of(context).textTheme.bodySmall!.color,
            style: Theme.of(context).textTheme.bodyMedium,
            onSubmitted: (e)=>_signUp(),
            controller: _passwordController,
            obscureText: !_showPassword,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.password),
              suffixIcon: IconButton(onPressed: (){setState(() {_showPassword=!_showPassword;});}, icon: _showPassword ? const Icon(CupertinoIcons.eye_slash_fill) : const Icon(CupertinoIcons.eye_fill)),
              hintText: "Password",
            )),
        ElevatedButton(onPressed: ()=>_signUp(), child: Text("Sign up")),
        const SizedBox(height: 25),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text("Already have an account?", style: TextStyle(color: Theme.of(context).textTheme.bodySmall!.color,fontWeight: FontWeight.w400),),
          const SizedBox(width: 4),
          GestureDetector(onTap: ()=>widget.changeSignUp(), child: Text("Sign In", style: TextStyle(fontWeight: FontWeight.w400, color: HexColor("#f7cf56")))),
        ]),
      ],
    );
  }
}
