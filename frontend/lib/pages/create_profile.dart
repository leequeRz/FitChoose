import 'package:fitchoose/components/custom_inputfield.dart';
import 'package:fitchoose/components/gender_selector.dart';
import 'package:fitchoose/pages/home_page.dart';
import 'package:fitchoose/services/firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// เพิ่ม imports สำหรับ Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  //firestore
  final FirestoreService firestoreService = FirestoreService();

  // สร้างตัวแปรเก็บรูปภาพ
  File? _image;
  final _picker = ImagePicker();

  //text controller
  final TextEditingController usernameController = TextEditingController();

  //gender controller
  Gender? _selectedGender;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'เลือกแหล่งที่มาของรูปภาพ',
          style: TextStyle(
            color: Color(0xFF3B1E54),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: Color(0xFF9B7EBD)),
                title: Text('แกลเลอรี่',
                    style: TextStyle(color: Color(0xFF3B1E54))),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Color(0xFF9B7EBD)),
                title: Text('กล้องถ่ายรูป',
                    style: TextStyle(color: Color(0xFF3B1E54))),
                onTap: () {
                  Navigator.of(context).pop();
                  pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // // ฟังก์ชันบันทึกข้อมูลลง Firebase
  // Future<bool> saveUserData() async {
  //   try {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     // 1. ตรวจสอบว่ามีการเข้าสู่ระบบหรือไม่
  //     final currentUser = FirebaseAuth.instance.currentUser;
  //     if (currentUser == null) {
  //       // ถ้ายังไม่มีผู้ใช้ คุณอาจต้องลงทะเบียนหรือเข้าสู่ระบบก่อน
  //       // หรือใช้ anonymous login ในกรณีนี้:
  //       await FirebaseAuth.instance.signInAnonymously();
  //     }

  //     final userId = FirebaseAuth.instance.currentUser!.uid;
  //     String? imageUrl;

  //     // 2. อัพโหลดรูปภาพไปที่ Firebase Storage (ถ้ามี)
  //     if (_image != null) {
  //       final storageRef = FirebaseStorage.instance
  //           .ref()
  //           .child('profile_images')
  //           .child('$userId.jpg');

  //       // อัพโหลดรูปภาพ
  //       final uploadTask = await storageRef.putFile(
  //         _image!,
  //         SettableMetadata(contentType: 'image/jpeg'),
  //       );

  //       // รับ URL ของรูปภาพ
  //       imageUrl = await storageRef.getDownloadURL();
  //     }

  //     // 3. บันทึกข้อมูลผู้ใช้ใน Firestore
  //     await FirebaseFirestore.instance.collection('users').doc(userId).set({
  //       'username': _usernameController.text,
  //       'gender': _selectedGender
  //           ?.toString()
  //           .split('.')
  //           .last, // แปลง enum เป็น string
  //       'profileImage': imageUrl,
  //       'createdAt': FieldValue.serverTimestamp(),
  //       'updatedAt': FieldValue.serverTimestamp(),
  //     }, SetOptions(merge: true));

  //     setState(() {
  //       _isLoading = false;
  //     });
  //     return true;
  //   } catch (e) {
  //     print('Error saving user data: $e');
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     return false;
  //   }
  // }

  @override
  void dispose() {
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBEAFF),
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Color(0xFF3B1E54)))
            : Form(
                key: _formKey,
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                            onTap: _showImageSourceDialog,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: _image == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                          SizedBox(height: 30),
                          //ใส่ Username
                          CustomInputField(
                            label: 'Username',
                            textController: usernameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'กรุณากรอกชื่อผู้ใช้';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          GenderSelector(
                            initialGender: _selectedGender,
                            onGenderSelected: (gender) {
                              setState(() {
                                _selectedGender = gender;
                              });
                            },
                          ),
                          SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // // ตรวจสอบความถูกต้องของฟอร์ม
          // if (_formKey.currentState!.validate()) {
          //   // ตรวจสอบว่าได้เลือกเพศหรือไม่
          //   if (_selectedGender == null) {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text("กรุณาเลือกเพศ")),
          //     );
          //     return;
          //   }

          // บันทึกข้อมูล
          bool success =
              await firestoreService.addUser(username: usernameController.text);
          if (success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึกข้อมูล")),
            );
          }
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.check, color: Color(0xFF3B1E54)),
      ),
    );
  }
}
