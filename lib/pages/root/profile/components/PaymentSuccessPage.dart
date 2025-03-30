import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:tradingapp/providers/subscription_provider.dart';

class PaymentSuccessPage extends StatefulWidget {
  final Map<String, dynamic> transactionDetails;
  final String planName;
  const PaymentSuccessPage({
    required this.transactionDetails,
    required this.planName,
    super.key,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _opacityAnimation;
  

  @override
  void initState() {
    super.initState();

    //debugPrint("INIT DETAILS:------------------------------- ${widget.transactionDetails}");

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();


    Provider.of<SubscriptionProvider>(context, listen: false).checkSubscriptionStatus(forceRefresh: true);
    
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildFeatureItem(String text, IconData icon) {
        //debugPrint("DETAILS:------------------------------- ${widget.transactionDetails}");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                      fontSize: 13,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }

 Widget _buildTransactionDetailRowTransactionId(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.7),
                      fontSize: 13,
                ),
          ),
          Text(
            value.toString().split('_').last,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }


  String _formatAmount(int amount, String currency) {
    final int amountInCents = amount;
    final double amountInCurrency = amountInCents / 100; // Convert from cents to dollars
    return '${amountInCurrency.toStringAsFixed(2)} ${currency.toUpperCase()}';
  }

  String _formatDate(dynamic timestamp) {
    try {
      // Convert string to int if needed
      final int timestampInt = timestamp is String ? int.parse(timestamp) : timestamp;
      final DateTime date = DateTime.fromMillisecondsSinceEpoch(timestampInt);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    } catch (e) {
      //debugPrint("Error formatting date: $e");
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final details = widget.transactionDetails;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      // Animated success icon
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Transform.rotate(
                              angle: _rotateAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                      // Success text
                      FadeTransition(
                        opacity: _opacityAnimation,
                        child: Column(
                          children: [
                            Text(
                              'Payment Successful!',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Thank you for subscribing to ${widget.planName}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.7),
                                  ),
                            ),
                            const SizedBox(height: 40),
                            // Payment details card
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
                                  _buildTransactionDetailRow(
                                    'Amount Paid',
                                    _formatAmount(details['amount'], details['currency']),
                                  ),
                                  const Divider(height: 32),
                                  _buildTransactionDetailRowTransactionId(
                                    'Transaction ID',
                                    '#${details['paymentIntentId']}',
                                  ),
                                  const Divider(height: 32),
                                  _buildTransactionDetailRow(
                                    'Payment Method',
                                    'Card'
                                    // '•••• ${details['paymentMethodId']?.substring(details['paymentMethodId'].length - 4) ?? 'N/A'}',
                                  ),
                                  const Divider(height: 32),
                                  _buildTransactionDetailRow(
                                    'Date & Time',
                                    _formatDate(details['created']),
                                  ),
                                  const Divider(height: 32),
                                  _buildTransactionDetailRow(
                                    'Status',
                                    details['status']?.toString().toUpperCase() ?? 'N/A',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // What's next section
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "What's next?",
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                  const SizedBox(height: 16),
                                  // _buildFeatureItem(
                                  //   'Access premium trading signals',
                                  //   Icons.trending_up,
                                  // ),
                                  // _buildFeatureItem(
                                  //   'Explore market analysis',
                                  //   Icons.analytics,
                                  // ),
                                  // _buildFeatureItem(
                                  //   'Set up notifications',
                                  //   Icons.notifications_active,
                                  // ),
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
            ),
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to home and clear stack
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Trading',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 