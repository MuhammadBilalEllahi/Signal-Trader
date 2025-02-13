import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tradingapp/pages/root/profile/Profile.dart';
import 'package:tradingapp/pages/root/profile/components/ProfileImage.dart';

import 'home/Home.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int selectedPage = 0;
  bool isModalVisible = true;
  final PageController _pageController = PageController();

  _navigateToPage(int index) {
    if (index == 0) {
      _pageController.jumpToPage(index);
      setState(() {
        isModalVisible = !isModalVisible;
      });
    } else {
      _pageController.jumpToPage(index);
      setState(() {
        selectedPage = index;
        isModalVisible = false;
      });
    }
  }

  _onPageChanged(int index) {
    setState(() {
      selectedPage = index;
      isModalVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: const [
              Home(),
              SizedBox(),
              SizedBox(),
              ProfileImage(),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isModalVisible ? 0 : -600,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: const Profile(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedPage,
        onTap: (int index) {
          _navigateToPage(index);
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
              activeIcon: Icon(Icons.home)),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_text),
              label: "Chat",
              activeIcon: Icon(CupertinoIcons.chat_bubble_text_fill)),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.smiley),
              label: "Trends",
              activeIcon: Icon(CupertinoIcons.smiley_fill)),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_sharp),
              label: "Profile",
              activeIcon: Icon(Icons.person)),
        ],
      ),
    );
  }
}
