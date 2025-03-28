import 'package:flutter/material.dart';
import 'package:tradingapp/pages/auth/SignIn.dart';
import 'package:tradingapp/pages/auth/SignUp.dart';
import 'package:tradingapp/pages/auth/PhoneAuthScreen.dart';
import 'package:tradingapp/pages/auth/services/AuthService.dart';
import 'package:tradingapp/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/auth/PasswordResetScreen.dart';

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

class SignOrSignUp extends StatefulWidget {
  const SignOrSignUp({super.key});

  @override
  State<SignOrSignUp> createState() => _SignOrSignUpState();
}

class _SignOrSignUpState extends State<SignOrSignUp> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final result = await context.read<AuthService>().signInWithGoogle();
      if (result == null) {
        // User cancelled the sign in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in cancelled')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing in with Google: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Welcome to Trading App',
                style: TextStyle(
                  color: MyTheme.foreground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _handleGoogleSignIn(context),
                icon: _isLoading 
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: MyTheme.foreground,
                      ),
                    )
                  : Image.asset(
                      'assets/images/google.png',
                      height: 24,
                    ),
                label: Text(_isLoading ? 'Signing in...' : 'Continue with Google'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.card,
                  foregroundColor: MyTheme.foreground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhoneAuthScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text('Continue with Phone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.card,
                  foregroundColor: MyTheme.foreground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: MyTheme.mutedForeground),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: MyTheme.mutedForeground,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: MyTheme.mutedForeground),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: _isLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInOrSign(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: MyTheme.foreground,
                  side: BorderSide(color: MyTheme.border),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Sign up with Email'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInOrSign(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: MyTheme.mutedForeground,
                ),
                child: const Text('Already have an account? Sign in'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PasswordResetScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: MyTheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
