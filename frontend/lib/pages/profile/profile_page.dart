import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitchoose/components/pictureselect.dart';
import 'package:fitchoose/components/profilename_section.dart';
import 'package:fitchoose/pages/loginregister/login_or_register_page.dart';
import 'package:fitchoose/services/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Loading...';
  String gender = 'Loading...';
  String? imageUrl;
  bool isLoading = true;
  final apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันดึงข้อมูลผู้ใช้เมื่อหน้าถูกโหลด
    _loadUserProfile();
  }

// ฟังก์ชันดึงข้อมูลผู้ใช้จาก API
  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userId = user.uid;
        print('Fetching profile for user: $userId');

        // เรียกใช้ API เพื่อดึงข้อมูลผู้ใช้
        final response = await apiService.checkUserExists(userId);

        if (response['exists'] == true && response.containsKey('user_data')) {
          final userData = response['user_data'];
          setState(() {
            userName = userData['username'] ?? 'No Name';
            gender = userData['gender'] ?? 'Not Specified';
            imageUrl = userData['image_url'];
            isLoading = false;
          });
          print('Profile loaded: $userName, $gender');
        } else {
          print('User profile not found');
          setState(() {
            userName = 'Profile Not Found';
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        userName = 'Error Loading Profile';
        isLoading = false;
      });
    }
  }

  // เพิ่มฟังก์ชันลบรูปเก่า
  Future<void> _deleteOldProfileImage(String? oldImageUrl) async {
    if (oldImageUrl != null &&
        oldImageUrl.isNotEmpty &&
        oldImageUrl.startsWith('https://')) {
      try {
        // แปลง URL เป็น path ใน Firebase Storage
        final ref = FirebaseStorage.instance.refFromURL(oldImageUrl);
        await ref.delete();
        print('Old profile image deleted successfully');
      } catch (e) {
        print('Error deleting old profile image: $e');
        // ถ้าเกิดข้อผิดพลาดในการลบรูปเก่า ให้ดำเนินการต่อ
      }
    }
  }

  // เพิ่มฟังก์ชันเลือกและอัปโหลดรูปภาพ
  Future<void> _pickAndUploadImage() async {
    try {
      // เลือกรูปภาพจากแกลเลอรี่
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // แสดง loading indicator
        setState(() {
          isLoading = true;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final userId = user.uid;

          // ลบรูปเก่าก่อน (ถ้ามี)
          await _deleteOldProfileImage(imageUrl);

          // สร้างชื่อไฟล์ที่ไม่ซ้ำกัน
          final fileName =
              'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';

          // อ้างอิงไปยัง Firebase Storage
          final storageRef =
              FirebaseStorage.instance.ref().child('profile_images/$fileName');

          // อัปโหลดไฟล์
          await storageRef.putFile(File(pickedFile.path));

          // รับ URL ของรูปภาพ
          final downloadUrl = await storageRef.getDownloadURL();

          // อัปเดต URL ใน MongoDB
          await apiService.updateUser(userId, {'image_url': downloadUrl});

          // อัปเดตหน้า UI
          setState(() {
            imageUrl = downloadUrl;
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile image updated successfully')),
          );
        } else {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error picking/uploading image: $e');
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update profile image: ${e.toString()}')),
      );
    }
  }

  Future<void> _showEditDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditNameDialog(initialName: userName),
    );

    if (result != null) {
      setState(() {
        userName = result;
      });
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // ต้องเพิ่มฟังก์ชัน updateUser ใน ApiService
          await apiService.updateUser(user.uid, {'username': result});
        }
      } catch (e) {
        print('Error updating username: $e');
      }
    }
  }

  //sign user out method
  Future<void> signUserOut() async {
    try {
      // แสดง loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // ล็อกเอาท์จาก Firebase
      await FirebaseAuth.instance.signOut();

      // ปิด loading indicator
      Navigator.pop(context);

      // นำทางกลับไปยังหน้า IntroPage
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginOrRegisterPage()),
        (route) => false, // ลบทุก route ที่อยู่ใน stack
      );
    } catch (e) {
      // ปิด loading indicator ในกรณีที่เกิดข้อผิดพลาด
      Navigator.pop(context);

      // แสดงข้อความแจ้งเตือนข้อผิดพลาด
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: ${e.toString()}')),
      );
      print('Error signing out: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F0FF),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B1E54), // Deep purple
                            ),
                          ),
                          IconButton(
                            onPressed: signUserOut,
                            icon: Icon(Icons.logout),
                          )
                        ],
                      ),
                      const Text(
                        'Your Profile',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF9B7EBD), // Deep purple
                        ),
                      ),
                      const SizedBox(height: 24),
                      ProfileNameSection(
                        name: userName,
                        onEditPressed: _showEditDialog,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: GestureDetector(
                          onTap: _pickAndUploadImage,
                          child: PictureSelect(
                            imageUrl: imageUrl ?? 'assets/images/test.png',
                            width: 230,
                            height: 300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        'Gender',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B1E54)),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: 160,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFD4BEE4),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            gender,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
