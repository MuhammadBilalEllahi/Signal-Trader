import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tradingapp/pages/auth/SignOrSignUp.dart';

import '../UI/GetStarted.dart';


class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  bool _isShow = true;
  final int _pageCount = 2;


  Widget _buildScreen(String imageUrl, String textLine){
    return Image.asset(imageUrl,fit: BoxFit.cover);
  }

  @override
  void initState() {
    _pageController.addListener(() {
      setState(() {
        _pageController.page!>=0.7?_isShow=false:_isShow=true;
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
        children: [
          PageView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _pageController,
            children: [
              GetStartedScreen(pageController: _pageController,),
              // _buildScreen("", "1"),
              // _buildScreen("", "2"),
              const SignInOrSign()
            ],
          ),


          //Control Buttons
          // Visibility(
          //   visible: _isShow,
          //   child: AnimatedOpacity(
          //     opacity: _isShow?1:0,
          //     duration: const Duration(milliseconds: 300),
          //     child: Container(
          //       padding: EdgeInsets.symmetric(horizontal: 25),
          //       alignment: const Alignment(0, 0.78),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         crossAxisAlignment: CrossAxisAlignment.center,
          //         children: [
          //           // GestureDetector(
          //           //     onTap: _isShow?(){_pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);}:null,
          //           //     child: Container(
          //           //       padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 50),
          //           //       decoration: BoxDecoration(
          //           //           borderRadius: BorderRadius.circular(15),
          //           //           color: HexColor("#13192B")
          //           //       ),
          //           //       child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 35),
          //           //     )
          //           // ),
          //           // GestureDetector(
          //           //     onTap: _isShow? (){_pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeIn);}:null,
          //           //     child: Container(
          //           //       padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 50),
          //           //       decoration: BoxDecoration(
          //           //           borderRadius: BorderRadius.circular(15),
          //           //           color: HexColor("#000000")
          //           //       ),
          //           //       child: Text("Get Started",style: TextStyle(color: HexColor("#f3f4f6")),),
          //           //     )),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),



          //Skip Button
          // Visibility(
          //   visible: _isShow,
          //   child: AnimatedOpacity(
          //     opacity: _isShow?1:0,
          //     duration: const Duration(milliseconds: 300),
          //     child: Container(
          //       alignment: const Alignment(0.9, -0.85),
          //       child: GestureDetector(onTap: _isShow?(){_pageController.jumpToPage(4);}:null,child: const Text("Skip", style: TextStyle(fontSize: 16),),),
          //     ),
          //   ),
          // ),

          //SmoothIndicator
          // Visibility(
          //   visible: _isShow,
          //   child: AnimatedOpacity(
          //     opacity: _isShow?1:0,
          //     duration: const Duration(milliseconds: 300),
          //     child: Container(
          //         alignment: const Alignment(0,-0.95),
          //         child: SmoothPageIndicator(
          //             effect: ExpandingDotsEffect(dotColor: HexColor("#919ebd"),activeDotColor: HexColor("#222A3d"), dotHeight: 7, dotWidth: 10),
          //             controller: _pageController,
          //             count: _pageCount,onDotClicked: _isShow?(e){_pageController.animateToPage(e, duration: const Duration(milliseconds: 500), curve: Curves.easeIn);}:null)),
          //   ),
          // ),

        ]);
  }
}
