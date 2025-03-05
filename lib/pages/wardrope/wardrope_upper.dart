import 'package:fitchoose/components/clothing_itemcard.dart';
import 'package:flutter/material.dart';

class WardropeUpper extends StatefulWidget {
  const WardropeUpper({super.key});

  @override
  State<WardropeUpper> createState() => _WardropeUpperState();
}

class _WardropeUpperState extends State<WardropeUpper> {
  // List of clothing items
  final List<String> clothingItems = [
    'assets/images/test.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text(
          'Wardrobe',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B1E54),
          ),
        ),
        backgroundColor: const Color(0xFFF5F0FF),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: const Text(
                'Your Upper-Body (6 items)',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9E8BB1),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: clothingItems.length,
                itemBuilder: (context, index) {
                  return ClothingItemCard(
                    imagePath: clothingItems[index],
                    onDeleteTap: () {
                      // Handle more options tap
                      print('Delete tapped for item $index');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
