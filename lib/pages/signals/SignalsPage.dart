import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tradingapp/pages/signals/page/CurrentSignal.dart';
import 'package:tradingapp/pages/signals/page/FavouritesPage.dart';
import 'package:tradingapp/pages/signals/page/HistoryPage.dart';

class SignalsPage extends StatefulWidget {
  const SignalsPage({super.key});

  @override
  _SignalsPageState createState() => _SignalsPageState();
}

class _SignalsPageState extends State<SignalsPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Trading Signals",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTabButton("Current", 0),
                const SizedBox(width: 12),
                _buildTabButton("History", 1),
                const SizedBox(width: 12),
                _buildTabButton("Favourites", 2),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? CurrentSignalsPage()
                : _selectedTab == 1
                    ? HistoryPage()
                    : FavouritesPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _selectedTab == index;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedTab = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(isDarkMode ? 1 : 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).dividerTheme.color ?? Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? isDarkMode
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}





