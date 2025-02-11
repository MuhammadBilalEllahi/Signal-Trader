import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProfileImage extends StatefulWidget {
  const ProfileImage({super.key});

  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor("#af9f85"),
      body: ListView(
        children: [
          SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('My Profile',style: TextStyle(fontSize: 28,fontWeight: FontWeight.bold),),
              QrImageView(
                dataModuleStyle: QrDataModuleStyle(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                    dataModuleShape: QrDataModuleShape.circle
      
                ),
                eyeStyle: QrEyeStyle(
                    color: Theme.of(context).textTheme.bodySmall!.color,
                    eyeShape: QrEyeShape.circle
                ),
                data: 'https://google.com',
                version: QrVersions.auto,
                size: 70.0,
              )
            ],
          ),
          Image.asset("assets/images/onboarding.jpg", width: 200,height: 200,errorBuilder: (a,b,c)=>SizedBox(),)
        ],
      ),
    );
  }
}
