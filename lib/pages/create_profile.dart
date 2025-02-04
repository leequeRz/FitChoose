import 'package:fitchoose/components/custom_inputfield.dart';
import 'package:fitchoose/components/gender_selector.dart';
import 'package:fitchoose/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  File? _image;
  final _picker = ImagePicker();

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBEAFF),
      body: SafeArea(
        //กันชนขอบจอ
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                'Let\'s Get Started',
                style: TextStyle(
                  fontSize: 30,
                  color: Color(0xFF3B1E54),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Create your Profile',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF9B7EBD),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: 200,
                  height: 200,
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
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: CustomInputField(label: 'Username'),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: GenderSelector(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.check, color: Color(0xFF3B1E54)),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     bool success = await saveData(); // บันทึกข้อมูลก่อน
      //     if (success) {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => const CreateProfile()),
      //       );
      //     } else {
      //       // แจ้งเตือนถ้าบันทึกไม่สำเร็จ
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         const SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึกข้อมูล")),
      //       );
      //     }
      //   },
      //   backgroundColor: Colors.white,
      //   shape: const CircleBorder(),
      //   child: const Icon(Icons.check, color: Color(0xFF3B1E54)),
      // ),
    );
  }
}
