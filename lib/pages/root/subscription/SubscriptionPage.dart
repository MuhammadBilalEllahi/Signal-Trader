import 'package:flutter/material.dart';
import 'package:tradingapp/pages/root/profile/components/SubscriptionInfo.dart';
import 'package:tradingapp/pages/root/profile/components/PaymentSuccessPage.dart';
import 'package:tradingapp/services/subscription_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<dynamic> _plans = [];
  bool _isLoading = true;
  String? _error;
  String? _subscribedPlanId;
  String? _subscribedProductId;
  bool _isAlreadySubscribed = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final response = await _subscriptionService.getStripePlans();
      setState(() {
        _plans = response['plans'] ?? [];
        _subscribedPlanId = response['subscribedPlanId'];
        _subscribedProductId = response['subscribedProductId'];
        _isAlreadySubscribed = response['message'] == 'alreadySubscribed';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading plans: $e')),
        );
      }
    }
  }

  Future<void> _handleSubscribe(Map<String, dynamic> plan) async {
    if (_subscriptionService.isPlanSubscribed(plan, _subscribedPlanId)) {
      return;
    }

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubscriptionInfo(
            planDetails: plan,
          ),
        ),
      );

      if (result == true) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentSuccessPage( 
                transactionDetails: result,
                planName: plan['product']['name'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing payment: $e')),
        );
      }
    }
  }

  List<String> _getFeatures(Map<String, dynamic> plan) {
    final productFeatures = plan['product']['marketing_features'] as List<dynamic>?;
    if (productFeatures != null && productFeatures.isNotEmpty) {
      return productFeatures.map((f) => f.toString()).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Plans'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlans,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadPlans,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : _plans.isEmpty
                    ? const Center(child: Text('No plans available'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          final product = plan['product'];
                          final isPopular = index == 1;
                          final isSubscribed = _subscriptionService.isPlanSubscribed(plan, _subscribedPlanId);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildPlanCard(
                              context,
                              title: product['name'],
                              price: (plan['unit_amount'] / 100).toStringAsFixed(2),
                              period: plan['recurring']?['interval'] == 'month' 
                                  ? 'per month' 
                                  : plan['recurring']?['interval'] == 'year'
                                      ? 'per year'
                                      : 'one-time',
                              features: _getFeatures(plan),
                              isPopular: isPopular,
                              isSubscribed: isSubscribed,
                              onSubscribe: () => _handleSubscribe(plan),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    String? period,
    required List<String> features,
    required bool isPopular,
    required bool isSubscribed,
    required VoidCallback onSubscribe,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPopular
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerTheme.color ?? Colors.transparent,
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Text(
                'Most Popular',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$$price',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (period != null) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          period,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 20),
                ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 20),
                if (isSubscribed)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Already Subscribed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onSubscribe,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isPopular
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        foregroundColor: isPopular
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.primary,
                        side: isPopular
                            ? null
                            : BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                      ),
                      child: const Text('Subscribe Now'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


