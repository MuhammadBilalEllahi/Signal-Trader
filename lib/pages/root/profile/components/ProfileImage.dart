// import 'package:flutter/material.dart';
// import 'package:hexcolor/hexcolor.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// class ProfileImage extends StatefulWidget {
//   const ProfileImage({super.key});

//   @override
//   State<ProfileImage> createState() => _ProfileImageState();
// }

// class _ProfileImageState extends State<ProfileImage> {
//   bool _showQR = false; // State variable to toggle between image and QR

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: HexColor("#af9f85"),
//       body: ListView(
//         children: [
//           const SizedBox(height: 25),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisSize: MainAxisSize.max,
//               children: [
//                 const Text(
//                   'My Profile',
//                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.w500),
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _showQR = !_showQR; // Toggle QR visibility
//                     });
//                   },
//                   child: QrImageView(
//                     dataModuleStyle: QrDataModuleStyle(
//                       color: Theme.of(context).textTheme.bodySmall!.color,
//                       dataModuleShape: QrDataModuleShape.circle,
//                     ),
//                     eyeStyle: QrEyeStyle(
//                       color: Theme.of(context).textTheme.bodySmall!.color,
//                       eyeShape: QrEyeShape.circle,
//                     ),
//                     data: 'https://google.com',
//                     version: QrVersions.auto,
//                     size: 60.0,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Align(
//             alignment: Alignment.center,
//             child: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 Positioned(
//                   left: 12,
//                   top: 12,
//                   child: Transform.rotate(
//                     angle: -0.04,
//                     child: Container(
//                       width: 250,
//                       height: 265,
//                       decoration: BoxDecoration(
//                         color: Colors.black,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: 25,
//                   top: 30,
//                   child: Transform.rotate(
//                     angle: -0.1,
//                     child: Container(
//                       width: 150,
//                       height: 265,
//                       decoration: BoxDecoration(
//                         color: Colors.black,
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (!_showQR) ...[
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _showQR = !_showQR; // Toggle QR visibility
//                       });
//                     },
//                     child: SizedBox(
//                       width: 250,
//                       height: 290,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Image.asset(
//                           "assets/images/user.png",
//                           width: 250,
//                           height: 290,
//                           fit: BoxFit.cover,
//                           errorBuilder: (a, b, c) => const SizedBox(),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ] else ...[
//                   Stack(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(16),
//                         child: Container(
//                           width: 250,
//                           height: 290,
//                           color: Colors.amber,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _showQR = !_showQR; // Toggle QR visibility
//                           });
//                         },
//                         child: SizedBox(
//                             width: 250,
//                             height: 290,
//                             child: Center(
//                               child: QrImageView(
//                                 data: 'https://google.com',
//                                 version: QrVersions.auto,
//                                 size: 200,
//                               ),
//                             )),
//                       )
//                     ],
//                   )
//                 ]
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
//             child: Column(

//     mainAxisSize: MainAxisSize.min,
//               // mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 Text(
//                   "Anna Shevchenko",
//                   style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
//                 ),

//       // const SizedBox(height: 4),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       "H97DPSZB",
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
//                     ),
//                     IconButton(
//                         onPressed: () {},
//                         icon: Icon(
//                           Icons.file_upload_outlined,
//                           size: 22,
//                           color: Colors.black,
//                         ))
//                   ],
//                 )
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({super.key});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  bool _showQR = false;

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
                            child: Image.asset(
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
                const Text(
                  "Anna Shevchenko",
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
                        color: Colors.black,
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
