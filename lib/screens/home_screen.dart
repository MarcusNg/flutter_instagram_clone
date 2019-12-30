import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clone/models/user_data.dart';
import 'package:flutter_instagram_clone/screens/activity_screen.dart';
import 'package:flutter_instagram_clone/screens/create_post_screen.dart';
import 'package:flutter_instagram_clone/screens/feed_screen.dart';
import 'package:flutter_instagram_clone/screens/profile_screen.dart';
import 'package:flutter_instagram_clone/screens/search_screen.dart';
import 'package:flutter_instagram_clone/services/auth_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTab = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    final String currentUserId = Provider.of<UserData>(context).currentUserId;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          FeedScreen(currentUserId: currentUserId),
          SearchScreen(),
          CreatePostScreen(),
          ActivityScreen(currentUserId: currentUserId),
          ProfileScreen(
            currentUserId: currentUserId,
            userId: currentUserId,
          ),
        ],
        onPageChanged: (int index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentTab,
        onTap: (int index) {
          setState(() {
            _currentTab = index;
          });
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
        activeColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_camera,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications,
              size: 32.0,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              size: 32.0,
            ),
          ),
        ],
      ),
    );
  }
}
