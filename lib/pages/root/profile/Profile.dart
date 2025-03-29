import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/auth/services/UserService.dart';
import 'package:tradingapp/pages/newsAlerts/providers/news_alerts_provider.dart';
import 'package:tradingapp/pages/root/home/providers/crypto_price_provider.dart';
import 'package:tradingapp/pages/root/subscription/SubscriptionPage.dart';
import 'package:tradingapp/pages/signals/providers/signals_provider.dart';
import 'package:tradingapp/providers/subscription_provider.dart';
import 'package:tradingapp/shared/constants/app_constants.dart';
import 'package:tradingapp/pages/root/profile/providers/profile_provider.dart';
import 'package:tradingapp/pages/signals/subscription/SubscriptionPlans.dart';
import 'package:tradingapp/pages/root/profile/components/BiometricSetupScreen.dart';
import '../../auth/services/AuthService.dart';
import 'package:tradingapp/pages/auth/TwoFactorSetupScreen.dart';
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  Future<void> _initializeProfile() async {
    final provider = Provider.of<ProfileProvider>(context, listen: false);
    await provider.initializeProfile();
  }

  _signOut() {
    // Clear all provider data
    Provider.of<AuthService>(context, listen: false).signOut();
    Provider.of<UserService>(context, listen: false).clearUser();
    Provider.of<SubscriptionProvider>(context, listen: false).clearSubscription();
    Provider.of<ProfileProvider>(context, listen: false).clearProfile();
    Provider.of<CryptoPriceProvider>(context, listen: false).clearCryptoPrice();
    Provider.of<SignalsProvider>(context, listen: false).clearSignals();
    Provider.of<NewsAlertsProvider>(context, listen: false).clearNewsAlerts();

    // Navigate to auth gate and clear all routes
    Navigator.pushNamedAndRemoveUntil(
      context, 
      AppRoutes.authGate, 
      (route) => false
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserService, ProfileProvider>(
      builder: (context, userService, profileProvider, child) {
        final email = userService.user?.email ?? '';
        final phone = userService.user?.phoneNumber ?? '';
        final fingerprint = userService.user?.uid ?? '';

        return RefreshIndicator(
          onRefresh: () => profileProvider.fetchProfileData(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                if (profileProvider.isLoading)
                  const LinearProgressIndicator(),
                if (phone.isNotEmpty)
                  ProfileListTile(
                    title: 'Phone Number',
                    icon: Icons.phone,
                    subtitleIcon: Icons.local_phone,
                    value: phone,
                  ),
                ProfileListTile(
                  title: 'Email Address',
                  icon: Icons.email,
                  subtitleIcon: Icons.alternate_email,
                  value: email,
                ),
                ProfileListTile(
                  title: 'Key Fingerprint',
                  icon: Icons.fingerprint,
                  subtitleIcon: Icons.verified,
                  value: fingerprint,
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionPage(),
                      ),
                    );
                  },
                  leading: Icon(
                    Icons.workspace_premium,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    "Subscription Plans",
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Upgrade your trading experience",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BiometricSetupScreen(),
                      ),
                    );
                  },
                  leading: Icon(
                    Icons.fingerprint,
                    size: 36,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    "Biometric Lock",
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Set up fingerprint or face ID lock",
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),

                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TwoFactorSetupScreen(),
                      ),
                    );
                  },
                  leading: Icon(
                    Icons.security,
                    size: 36, 
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    "Two-Factor Authentication",
                    style: TextStyle(
                      fontSize: 15, 
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    "Add an extra layer of security", 
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  trailing: Icon( 
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () => _signOut(),
                  leading: Icon(
                    Icons.logout_outlined,
                    size: 36,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  title: Text(
                    "Sign out",
                    style: TextStyle(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w500,
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
}

class ProfileListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData subtitleIcon;
  final String value;

  const ProfileListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.subtitleIcon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        size: 36,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            subtitleIcon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
