import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tradingapp/pages/auth/services/AuthService.dart';
import 'package:tradingapp/theme/theme.dart';
import 'package:flutter/services.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  bool _verifying = false;
  String? _secret;
  String? _qrUrl;
  String? _error;
  bool _alreadyEnabled = false;

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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await context.read<AuthService>().enable2FA();
      //debugPrint('response from enable2FA--------- $response');
      setState(() {
        _secret = response['secret'];
        _qrUrl = response['otpauth_url'];
        _alreadyEnabled = response['alreadyEnabled'] ?? false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _verify2FA() async {
    if (_codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _verifying = true;
      _error = null;
    });

    try {
      final verified = await context.read<AuthService>().verify2FAInitialize(_codeController.text);
      if (verified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('2FA enabled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _error = 'Invalid code. Please try again.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _verifying = false);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: Colors.green,
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
          'Two-Factor Authentication',
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
                  ListTile(
                    title: Text(
                      _alreadyEnabled ? 'Disable 2FA' : 'Enable 2FA',
                      style: TextStyle(
                        color: MyTheme.foreground,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Switch(
                      value: _alreadyEnabled,
                      onChanged: (value) {
                        if (value) {
                          _setup2FA();
                        } else {
                          // Handle disabling 2FA here
                        }
                      },
                    ),
                  ),
                  if (!_alreadyEnabled) ...[
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
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
                      GestureDetector(
                        onTap: () => _copyToClipboard(_secret!),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MyTheme.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: MyTheme.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: SelectableText(
                                  _secret!,
                                  style: TextStyle(
                                    color: MyTheme.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () => _copyToClipboard(_secret!),
                              ),
                            ],
                          ),
                        ),
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
                      maxLength: 6,
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
                      onPressed: _verifying ? null : _verify2FA,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyTheme.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _verifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Verify and Enable 2FA'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}