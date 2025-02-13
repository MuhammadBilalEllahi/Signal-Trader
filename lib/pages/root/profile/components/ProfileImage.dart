import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({super.key});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  bool _showQR = false; // State variable to toggle between image and QR

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#af9f85"),
      body: ListView(
        children: [
          const SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showQR = !_showQR; // Toggle QR visibility
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
                        color: Colors.black,
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
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                if (!_showQR) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showQR = !_showQR; // Toggle QR visibility
                      });
                    },
                    child: SizedBox(
                      width: 250,
                      height: 290,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/images/user.png",
                          width: 250,
                          height: 290,
                          fit: BoxFit.cover,
                          errorBuilder: (a, b, c) => const SizedBox(),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 250,
                          height: 290,
                          color: Colors.amber,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showQR = !_showQR; // Toggle QR visibility
                          });
                        },
                        child: SizedBox(
                            width: 250,
                            height: 290,
                            child: Center(
                              child: QrImageView(
                                data: 'https://google.com',
                                version: QrVersions.auto,
                                size: 200,
                              ),
                            )),
                      )
                    ],
                  )
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
