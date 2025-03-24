import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tradingapp/providers/crypto_price_provider.dart';
import 'package:tradingapp/theme/theme.dart';
import 'package:tradingapp/pages/root/trading/components/MarketData.dart';
import 'package:tradingapp/pages/root/trading/components/PriceChart.dart';
import 'package:tradingapp/pages/root/trading/components/TechnicalIndicators.dart';

class TradingInterface extends StatefulWidget {
  final String symbol;

  const TradingInterface({
    super.key,
    required this.symbol,
  });

  @override
  State<TradingInterface> createState() => _TradingInterfaceState();
}

class _TradingInterfaceState extends State<TradingInterface> {
  String _selectedTimeframe = '1D';
  final List<String> _timeframes = ['1D', '1W', '1M', '3M', '1Y'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyTheme.background,
      appBar: AppBar(
        backgroundColor: MyTheme.card,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: MyTheme.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.currency_bitcoin,
                size: 20,
                  color: MyTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.symbol,
              style: TextStyle(
                color: MyTheme.foreground,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyTheme.foreground),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MarketData(symbol: widget.symbol),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: MyTheme.card,
                border: Border(
                  bottom: BorderSide(
                    color: MyTheme.border.withValues(alpha:0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _timeframes.map((timeframe) {
                  final isSelected = timeframe == _selectedTimeframe;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeframe = timeframe),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MyTheme.primary
                            : MyTheme.card,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected
                              ? MyTheme.primary
                                : MyTheme.border.withValues(alpha:0.1),
                        ),
                      ),
                      child: Text(
                        timeframe,
                        style: TextStyle(
                          color: isSelected
                              ? MyTheme.background
                              : MyTheme.foreground,
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            PriceChart(
              symbol: widget.symbol,
              timeframe: _selectedTimeframe,
            ),
            TechnicalIndicators(
              symbol: widget.symbol,
            ),
          ],
        ),
      ),
    );
  }
} 