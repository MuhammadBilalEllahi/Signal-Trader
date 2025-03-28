import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/auth/services/BiometricService.dart';
import 'package:tradingapp/theme/theme.dart';

class BiometricAuthGate extends StatefulWidget {
  final Widget child;

  const BiometricAuthGate({
    super.key,
    required this.child,
  });

  @override
  State<BiometricAuthGate> createState() => _BiometricAuthGateState();
}

class _BiometricAuthGateState extends State<BiometricAuthGate> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final biometricService = context.read<BiometricService>();
    await biometricService.checkBiometricStatus();
    if (mounted) {
      setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BiometricService>(
      builder: (context, biometricService, child) {
        if (_isChecking) {
          return Scaffold(
            backgroundColor: MyTheme.background,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!biometricService.isAuthenticated) {
          return Scaffold(
            backgroundColor: MyTheme.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 64,
                    color: MyTheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication Required',
                    style: TextStyle(
                      color: MyTheme.foreground,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please authenticate to access the app',
                    style: TextStyle(
                      color: MyTheme.mutedForeground,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _checkBiometric,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Authenticate'),
                  ),
                ],
              ),
            ),
          );
        }

        return widget.child;
      },
    );
  }
} 