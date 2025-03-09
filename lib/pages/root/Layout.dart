import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tradingapp/admin/pages/AdminDashboard.dart';
import 'package:tradingapp/pages/messages/ChatListScreen.dart';
import 'package:tradingapp/pages/newsAlerts/NewsAlerts.dart';
import 'package:tradingapp/pages/root/profile/Profile.dart';
import 'package:tradingapp/pages/root/profile/components/ProfileImage.dart';
import 'package:tradingapp/pages/signals/SignalsPage.dart';

import 'home/Home.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  int selectedPage = 0;
  bool isModalVisible = false;
  final PageController _pageController = PageController();

  _navigateToPage(int index) {
    if (index == 4) {
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
            physics: selectedPage == 1 ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
            children: const [
              SignalsPage(),
              NewsAlerts(),
              // AdminDashboard(),
              Home(),
              ChatListScreen(),
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
                color: Theme.of(context).canvasColor,
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
              icon: Icon(CupertinoIcons.chart_bar_alt_fill),
              label: "Signals", 
              activeIcon: Icon(CupertinoIcons.chart_bar_alt_fill)),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.news),
              label: "News/Updates",
              activeIcon: Icon(CupertinoIcons.news_solid)),
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
              activeIcon: Icon(Icons.home)),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_text),
              label: "Chat",
              activeIcon: Icon(CupertinoIcons.chat_bubble_text_fill)),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_sharp),
              label: "Profile",
              activeIcon: Icon(Icons.person)),
        ],
      ),
    );
  }
}
