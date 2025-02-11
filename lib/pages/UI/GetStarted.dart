import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tradingapp/pages/services/constants/constants.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
            child: Image.asset(AppAssets.splashImage, fit: BoxFit.cover)),
        Padding(padding:EdgeInsets.fromLTRB(40, 0, 30, 60) ,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: EdgeInsets.only(top: 10, bottom: 10), child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppConstants.splashVal.secure ,
                  style: TextStyle(fontSize: 45, color: Colors.black, fontWeight: FontWeight.w700),
                ),
                Text(
                  AppConstants.splashVal.anonymous,
                  style: TextStyle(fontSize: 45, color: Colors.black, fontWeight: FontWeight.w700),
                ),
                Text(
                  AppConstants.splashVal.private,
                  style: TextStyle(fontSize: 45, color: Colors.black, fontWeight: FontWeight.w700),
                ),
              ],
            ),),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => {},
                  
                  style: ElevatedButton.styleFrom(
                    
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5))),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    AppConstants.getStarted,
                    style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w300),
                  ),
                  
                ),

                Padding(padding: EdgeInsets.only(left: 30) ,
                child: RichText(
  text: TextSpan(
    text: AppConstants.alreadyHaveAnAcount,
    style: const TextStyle(fontSize: 18, color: Colors.black54),
    children: [
      TextSpan(
        recognizer: TapGestureRecognizer()..onTap=(){
          Navigator.pushNamed(context, AppRoutes.signIn);
        },
        text: AppConstants.login,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black, // Makes it look like a link
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline, // Underline effect
        ),
      ),
    ],
  ),
),
)
             

             
              ],
            )
          ],
        )
      ,)],
    ));
  }
}
