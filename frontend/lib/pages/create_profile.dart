import 'package:fitchoose/components/custom_inputfield.dart';
import 'package:fitchoose/components/gender_selector.dart';
import 'package:fitchoose/pages/home_page.dart';
import 'package:fitchoose/services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitchoose/widgets/profile_picture_guide_popup.dart';

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

    // แสดง popup หลังจากที่ widget ถูกสร้างเสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showProfilePictureGuide();
    });
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

  // เพิ่มฟังก์ชันสำหรับแสดง popup
  void _showProfilePictureGuide() {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิดโดยการแตะพื้นหลัง
      builder: (BuildContext context) {
        return ProfilePictureGuidePopup(
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // เพิ่มฟังก์ชันสำหรับอัปโหลดรูปภาพและสร้างผู้ใช้ผ่าน API
  Future<bool> createUserViaApi() async {
    try {
      // ตรวจสอบว่าได้กรอกชื่อผู้ใช้หรือไม่
      if (usernameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("กรุณากรอกชื่อผู้ใช้")),
        );
        return false;
      }

      // ตรวจสอบว่าได้เลือกเพศหรือไม่
      if (_selectedGender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("กรุณาเลือกเพศ")),
        );
        return false;
      }

      setState(() {
        _isLoading = true;
      });

      String? imageUrl;

      // อัปโหลดรูปภาพไปที่ Firebase Storage (ถ้ามี)
      if (_image != null) {
        try {
          // สร้างชื่อไฟล์ที่ไม่ซ้ำกันโดยใช้ userId แกะกัน
          final fileName =
              'profile_${widget.userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child(fileName);

          // แสดงข้อความกำลังอัปโหลด
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("กำลังอัปโหลดรูปภาพ...")),
          );

          // อัปโหลดรูปภาพ
          final uploadTask = storageRef.putFile(
            _image!,
            SettableMetadata(contentType: 'image/jpeg'),
          );

          // ติดตามความคืบหน้าของการอัปโหลด (ถ้าต้องการ)
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            print('Upload progress: ${(progress * 100).toStringAsFixed(2)}%');
          });

          // รอจนกว่าการอัปโหลดจะเสร็จสิ้น
          await uploadTask;

          // รับ URL ของรูปภาพ
          imageUrl = await storageRef.getDownloadURL();

          print('Image uploaded successfully. URL: $imageUrl');

          // ปิดข้อความกำลังอัปโหลด
          ScaffoldMessenger.of(context).clearSnackBars();
        } catch (storageError) {
          print('Firebase Storage error: $storageError');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: ${storageError.toString()}")),
          );

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
        username: usernameController.text.trim(),
        gender: genderString,
        imageUrl: imageUrl,
      );

      if (response['status_code'] == 200) {
        // สร้างโปรไฟล์สำเร็จ
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("สร้างโปรไฟล์สำเร็จ")),
        );

        // นำทางไปยังหน้าหลัก
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );

        return true;
      } else {
        print('API response error: $response');
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "เกิดข้อผิดพลาดในการสร้างโปรไฟล์: ${response['message'] ?? 'Unknown error'}")),
        );

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
            // เรียกใช้ฟังก์ชันสร้างผู้ใช้
            await createUserViaApi();
          }
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.check, color: Color(0xFF3B1E54)),
      ),
    );
  }
}
