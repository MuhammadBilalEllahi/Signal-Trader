import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:tradingapp/pages/services/UserService.dart';
import 'package:tradingapp/pages/root/profile/components/PaymentPage.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({super.key});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  bool _showQR = false;

  Widget _buildSubscriptionCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Free Plan',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Upgrade to Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Get access to premium features and exclusive trading signals',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PaymentPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Subscribe Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final profileImage = userService.user?.photoURL;
    final name = userService.user?.displayName ?? "Anna Shevchenko";
    
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
                  height: 290,
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
                            height: 290,
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
                              height: 290,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(),
                            )
                            :  Image.asset(
                               "assets/images/user.png",
                              width: 250,
                              height: 290,
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
            padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
