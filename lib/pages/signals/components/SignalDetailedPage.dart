import 'package:flutter/material.dart';

class SignalDetailedPage extends StatelessWidget {
  final Map<String, dynamic> signal;

  const SignalDetailedPage({required this.signal, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(signal["coin"]),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with type badge and direction
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        signal["coin"],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildTypeBadge(signal["type"]),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: signal['direction'].toString().toLowerCase() == 'long'
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      signal['direction'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price Information Card
              _buildInfoCard(
                title: "Trade Information",
                content: Column(
                  children: [
                    _buildInfoRow(
                      "Entry Price",
                      "\$${signal["entryPrice"]}",
                      Icons.call_made,
                      Colors.green,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      "Exit Price",
                      "\$${signal["exitPrice"]}",
                      Icons.call_received,
                      Colors.red,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      "Portfolio %",
                      "${signal["portfolioPercentage"]}%",
                      Icons.account_balance_wallet,
                      Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      "Created At",
                      signal["createdFormatted"],
                      Icons.access_time,
                      Colors.grey,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Analysis Section
              _buildInfoCard(
                title: "Analysis",
                content: Text(
                  signal["analysis"] ?? "No analysis available for this signal.",
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
             ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    Color startColor;
    Color endColor;
    String text;
    Color textColor;

    switch (type.toLowerCase()) {
      case 'crypto':
        startColor = Colors.grey.shade700;
        endColor = Colors.grey.shade500;
        text = "CRYPTO";
        textColor = Colors.white;
        break;
      case 'stocks':
        startColor = Colors.black87;
        endColor = Colors.black12;
        text = "STOCKS";
        textColor = Colors.white;
        break;
      default:
        startColor = Colors.yellow.shade700;
        endColor = Colors.yellow.shade100;
        text = "GOLD";
        textColor = Colors.black87;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey[900]!,
            Colors.grey[850]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[800]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.amber[400],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}