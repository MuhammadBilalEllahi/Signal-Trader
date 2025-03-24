import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/providers/crypto_price_provider.dart';
import 'package:tradingapp/theme/theme.dart';

class PriceChart extends StatelessWidget {
  final String symbol;
  final String timeframe;

  const PriceChart({
    super.key,
    required this.symbol,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoPriceProvider>(
      builder: (context, provider, child) {
        final price = provider.getPriceForSymbol(symbol);
        if (price == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Calculate price range for Y axis
        final priceRange = price.high24h - price.low24h;
        final minY = price.low24h - (priceRange * 0.1);
        final maxY = price.high24h + (priceRange * 0.1);

        // Generate spots based on timeframe
        final spots = _generateSpots(price, timeframe);

        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: MyTheme.card,
            border: Border(
              bottom: BorderSide(
                color: MyTheme.border.withOpacity(0.1),
              ),
            ),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: priceRange / 5,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: MyTheme.border.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const style = TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      );
                      Widget text;
                      switch (value.toInt()) {
                        case 0:
                          text = const Text('1D', style: style);
                          break;
                        case 1:
                          text = const Text('1W', style: style);
                          break;
                        case 2:
                          text = const Text('1M', style: style);
                          break;
                        case 3:
                          text = const Text('3M', style: style);
                          break;
                        case 4:
                          text = const Text('1Y', style: style);
                          break;
                        default:
                          text = const Text('');
                          break;
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: text,
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: priceRange / 5,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          '\$${value.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: MyTheme.mutedForeground,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: MyTheme.border.withOpacity(0.1)),
              ),
              minX: 0,
              maxX: 4,
              minY: minY,
              maxY: maxY,
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: MyTheme.primary,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: MyTheme.primary.withOpacity(0.1),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        MyTheme.primary.withOpacity(0.2),
                        MyTheme.primary.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<FlSpot> _generateSpots(dynamic price, String timeframe) {
    // This is a simplified version. In a real app, you would fetch historical data
    // based on the timeframe from your API
    final basePrice = price.price;
    final volatility = price.high24h - price.low24h;
    
    return List.generate(5, (index) {
      final randomFactor = (index % 2 == 0 ? 1 : -1) * (volatility * 0.1);
      return FlSpot(
        index.toDouble(),
        basePrice + randomFactor,
      );
    });
  }
}

class CandlestickChart extends StatefulWidget {
  final String symbol;
  final String timeframe;
  final bool showIndicators;

  const CandlestickChart({
    super.key,
    required this.symbol,
    required this.timeframe,
    required this.showIndicators,
  });

  @override
  State<CandlestickChart> createState() => _CandlestickChartState();
}

class _CandlestickChartState extends State<CandlestickChart> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CryptoPriceProvider>(
      builder: (context, provider, child) {
        final price = provider.getPriceForSymbol(widget.symbol);
        if (price == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: Theme.of(context).dividerColor.withValues(alpha:0.1),
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    const style = TextStyle(
                      color: Color(0xff68737d),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                    Widget text;
                    switch (value.toInt()) {
                      case 0:
                        text = const Text('00:00', style: style);
                        break;
                      case 6:
                        text = const Text('06:00', style: style);
                        break;
                      case 12:
                        text = const Text('12:00', style: style);
                        break;
                      case 18:
                        text = const Text('18:00', style: style);
                        break;
                      case 24:
                        text = const Text('24:00', style: style);
                        break;
                      default:
                        text = const Text('');
                        break;
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: text,
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        '\$${value.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                  reservedSize: 42,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha:0.1),
              ),
            ),
            minX: 0,
            maxX: 24,
            minY: price.price * 0.95,
            maxY: price.price * 1.05,
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 50000),
                  const FlSpot(6, 51000),
                  const FlSpot(12, 49000),
                  const FlSpot(18, 52000),
                  const FlSpot(24, 51000),
                ],
                isCurved: true,
                color: Theme.of(context).colorScheme.primary,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: false,
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 