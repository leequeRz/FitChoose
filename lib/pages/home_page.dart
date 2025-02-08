import 'package:fitchoose/components/bottom_navigation.dart';
import 'package:fitchoose/pages/virtual_tryon.dart';
import 'package:fitchoose/pages/wardrope_page.dart';
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
          // body: SafeArea(
          //   child: SingleChildScrollView(
          //     physics: const BouncingScrollPhysics(),
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 30.0),
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.start,
          //         children: [
          //           Align(
          //             alignment: Alignment.centerLeft,
          //             child: Text(
          //               'Nan',
          //               style: TextStyle(
          //                 fontSize: 26,
          //                 fontWeight: FontWeight.bold,
          //                 color: Color(0xFF9B7EBD),
          //               ),
          //             ),
          //           ),
          //           SizedBox(height: 40),
          //           ContainerHome(),
          //           SizedBox(height: 40),
          //           ContainerHome(
          //               title: 'What is FitChoose',
          //               subtitle:
          //                   'Fitchoose is an application designed for users who want to try on outfits that perfectly suit them.'),
          //           SizedBox(height: 40),
          //           ContainerHome(
          //               title: 'What is Personal Color?',
          //               subtitle:
          //                   'It is colorology theorry that finds the best colors for a person is skin tone.'),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
