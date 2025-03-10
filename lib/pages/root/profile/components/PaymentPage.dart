import 'package:flutter/material.dart';
import 'package:tradingapp/pages/root/profile/components/CreditCardPage.dart';

class PaymentPage extends StatefulWidget {
  final int selectedPlan;
  const PaymentPage({super.key, this.selectedPlan = 0});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late int _selectedPlan;
  final bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedPlan = widget.selectedPlan;
  }

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Monthly',
      'price': '\$49.99',
      'period': 'month',
      'features': [
        'All trading signals',
        'Real-time alerts',
        'Market analysis',
        'Priority support',
      ],
    },
    {
      'name': 'Quarterly',
      'price': '\$129.99',
      'period': '3 months',
      'features': [
        'All trading signals',
        'Real-time alerts',
        'Market analysis',
        'Priority support',
        'Save 13%',
      ],
    },
    {
      'name': 'Yearly',
      'price': '\$449.99',
      'period': 'year',
      'features': [
        'All trading signals',
        'Real-time alerts',
        'Market analysis',
        'Priority support',
        'Save 25%',
        'Exclusive webinars',
      ],
    },
  ];

  Widget _buildPlanCard(int index) {
    final plan = _plans[index];
    final isSelected = _selectedPlan == index;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedPlan = index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan['name'],
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  Radio(
                    value: index,
                    groupValue: _selectedPlan,
                    onChanged: (value) => setState(() => _selectedPlan = value!),
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    plan['price'],
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '/${plan['period']}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              ...plan['features'].map<Widget>((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          feature,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _plans[_selectedPlan]['price'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreditCardPage(
                                  amount: _plans[_selectedPlan]['price'],
                                  planName: _plans[_selectedPlan]['name'],
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.155),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Choose Plan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              Text(
                'Select your plan',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose the plan that best suits your needs',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 24),
              ...List.generate(
                _plans.length,
                (index) => _buildPlanCard(index),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildPaymentSection(),
          ),
        ],
      ),
    );
  }
}