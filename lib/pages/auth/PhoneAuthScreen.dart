import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/auth/services/AuthService.dart';
import 'package:tradingapp/theme/theme.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _smsController.dispose();
    super.dispose();
  }

  String _getReadableErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-phone-number':
        return 'Invalid phone number format. Please use format: +[country code][number] (e.g., +1234567890)';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'session-expired':
        return 'Verification session expired. Please request a new code.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      default:
        return 'An error occurred. Please try again later.';
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _verifyPhone() async {
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Please enter your phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().signUpWithPhone(
        _phoneController.text,
      );
      
      setState(() {
        _codeSent = true;  // Only set to true if no error is thrown
      });
    } catch (e) {
      String errorMessage = e.toString();
      
      // Extract error code from Firebase error message
      final RegExp regExp = RegExp(r'\[(.*?)\]');
      final match = regExp.firstMatch(errorMessage);
      if (match != null && match.groupCount >= 1) {
        final errorCode = match.group(1)?.split('/')[1] ?? '';
        errorMessage = _getReadableErrorMessage(errorCode);
      }

      _showErrorSnackBar(errorMessage);
      setState(() {
        _codeSent = false;  // Ensure we stay on phone input screen
        _verificationId = null;  // Reset verification ID
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifySmsCode() async {
    if (_smsController.text.isEmpty) {
      _showErrorSnackBar('Please enter the verification code');
      return;
    }

    if (_verificationId == null) {
      _showErrorSnackBar('Verification session expired. Please request a new code.');
      setState(() => _codeSent = false);
      return;
    }

    if (_smsController.text.length != 6) {
      _showErrorSnackBar('Please enter a valid 6-digit code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().verifyPhoneCode(
        _verificationId!,
        _smsController.text,
      );
      
      // Show success message before popping
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone number verified successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      
      Navigator.pop(context);
    } catch (e) {
      String errorMessage = e.toString();
      
      final RegExp regExp = RegExp(r'\[(.*?)\]');
      final match = regExp.firstMatch(errorMessage);
      if (match != null && match.groupCount >= 1) {
        final errorCode = match.group(1)?.split('/')[1] ?? '';
        errorMessage = _getReadableErrorMessage(errorCode);
      }

      _showErrorSnackBar(errorMessage);
      _smsController.clear();
    } finally {
      setState(() => _isLoading = false);
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
          'Phone Authentication',
          style: TextStyle(
            color: MyTheme.foreground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_codeSent) ...[
              Text(
                'Enter your phone number',
                style: TextStyle(
                  color: MyTheme.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We will send you a verification code',
                style: TextStyle(
                  color: MyTheme.mutedForeground,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                enabled: !_isLoading,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: MyTheme.foreground),
                decoration: InputDecoration(
                  hintText: '+1234567890',
                  hintStyle: TextStyle(color: MyTheme.mutedForeground),
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: MyTheme.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: MyTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: MyTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: MyTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyPhone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Verification Code'),
              ),
            ] else ...[
              Text(
                'Enter verification code',
                style: TextStyle(
                  color: MyTheme.foreground,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We sent a code to ${_phoneController.text}',
                style: TextStyle(
                  color: MyTheme.mutedForeground,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _smsController,
                enabled: !_isLoading,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: TextStyle(color: MyTheme.foreground),
                decoration: InputDecoration(
                  hintText: '123456',
                  counterText: '',  // Hide the counter
                  hintStyle: TextStyle(color: MyTheme.mutedForeground),
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: MyTheme.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: MyTheme.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: MyTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: MyTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifySmsCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyTheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify Code'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isLoading ? null : () {
                  setState(() => _codeSent = false);
                },
                child: const Text('Change phone number'),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 