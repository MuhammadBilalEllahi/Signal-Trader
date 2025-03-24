import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/providers/crypto_price_provider.dart';
import 'package:tradingapp/theme/theme.dart';

class MarketData extends StatelessWidget {
  final String symbol;

  const MarketData({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoPriceProvider>(
      builder: (context, provider, child) {
        final price = provider.getPriceForSymbol(symbol);
        if (price == null) {
          return const SizedBox.shrink();
        }

        final isPositive = price.priceChangePercent >= 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyTheme.card,
            border: Border(
              bottom: BorderSide(
                color: MyTheme.border.withOpacity(0.1),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Price and 24h Change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: TextStyle(
                          fontSize: 14,
                          color: MyTheme.mutedForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${price.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: MyTheme.foreground,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${price.priceChangePercent.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPositive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Market Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatItem(
                    '24h High',
                    '\$${price.high24h.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                  _buildStatItem(
                    '24h Low',
                    '\$${price.low24h.toStringAsFixed(2)}',
                    Colors.red,
                  ),
                  _buildStatItem(
                    '24h Volume',
                    '\$${price.volume24h.toStringAsFixed(2)}',
                    MyTheme.primary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: MyTheme.mutedForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
} 