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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Trading Signals"),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTabButton("Current", 0),
              _buildTabButton("History", 1),
              _buildTabButton("Favourites", 2),
            ],
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
    return ElevatedButton(
      onPressed: () => setState(() => _selectedTab = index),
      style: ElevatedButton.styleFrom(
        backgroundColor: _selectedTab == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        foregroundColor: _selectedTab == index
            ? Theme.of(context).colorScheme.onPrimary
            : Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: _selectedTab == index
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerTheme.color ?? Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: Text(title),
    );
  }
}





