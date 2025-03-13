import 'package:fitchoose/components/custom_inputfield.dart';
import 'package:fitchoose/components/gender_selector.dart';
import 'package:fitchoose/pages/home_page.dart';
import 'package:fitchoose/services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// เพิ่ม imports สำหรับ Firebase
import 'package:firebase_storage/firebase_storage.dart';

class CreateProfile extends StatefulWidget {
  final String userId;
  final bool isNewUser;

  const CreateProfile(
      {super.key, required this.userId, required this.isNewUser});

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  // เพิ่ม API service
  final ApiService apiService = ApiService();

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

  @override
  void initState() {
    super.initState();
    // ถ้าไม่ใช่ผู้ใช้ใหม่ ให้ตรวจสอบว่ามีโปรไฟล์อยู่แล้วหรือไม่
    if (!widget.isNewUser) {
      _checkExistingProfile();
    }
  }

  // เพิ่มฟังก์ชันตรวจสอบโปรไฟล์ที่มีอยู่
  Future<void> _checkExistingProfile() async {
    try {
      // ดึงข้อมูลโปรไฟล์จาก API
      final userProfile = await apiService.getUser(widget.userId);

      // ถ้ามีโปรไฟล์อยู่แล้ว ให้นำทางไปยังหน้า HomePage
      if (userProfile != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      print('Error checking profile: $e');
      // ถ้าเกิดข้อผิดพลาด ให้แสดงหน้าสร้างโปรไฟล์ตามปกติ
    }
  }

  // เพิ่มฟังก์ชันสำหรับอัปโหลดรูปภาพและสร้างผู้ใช้ผ่าน API
  // ในฟังก์ชัน createUserViaApi หรือฟังก์ชันที่ทำการสร้างโปรไฟล์
  Future<bool> createUserViaApi() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // สร้าง UUID สำหรับ user_id
      // final uuid = Uuid();
      // final userId = uuid.v4(); // สร้าง UUID v4 (random)

      String? imageUrl;

      // อัปโหลดรูปภาพไปที่ Firebase Storage (ถ้ามี)
      if (_image != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

          // อัปโหลดรูปภาพ
          await storageRef.putFile(
            _image!,
            SettableMetadata(contentType: 'image/jpeg'),
          );

          // รับ URL ของรูปภาพ
          imageUrl = await storageRef.getDownloadURL();
        } catch (storageError) {
          print('Firebase Storage error: $storageError');
          // ถ้าเกิดข้อผิดพลาดในการอัปโหลดรูปภาพ ให้ดำเนินการต่อโดยไม่มีรูปภาพ
          imageUrl = null;
        }
      }

      // แปลงค่า enum Gender เป็น string
      String genderString = '';
      if (_selectedGender == Gender.male) {
        genderString = 'Male';
      } else if (_selectedGender == Gender.female) {
        genderString = 'Female';
      } else {
        genderString = 'Other';
      }

      // เรียกใช้ API สร้างผู้ใช้
      final response = await apiService.createUser(
        user_id: widget.userId, // ใช้ Firebase UID ที่ส่งมาจาก widget
        username: usernameController.text,
        gender: genderString,
        imageUrl: imageUrl,
      );

      if (response['status_code'] == 200) {
        // สร้างโปรไฟล์สำเร็จ
        setState(() {
          _isLoading = false;
        });

        // นำทางไปยังหน้าหลัก
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        return true;
      } else {
        print('API response does not contain ID: $response');
        setState(() {
          _isLoading = false;
        });
        return false;
      }
    } catch (e) {
      print('Error creating user: $e');
      setState(() {
        _isLoading = false;
      });

      // แสดงข้อความข้อผิดพลาดที่เฉพาะเจาะจงมากขึ้น
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เกิดข้อผิดพลาด: ${e.toString()}")),
      );
      return false;
    }
  }

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
          // ตรวจสอบความถูกต้องของฟอร์ม
          if (_formKey.currentState!.validate()) {
            // ตรวจสอบว่าได้เลือกเพศหรือไม่
            if (_selectedGender == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("กรุณาเลือกเพศ")),
              );
              return;
            }

            // บันทึกข้อมูลผ่าน API
            bool success = await createUserViaApi();
            if (success) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("เกิดข้อผิดพลาดในการบันทึกข้อมูล")),
              );
            }
          }
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.check, color: Color(0xFF3B1E54)),
      ),
    );
  }
}
