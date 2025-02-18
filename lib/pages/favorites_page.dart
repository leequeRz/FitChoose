import 'package:fitchoose/components/favorite_matching.dart';
import 'package:fitchoose/pages/favorites_history.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B1E54),
          ),
        ),
        backgroundColor: const Color(0xFFF5F0FF),
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F0FF),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Favorites',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF9B7EBD),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 36),
                Container(
                  width: 120,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFD4BEE4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'Matching +',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FavoritesHistory(),
                    ),
                  ),
                  child: FavoritesCard(
                    upperImagePath: 'assets/images/test.png',
                    lowerImagePath: 'assets/images/test.png',
                    dateAdded: DateTime.now(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
