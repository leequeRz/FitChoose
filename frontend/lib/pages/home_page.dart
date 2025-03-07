import 'package:fitchoose/components/bottom_navigation.dart';
import 'package:fitchoose/pages/matching/matching_page.dart';
import 'package:fitchoose/pages/profile/profile_page.dart';
import 'package:fitchoose/pages/virtualtryon/virtual_tryon_page.dart';
import 'package:fitchoose/pages/wardrope/wardrope_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // this selected index is to control the bottom navigation bar
  int _selectedIndex = 0;

  // this method will update our selected index
  // when the user taps on the bottom bar
  void navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    //page to display
    final List<Widget> _pages = [
      const WardropePage(),
      const VirtualTryOnPage(),
      const MatchingPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      bottomNavigationBar: BottomNavBar(
        onTabChange: (index) => navigateBottomBar(index),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          WardropePage(),
          VirtualTryOnPage(),
          MatchingPage(),
          ProfilePage(),
        ],
      ),
    );
  }
}
