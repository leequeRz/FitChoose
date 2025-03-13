import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitchoose/pages/home_page.dart';
import 'package:fitchoose/pages/loginregister/login_or_register_page.dart';
import 'package:fitchoose/services/api_service.dart';
import 'package:fitchoose/pages/create_profile.dart'; // เพิ่ม import
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  AuthGate({super.key});

  final apiService = ApiService();

  // ฟังก์ชันตรวจสอบว่าผู้ใช้มีโปรไฟล์แล้วหรือยัง
  Future<Map<String, dynamic>> _checkUserProfile(String userId) async {
    try {
      print("Checking profile for user: $userId");
      // เรียกใช้ API เพื่อตรวจสอบว่ามีโปรไฟล์แล้วหรือยัง
      final response = await apiService.checkUserExists(userId);
      print("API response: $response");

      // ตรวจสอบให้แน่ใจว่าค่า exists เป็น boolean
      bool exists = false;

      if (response.containsKey('exists')) {
        exists = response['exists'] == true;
      } else if (response.containsKey('user_data')) {
        // ถ้ามีข้อมูล user_data แสดงว่ามีโปรไฟล์แล้ว
        exists = true;
      }

      print("Profile exists: $exists");
      return {'exists': exists};
    } catch (e) {
      print('Error checking user profile: $e');
      // ถ้าเกิดข้อผิดพลาด ให้ถือว่ายังไม่มีโปรไฟล์
      return {'exists': false};
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // ถ้ายังไม่มีการล็อกอิน ให้ไปหน้า LoginOrRegister
        if (!snapshot.hasData) {
          return LoginOrRegisterPage();
        }

        // ถ้ามีการล็อกอิน ตรวจสอบว่ามีโปรไฟล์หรือไม่
        return FutureBuilder<Map<String, dynamic>>(
          future: _checkUserProfile(snapshot.data!.uid),
          builder: (context, profileSnapshot) {
            // แสดง loading ระหว่างตรวจสอบ
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // ถ้ามีโปรไฟล์แล้ว ไปที่หน้าหลัก
            if (profileSnapshot.data != null &&
                profileSnapshot.data!['exists'] == true) {
              print("User has profile, going to HomePage");
              return HomePage();
            }

            // ถ้ายังไม่มีโปรไฟล์ ให้ไปที่หน้า CreateProfile
            print("User has no profile, redirecting to CreateProfile");
            return CreateProfile(
              userId: snapshot.data!.uid,
              isNewUser: true,
            );
          },
        );
      },
    );
  }
}
