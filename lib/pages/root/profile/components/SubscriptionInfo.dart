import 'package:flutter/material.dart';
import 'package:tradingapp/pages/payment/services/StripeService.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeStripe();
    _priceId = widget.planDetails['product']['id'];
    debugPrint("DATA from subscription page: ${widget.planDetails}");
  }

  Future<void> _initializeStripe() async {
    await _stripeService.initialize();
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
      final result = await _stripeService.createSubscription(_priceId!);

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment successful!')),
          );
          Navigator.pop(context);
        }
      } else {
        setState(() {
          _error = result['error'];
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
                      'Selected Plan: ${widget.planDetails['product']['name']}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Price: ${widget.planDetails['currency']}${(widget.planDetails['unit_amount'] ?? 0 / 100).toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (widget.planDetails['product']['description'] != null) ...[
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
              onPressed: _isLoading || _priceId == null ? null : _handlePayment,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatures() {
    debugPrint("FEATURES: ${widget.planDetails['product']?['metadata']?['marketingFeatures']}");
    final marketingFeatures = widget.planDetails['product']?['metadata']?['marketingFeatures']?.toString();
    
    if (marketingFeatures == null || marketingFeatures.isEmpty) {
      return [];
    }

    final listOfMarketingFeatures = marketingFeatures.split(',');
    debugPrint("LIST OF MARKETING FEATURES: $listOfMarketingFeatures");
    
    return listOfMarketingFeatures.map((feature) {
      debugPrint("FEATURE--: $feature");
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
    }).toList(); // Convert the Iterable to List<Widget>
  }
}