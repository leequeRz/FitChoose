import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class VirtualTryOnPage extends StatefulWidget {
  const VirtualTryOnPage({super.key});

  @override
  _VirtualTryOnPageState createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage> {
  String selectedCategory = 'Upper-Body';

  // Sample data - Replace with your actual data
  final Map<String, List<String>> clothingItems = {
    'Upper-Body': [
      'assets/images/test.png',
    ],
    'Lower-Body': [
      'assets/images/test.png',
      'assets/images/test.png',
    ],
    'Dress': [
      'assets/images/test.png',
      'assets/images/test.png',
      'assets/images/test.png',
    ],
  };

  File? _image;

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF), // Light purple background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Virtual Try-on',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B1E54), // Deep purple
                ),
              ),
              const Text(
                'Customize your outfit effortlessly',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF9B7EBD), // Medium purple
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: pickImage,
                child: Center(
                  child: Container(
                    width: 260,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 60,
                                color: Color(0xFF9B7EBD),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Upload Your Picture',
                                style: TextStyle(
                                  color: Color(0xFF9B7EBD),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              _image!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (String category in [
                      'Upper-Body',
                      'Lower-Body',
                      'Dress'
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: CategoryButton(
                          text: category,
                          isSelected: selectedCategory == category,
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: clothingItems[selectedCategory]?.length ?? 0,
                  itemBuilder: (context, index) {
                    return ClothingItemCard(
                      imagePath: clothingItems[selectedCategory]![index],
                      onDeleteTap: () {
                        // Handle delete
                        print('Delete item $index from $selectedCategory');
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Category Button Widget
class CategoryButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6D8F5) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFF9B7EBD) : const Color(0xFFCBB6E5),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Clothing Item Card Widget
class ClothingItemCard extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onDeleteTap;

  const ClothingItemCard({
    Key? key,
    required this.imagePath,
    this.onDeleteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAE2F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
