import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradingapp/pages/root/profile/Profile.dart';
import 'package:tradingapp/pages/root/profile/components/ProfileImage.dart';

import '../services/AuthService.dart';
import 'home/Home.dart';



class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int selectedPage = 0;
  final PageController _pageController = PageController();



  _navigateToPage(int index){
    if(index==3){
      showModalBottomSheet(
          enableDrag: false,
          clipBehavior: Clip.hardEdge,
          isScrollControlled: false,
          constraints: const BoxConstraints(maxHeight: 200),
          context: context,
          barrierColor: Colors.transparent,
          builder: (builder){

            return const Profile();
          });
    }
      _pageController.jumpToPage(index);
      setState(() {
        selectedPage=index;
      });

  }
  _onPageChanged(int index){
    setState(() {
      selectedPage=index;
    });
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: MediaQuery(
        data: const MediaQueryData(viewPadding: EdgeInsets.only(bottom: kIsWeb?20:0)),
        child: BottomNavigationBar(
            currentIndex: selectedPage,
            onTap: (int index){
              _navigateToPage(index);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined),label: "Home",activeIcon: Icon(Icons.home)),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_text),label: "Chat",activeIcon:Icon(CupertinoIcons.chat_bubble_text_fill)),
              BottomNavigationBarItem(icon: Icon(CupertinoIcons.smiley),label: "Trends",activeIcon: Icon(CupertinoIcons.smiley_fill)),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline_sharp),label: "Profile",activeIcon: Icon(Icons.person))
            ]),
      ),
      body: PageView(
        // allowImplicitScrolling: false,
        scrollDirection: Axis.horizontal,
        // physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children:  const [
          Home(),
          SizedBox(),
          SizedBox(),
          ProfileImage()
        ],
        onPageChanged: (pageIndex){
          _onPageChanged(pageIndex);
        },
      ),
    );
  }
}
