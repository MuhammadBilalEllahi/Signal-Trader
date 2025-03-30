import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tradingapp/pages/auth/services/UserService.dart';
import 'package:tradingapp/pages/root/profile/components/SubscriptionInfo.dart';
import 'package:tradingapp/pages/root/subscription/SubscriptionPage.dart';
import 'package:tradingapp/providers/subscription_provider.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({super.key});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  bool _showQR = false;

  @override
  void initState() {
    super.initState();
    // Check subscription status when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SubscriptionProvider>(context, listen: false).checkSubscriptionStatus();
    });
  }

  Widget _buildSubscriptionCard() {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final isSubscribed = subscriptionProvider.isSubscribed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.7),
            Theme.of(context).colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isSubscribed ? Icons.workspace_premium : Icons.star,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSubscribed ? 'Pro Plan' : 'Free Plan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    isSubscribed ? 'Active Subscription' : 'Upgrade to Pro',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (!isSubscribed)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SubscriptionPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Subscribe',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    //debugPrint("This is userService.user: ${userService.user}");
    final profileImage = userService.user?.photoURL;
    final name = userService.user?.displayName ?? "Crypto User";
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showQR = !_showQR;
                    });
                  },
                  child: QrImageView(
                    dataModuleStyle: QrDataModuleStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color,
                      dataModuleShape: QrDataModuleShape.circle,
                    ),
                    eyeStyle: QrEyeStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color,
                      eyeShape: QrEyeShape.circle,
                    ),
                    data: 'https://google.com',
                    version: QrVersions.auto,
                    size: 60.0,
                  ),
                ),
              ],
            ),
          ),
          _buildSubscriptionCard(),
          Align(
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 12,
                  top: 12,
                  child: Transform.rotate(
                    angle: -0.04,
                    child: Container(
                      width: 250,
                      height: 265,
                      decoration: BoxDecoration(
                        color: Theme.of(context).listTileTheme.tileColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 25,
                  top: 30,
                  child: Transform.rotate(
                    angle: -0.1,
                    child: Container(
                      width: 150,
                      height: 265,
                      decoration: BoxDecoration(
                        color: Theme.of(context).listTileTheme.tileColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 250,
                  height: 270,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.amber,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (widget, animation) => FadeTransition(
                    opacity: animation,
                    child: widget,
                  ),
                  child: _showQR
                      ? GestureDetector(
                          key: const ValueKey("QR"),
                          onTap: () {
                            setState(() {
                              _showQR = !_showQR;
                            });
                          },
                          child: Container(
                            width: 250,
                            height: 270,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.amber,
                            ),
                            child: Center(
                              child: QrImageView(
                                data: 'https://google.com',
                                version: QrVersions.auto,
                                size: 200,
                              ),
                            ),
                          ),
                        )
                      : GestureDetector(
                          key: const ValueKey("Image"),
                          onTap: () {
                            setState(() {
                              _showQR = !_showQR;
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child:
                            profileImage != null
                            ?
                             Image.network(
                              profileImage,
                              width: 250,
                              height: 270,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(),
                            )
                            :  Image.asset(
                               "assets/images/user.png",
                              width: 250,
                              height: 270,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                  name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "H97DPSZB",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.file_upload_outlined,
                        size: 22,
                        
                      ),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
