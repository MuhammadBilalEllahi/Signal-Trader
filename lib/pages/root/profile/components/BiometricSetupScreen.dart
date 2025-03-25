import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradingapp/theme/theme.dart';

class BiometricSetupScreen extends StatefulWidget {
  const BiometricSetupScreen({super.key});

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool isBiometricAvailable;
    List<BiometricType> availableBiometrics;
    
    try {
      isBiometricAvailable = await _localAuth.canCheckBiometrics;
      availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      // Check if biometric lock is already enabled
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('biometric_lock_enabled') ?? false;

      setState(() {
        _isBiometricAvailable = isBiometricAvailable;
        _availableBiometrics = availableBiometrics;
        _isBiometricEnabled = isEnabled;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleBiometricLock() async {
    if (!_isBiometricAvailable) return;

    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: _isBiometricEnabled
            ? 'Authenticate to disable biometric lock'
            : 'Authenticate to enable biometric lock',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('biometric_lock_enabled', !_isBiometricEnabled);
        
        setState(() {
          _isBiometricEnabled = !_isBiometricEnabled;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isBiometricEnabled
                    ? 'Biometric lock enabled'
                    : 'Biometric lock disabled',
              ),
              backgroundColor: _isBiometricEnabled ? Colors.green : Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Biometric Lock',
          style: TextStyle(
            color: MyTheme.foreground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: MyTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MyTheme.border),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _availableBiometrics.contains(BiometricType.fingerprint)
                              ? Icons.fingerprint
                              : Icons.face,
                          size: 64,
                          color: _isBiometricAvailable
                              ? MyTheme.primary
                              : MyTheme.mutedForeground,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isBiometricAvailable
                              ? 'Biometric authentication is available'
                              : 'Biometric authentication is not available',
                          style: TextStyle(
                            color: MyTheme.foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  if (_isBiometricAvailable) ...[
                    const SizedBox(height: 24),
                    SwitchListTile(
                      title: Text(
                        'Enable Biometric Lock',
                        style: TextStyle(
                          color: MyTheme.foreground,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'Use fingerprint or face ID to unlock the app',
                        style: TextStyle(
                          color: MyTheme.mutedForeground,
                          fontSize: 14,
                        ),
                      ),
                      value: _isBiometricEnabled,
                      onChanged: (bool value) => _toggleBiometricLock(),
                      activeColor: MyTheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'When enabled, you\'ll need to authenticate with your biometric data every time you open the app.',
                        style: TextStyle(
                          color: MyTheme.mutedForeground,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Please set up fingerprint or face recognition in your device settings to use this feature.',
                        style: TextStyle(
                          color: MyTheme.mutedForeground,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
    );
  }
} 