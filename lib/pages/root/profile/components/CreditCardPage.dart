import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tradingapp/pages/root/profile/components/PaymentSuccessPage.dart';

class CreditCardPage extends StatefulWidget {
  final String amount;
  final String planName;

  const CreditCardPage({
    required this.amount,
    required this.planName,
    super.key,
  });

  @override
  State<CreditCardPage> createState() => _CreditCardPageState();
}

class _CreditCardPageState extends State<CreditCardPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  String _cardNumber = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardHolderName = '';
  bool _saveCard = false;

  Widget _buildCardPreview() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 24,
            top: 24,
            child: Icon(
              Icons.credit_card,
              size: 32,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cardNumber.isEmpty ? '**** **** **** ****' : _formatCardNumber(_cardNumber),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expiry Date',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _expiryDate.isEmpty ? 'MM/YY' : _expiryDate,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CVV',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _cvv.isEmpty ? '***' : '•' * _cvv.length,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  _cardHolderName.isEmpty ? 'CARD HOLDER NAME' : _cardHolderName.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCardNumber(String number) {
    if (number.isEmpty) return '';
    final cleaned = number.replaceAll(RegExp(r'\D'), '');
    final parts = cleaned.split('');
    final formatted = [];
    for (var i = 0; i < parts.length; i++) {
      if (i % 4 == 0 && i > 0) formatted.add(' ');
      formatted.add(parts[i]);
    }
    return formatted.join('');
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required void Function(String) onChanged,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          onChanged: onChanged,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Payment Details'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardPreview(),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInputField(
                      label: 'Card Number',
                      hint: '1234 5678 9012 3456',
                      onChanged: (value) => setState(() => _cardNumber = value),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                      ],
                      validator: (value) {
                        if (value == null || value.length != 16) {
                          return 'Please enter a valid card number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInputField(
                            label: 'Expiry Date',
                            hint: 'MM/YY',
                            onChanged: (value) => setState(() => _expiryDate = value),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryDateInputFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.length != 5) {
                                return 'Invalid date';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInputField(
                            label: 'CVV',
                            hint: '123',
                            onChanged: (value) => setState(() => _cvv = value),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            validator: (value) {
                              if (value == null || value.length != 3) {
                                return 'Invalid CVV';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label: 'Card Holder Name',
                      hint: 'John Doe',
                      onChanged: (value) => setState(() => _cardHolderName = value),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card holder name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Switch(
                          value: _saveCard,
                          onChanged: (value) => setState(() => _saveCard = value),
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Save card for future payments',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.planName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                widget.amount,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isProcessing
                                  ? null
                                  : () async {
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => _isProcessing = true);
                                        // Add payment processing logic here
                                        await Future.delayed(const Duration(seconds: 2));
                                        if (mounted) {
                                          // Navigator.pushReplacement(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) => PaymentSuccessPage(
                                          //       planName: widget.planName,
                                          //       amount: widget.amount,
                                          //     ),
                                          //   ),
                                          // );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isProcessing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Pay ${widget.amount}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    var newText = '';

    if (text.length >= 2) {
      newText = '${text.substring(0, 2)}/${text.substring(2)}';
    } else {
      newText = text;
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
} 