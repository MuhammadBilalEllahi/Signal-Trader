import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tradingapp/admin/pages/AdminDashboard.dart';
import 'package:tradingapp/pages/messages/ChatListScreen.dart';
import 'package:tradingapp/pages/newsAlerts/NewsAlerts.dart';
import 'package:tradingapp/pages/root/profile/Profile.dart';
import 'package:tradingapp/pages/root/profile/components/ProfileImage.dart';
import 'package:tradingapp/pages/root/subscription/SubscriptionPage.dart';
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
  bool isLoading = false;
  bool hasError = false;
  String errorMessage = '';
  final PageController _pageController = PageController();

  void _navigateToPage(int index) {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      if (index == 4) {
        _pageController.jumpToPage(index);
        setState(() {
          isModalVisible = !isModalVisible;
          isLoading = false;
        });
      } else {
        _pageController.jumpToPage(index);
        setState(() {
          selectedPage = index;
          isModalVisible = false;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Failed to load page. Please try again.';
        isLoading = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      selectedPage = index;
      isModalVisible = false;
      hasError = false;
      errorMessage = '';
    });
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _navigateToPage(selectedPage),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          if (hasError)
            _buildErrorWidget()
          else if (isLoading)
            _buildLoadingWidget()
          else
            PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              physics: selectedPage == 1
                  ? const NeverScrollableScrollPhysics()
                  : const PageScrollPhysics(),
              children: const [
                SignalsPage(),
                NewsAlerts(),
                Home(),
                SubscriptionPage(),
                // ChatListScreen(),
                ProfileImage(),
              ],
            ),
          if (!hasError && !isLoading)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              bottom: isModalVisible ? 0 : -600,
              left: 0,
              right: 0,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
                    ),
                  ),
                ),
                child: const Profile(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedPage,
          onTap: isLoading ? null : _navigateToPage,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar_alt_fill, size: 20),
              label: "Signals",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.news, size: 20),
              label: "Analysis",
              activeIcon: Icon(CupertinoIcons.news_solid, size: 20),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 20),
              label: "Home",
              activeIcon: Icon(Icons.home, size: 20),
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(CupertinoIcons.chat_bubble_text, size: 20),
            //   label: "Chat",
            //   activeIcon: Icon(CupertinoIcons.chat_bubble_text_fill, size: 20),
            // ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.creditcard, size: 20),
              label: "Plans",
              activeIcon: Icon(CupertinoIcons.creditcard_fill, size: 20),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_sharp, size: 20),
              label: "Profile",
              activeIcon: Icon(Icons.person, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
