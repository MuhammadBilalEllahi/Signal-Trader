import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/providers/crypto_price_provider.dart';
import 'package:tradingapp/theme/theme.dart';

class TechnicalIndicators extends StatelessWidget {
  final String symbol;

  const TechnicalIndicators({
    super.key,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoPriceProvider>(
      builder: (context, provider, child) {
        final price = provider.getPriceForSymbol(symbol);
        if (price == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Calculate technical indicators based on price data
        final indicators = _calculateIndicators(price);

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
              Row(
                children: [
                  Icon(
                    Icons.analytics,
                    size: 18,
                    color: MyTheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Technical Indicators',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: MyTheme.foreground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildIndicatorCard('RSI', indicators['rsi'] ?? 0, Colors.orange),
                  _buildIndicatorCard('MACD', indicators['macd'] ?? 0, Colors.blue),
                  _buildIndicatorCard('BB Upper', indicators['bbUpper'] ?? 0, Colors.purple),
                  _buildIndicatorCard('BB Lower', indicators['bbLower'] ?? 0, Colors.purple),
                  _buildIndicatorCard('MA 20', indicators['ma20'] ?? 0, Colors.green),
                  _buildIndicatorCard('MA 50', indicators['ma50'] ?? 0, Colors.red),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, double> _calculateIndicators(dynamic price) {
    // This is a simplified version. In a real app, you would calculate these
    // indicators based on historical data from your API
    final currentPrice = (price.price as num).toDouble();
    final high24h = (price.high24h as num).toDouble();
    final low24h = (price.low24h as num).toDouble();
    final volume24h = (price.volume24h as num).toDouble();
    final priceChangePercent = (price.priceChangePercent as num).toDouble();

    // Calculate RSI (simplified)
    final rsi = (50.0 + (priceChangePercent * 2.0)).toDouble();

    // Calculate MACD (simplified)
    final macd = (priceChangePercent * 0.01).toDouble();

    // Calculate Bollinger Bands (simplified)
    final bbUpper = (currentPrice * 1.02).toDouble();
    final bbLower = (currentPrice * 0.98).toDouble();

    // Calculate Moving Averages (simplified)
    final ma20 = (currentPrice * 1.01).toDouble();
    final ma50 = (currentPrice * 0.99).toDouble();

    return {
      'rsi': rsi,
      'macd': macd,
      'bbUpper': bbUpper,
      'bbLower': bbLower,
      'ma20': ma20,
      'ma50': ma50,
    };
  }

  Widget _buildIndicatorCard(String name, double value, Color color) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: MyTheme.card,
        border: Border.all(
          color: MyTheme.border.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  color: MyTheme.mutedForeground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 16,
              color: MyTheme.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
} 