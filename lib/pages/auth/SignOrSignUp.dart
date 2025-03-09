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

  void _changeSignIn() {
    setState(() {
      _isSignIn = !_isSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(_isSignIn ? 1.0 : -1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          child: _isSignIn
              ? SignIn(
                  key: const ValueKey('signin'),
                  changeSignIn: _changeSignIn,
                )
              : SignUp(
                  key: const ValueKey('signup'),
                  changeSignUp: _changeSignIn,
                ),
        ),
      ),
    );
  }
}
