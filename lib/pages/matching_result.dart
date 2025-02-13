import 'package:fitchoose/components/container_matchingresult.dart';
import 'package:fitchoose/components/matchingresult_pictureselect.dart';
import 'package:fitchoose/components/matchingresult_picturesuggest.dart';
import 'package:flutter/material.dart';

class MatchingResult extends StatefulWidget {
  const MatchingResult({super.key});

  @override
  State<MatchingResult> createState() => _MatchingResultState();
}

class _MatchingResultState extends State<MatchingResult> {
  bool isFavorite = false;

  final List<String> clothingItems = [
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text(
          'Matching +',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B1E54),
          ),
        ),
        backgroundColor: const Color(0xFFF5F0FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Matching Result',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF9B7EBD),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 36),
                  Center(
                    child: MatchingPictureSelect(
                      imageUrl: 'assets/images/test.png',
                      width: 160,
                      height: 160,
                    ),
                  ),
                  SizedBox(height: 36),
                  StyleDescriptionCard(
                    title: 'Vintage Style',
                    description:
                        'Bringing back or reinterpreting past fashion styles, such as flared jeans that were popular in the 60s and have become trendy again in the present day.', // ตรงนี้ต้องทำการดึงข้อมูล API คำอธิบายจาก database มา
                    isFavorite: isFavorite,
                    onFavoriteTap: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  MatchingPictureSuggest(
                      title: 'Matching Outfits',
                      imageUrls: [
                        'assets/images/test.png',
                        'assets/images/test.png'
                      ],
                      onItemTap: (index) {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
