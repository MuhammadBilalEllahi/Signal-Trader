import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tradingapp/pages/services/AuthService.dart';
import 'package:tradingapp/theme/theme.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _secret;
  String? _qrUrl;

  @override
  void initState() {
    super.initState();
    _setup2FA();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _setup2FA() async {
    setState(() => _loading = true);

    try {
      final response = await context.read<AuthService>().enable2FA();
      setState(() {
        _secret = response['secret'];
        _qrUrl = response['otpauth_url'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verify2FA() async {
    if (_codeController.text.isEmpty) return;

    setState(() => _loading = true);

    try {
      final verified = await context.read<AuthService>().verify2FA(_codeController.text);
      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('2FA enabled successfully')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
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
          'Set Up Two-Factor Authentication',
          style: TextStyle(
            color: MyTheme.foreground,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Scan this QR code with your authenticator app',
                    style: TextStyle(
                      color: MyTheme.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_qrUrl != null)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QrImageView(
                          data: _qrUrl!,
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  if (_secret != null) ...[
                    Text(
                      'Or enter this code manually:',
                      style: TextStyle(
                        color: MyTheme.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _secret!,
                      style: TextStyle(
                        color: MyTheme.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    'Enter the code from your authenticator app',
                    style: TextStyle(
                      color: MyTheme.foreground,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: MyTheme.foreground),
                    decoration: InputDecoration(
                      hintText: '123456',
                      hintStyle: TextStyle(color: MyTheme.mutedForeground),
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
                    onPressed: _verify2FA,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Verify and Enable 2FA'),
                  ),
                ],
              ),
            ),
    );
  }
} 