import 'package:flutter/material.dart';
import 'package:tradingapp/pages/payment/services/StripeService.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:tradingapp/shared/client/ApiClient.dart';

class PaymentPage extends StatefulWidget {
  final int selectedPlan;

  const PaymentPage({super.key, required this.selectedPlan});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _stripeService = StripeService();
  bool _isLoading = false;
  String? _error;
  String? _priceId;
  Map<String, dynamic>? _planDetails;

  @override
  void initState() {
    super.initState();
    _initializeStripe();
    _fetchPlanDetails();
  }

  Future<void> _initializeStripe() async {
    await _stripeService.initialize();
  }

  Future<void> _fetchPlanDetails() async {
    try {
      final response = await ApiClient().get('/stripe/subscriptions');

      if (response.statusCode == 200) {
        final subscriptions = json.decode(response.body);
        // Find the subscription that matches the selected plan
        final subscription = subscriptions.firstWhere(
          (sub) => sub['items'][0]['product']['name'] == 
            (widget.selectedPlan == 0 ? "Pro Trader Subscription" : "Basic Subscription"),
          orElse: () => null,
        );

        if (subscription != null) {
          setState(() {
            _priceId = subscription['items'][0]['price']['id'];
            _planDetails = {
              'name': subscription['items'][0]['product']['name'],
              'price': subscription['items'][0]['price']['unit_amount'] / 100, // Convert from cents to dollars
              'currency': subscription['items'][0]['price']['currency'],
              'description': subscription['items'][0]['product']['description'],
              'features': subscription['items'][0]['product']['metadata']?['features']?.split(',') ?? [],
            };
          });
        } else {
          setState(() {
            _error = 'Subscription plan not found';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch subscription details';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
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
            if (_planDetails != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Plan: ${_planDetails!['name']}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Price: ${_planDetails!['currency']}${_planDetails!['price']}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (_planDetails!['description'] != null) ...[
                        const SizedBox(height: 8),
                        Text(_planDetails!['description']),
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
              )
            else
              const Center(child: CircularProgressIndicator()),
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
    if (_planDetails == null || _planDetails!['features'] == null) {
      return [];
    }

    return (_planDetails!['features'] as List<String>).map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            const Icon(Icons.check_circle, size: 20),
            const SizedBox(width: 8),
            Text(feature),
          ],
        ),
      );
    }).toList();
  }
}