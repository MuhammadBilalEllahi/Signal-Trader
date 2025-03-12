import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/root/home/components/CryptoPriceList.dart';
import 'package:tradingapp/pages/root/home/components/HomeButtons.dart';
import 'package:tradingapp/pages/services/constants/constants.dart';
import 'package:tradingapp/providers/crypto_price_provider.dart';
import 'package:tradingapp/theme/theme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  void _retryLoad() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    // Simulate loading
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Widget _buildContent() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            leading: Icon(
              Icons.verified,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              "Apply for verification",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: OutlinedButton(
              onPressed: () {},
              child: const Text("Apply"),
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Text(
        //   "Quick Actions",
        //   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        //     fontWeight: FontWeight.w600,
        //   ),
        // ),
        // const SizedBox(height: 16),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     Homebuttons(
        //       onTap: () {},
        //       icon: Icons.money_sharp,
        //       isActive: true,
        //       text: "Payments",
        //     ),
        //     Homebuttons(
        //       onTap: () {},
        //       icon: Icons.arrow_forward,
        //       text: "Send",
        //     ),
        //     Homebuttons(
        //       onTap: () {},
        //       icon: Icons.people,
        //       text: "Peers",
        //     ),
        //     Homebuttons(
        //       onTap: () {},
        //       icon: Icons.more_horiz_outlined,
        //       text: "More",
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 24),
        const CryptoPriceList(),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage.isNotEmpty
                ? _errorMessage
                : 'Something went wrong. Please try again.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _retryLoad,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Badge(
              child: Icon(
                Icons.notifications_none_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
      body: _hasError
          ? _buildErrorWidget()
          : _isLoading
              ? _buildLoadingWidget()
              : _buildContent(),
    );
  }
}
