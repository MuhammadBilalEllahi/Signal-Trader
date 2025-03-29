import 'package:flutter/material.dart';
import 'package:tradingapp/pages/payment/services/StripeService.dart';
import 'package:tradingapp/pages/root/profile/components/PaymentSuccessPage.dart';

class SubscriptionInfo extends StatefulWidget {
  final Map<String, dynamic> planDetails;

  const SubscriptionInfo({super.key, required this.planDetails});

  @override
  State<SubscriptionInfo> createState() => _SubscriptionInfoState();
}

class _SubscriptionInfoState extends State<SubscriptionInfo> {
  final _stripeService = StripeService();
  bool _isLoading = false;
  String? _error;
  String? _priceId;
  String? _productId;

  @override
  void initState() {
    super.initState();
    _initializeStripe();
    _productId = widget.planDetails['product']['id'];
    _priceId = widget.planDetails['id'];
    debugPrint("DATA from subscription page: ${widget.planDetails}");
  }

  Future<void> _initializeStripe() async {
    try {
      await _stripeService.initialize();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to initialize payment system: $e';
        });
      }
    }
  }

  Future<void> _handlePayment() async {
    if (_priceId == null) {
      setState(() {
        _error = 'Subscription details not loaded';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _stripeService.createSubscription(_priceId!, _productId!);

      if (result['success']) {
        if (mounted) {
          // Navigate to success page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessPage(
                planName: widget.planDetails['product']['name'],
                amount: '\$${(widget.planDetails['unit_amount'] / 100).toStringAsFixed(2)}',
              ),
            ),
          );
        }
      } else {
        setState(() {
          _error = result['error'] ?? 'Payment failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unitAmount = widget.planDetails['unit_amount'] ?? 0;
    final price = (unitAmount / 100).toStringAsFixed(2);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Plan: ${widget.planDetails['product']?['name'] ?? 'Unknown Plan'}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: ${widget.planDetails['currency'] ?? 'USD'}$price',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (widget.planDetails['product']?['description'] != null) ...[
                      const SizedBox(height: 8),
                      Text(widget.planDetails['product']['description']),
                    ],
                    const SizedBox(height: 16),
                    const Text(
                      'Features included:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ..._buildFeatures(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePayment,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatures() {
    final marketingFeatures = widget.planDetails['product']?['metadata']?['marketingFeatures']?.toString();
    
    if (marketingFeatures == null || marketingFeatures.isEmpty) {
      return [];
    }

    final listOfMarketingFeatures = marketingFeatures.split(',');
    
    return listOfMarketingFeatures.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 20),
            const SizedBox(width: 8),
            Text(feature.trim()),
          ],
        ),
      );
    }).toList();
  }
}