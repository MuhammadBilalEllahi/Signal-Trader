import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/services/AuthService.dart';
import 'package:tradingapp/theme/theme.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _smsController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _resetPasswordWithEmail() async {
    if (_emailController.text.isEmpty) {
      _showErrorSnackBar('Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().sendPasswordResetEmail(_emailController.text);
      _showSuccessSnackBar('Password reset link sent to your email');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPhoneVerification() async {
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar('Please enter your phone number');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().sendPasswordResetPhone(_phoneController.text);
      setState(() => _codeSent = true);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCodeAndResetPassword() async {
    if (_smsController.text.isEmpty) {
      _showErrorSnackBar('Please enter the verification code');
      return;
    }

    if (_newPasswordController.text.isEmpty) {
      _showErrorSnackBar('Please enter a new password');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorSnackBar('Passwords do not match');
      return;
    }

    if (_newPasswordController.text.length < 8) {
      _showErrorSnackBar('Password must be at least 8 characters long');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthService>().verifyPhoneAndResetPassword(
        _verificationId!,
        _smsController.text,
        _newPasswordController.text,
      );
      _showSuccessSnackBar('Password reset successfully');
      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildEmailTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset Password via Email',
            style: TextStyle(
              color: MyTheme.foreground,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: MyTheme.foreground),
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: TextStyle(color: MyTheme.mutedForeground),
              prefixIcon: const Icon(Icons.email),
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
            onPressed: _isLoading ? null : _resetPasswordWithEmail,
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
                : const Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Reset Password via Phone',
            style: TextStyle(
              color: MyTheme.foreground,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (!_codeSent) ...[
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
              onPressed: _isLoading ? null : _sendPhoneVerification,
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
            TextField(
              controller: _smsController,
              enabled: !_isLoading,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(color: MyTheme.foreground),
              decoration: InputDecoration(
                hintText: 'Enter 6-digit code',
                counterText: '',
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
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              enabled: !_isLoading,
              obscureText: true,
              style: TextStyle(color: MyTheme.foreground),
              decoration: InputDecoration(
                hintText: 'New Password',
                hintStyle: TextStyle(color: MyTheme.mutedForeground),
                prefixIcon: const Icon(Icons.lock),
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
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              enabled: !_isLoading,
              obscureText: true,
              style: TextStyle(color: MyTheme.foreground),
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                hintStyle: TextStyle(color: MyTheme.mutedForeground),
                prefixIcon: const Icon(Icons.lock),
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
              onPressed: _isLoading ? null : _verifyCodeAndResetPassword,
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
                  : const Text('Reset Password'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : () {
                setState(() {
                  _codeSent = false;
                  _smsController.clear();
                  _newPasswordController.clear();
                  _confirmPasswordController.clear();
                });
              },
              child: const Text('Change phone number'),
            ),
          ],
        ],
      ),
    );
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
          'Reset Password',
          style: TextStyle(
            color: MyTheme.foreground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Email'),
            Tab(text: 'Phone'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(child: _buildEmailTab()),
          SingleChildScrollView(child: _buildPhoneTab()),
        ],
      ),
    );
  }
} 