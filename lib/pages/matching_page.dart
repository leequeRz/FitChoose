import 'dart:io';

import 'package:fitchoose/pages/matching_result.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
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
                'Matching +',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B1E54), // Deep purple
                ),
              ),
              const Text(
                'Matching Your Outfits',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF9B7EBD), // Medium purple
                ),
              ),
              SizedBox(height: 36),
              GestureDetector(
                onTap: pickImage,
                child: Center(
                  child: Container(
                    width: 230,
                    height: 190,
                    decoration: BoxDecoration(
                      color: Color(0xFFD4BEE4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Select Your',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Upper-Body',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
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
              const SizedBox(height: 24),
              Center(
                child: const Text('OR',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: pickImage,
                child: Center(
                  child: Container(
                    width: 230,
                    height: 190,
                    decoration: BoxDecoration(
                      color: Color(0xFFD4BEE4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Select Your',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Lower-Body',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
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
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 60),
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchingResult(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B7EBD),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Matching',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
