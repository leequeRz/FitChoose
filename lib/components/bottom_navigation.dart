import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavBar extends StatelessWidget {
  void Function(int) onTabChange;

  BottomNavBar({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return GNav(
      backgroundColor: Colors.white,
      color: Color(0xFFD4BEE4),
      activeColor: Colors.white,
      tabBackgroundColor: Color(0xFF9B7EBD),
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      tabBorderRadius: 0, // Set border radius to 0 for square tabs
      onTabChange: (value) => onTabChange!(value),
      tabs: const [
        // GButton(
        //   icon: Icons.home,
        //   text: 'Home',
        // ),
        GButton(
          icon: Icons.checkroom,
          text: 'Wardrobe', // Corrected spelling
        ),
        GButton(
          icon: Icons.view_in_ar,
          text: 'Virtual Try-On',
        ),
        GButton(
          icon: Icons.style,
          text: 'Matching',
        ),
        GButton(
          icon: Icons.person,
          text: 'Profile',
        ),
      ],
    );
  }
}
