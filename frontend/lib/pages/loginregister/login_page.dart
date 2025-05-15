import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitchoose/components/loginregis/button_login_regis.dart';
import 'package:fitchoose/components/loginregis/login_regis_textfield.dart';
import 'package:fitchoose/components/loginregis/square_tile.dart';
import 'package:fitchoose/pages/loginregister/forget_pw_page.dart';
import 'package:fitchoose/services/auth_service.dart';
import 'package:fitchoose/services/api_service.dart'; // เพิ่ม import
import 'package:fitchoose/pages/home_page.dart'; // เพิ่ม import
import 'package:fitchoose/pages/create_profile.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final apiService = ApiService(); // เพิ่ม apiService

  // เพิ่มฟังก์ชันตรวจสอบโปรไฟล์
  Future<bool> _checkUserProfile(String userId) async {
    try {
      print("กำลังตรวจสอบโปรไฟล์ของผู้ใช้: $userId");
      final response = await apiService.checkUserExists(userId);
      print("ผลการตรวจสอบโปรไฟล์: $response");

      // แปลงค่าให้เป็น boolean ที่ชัดเจน
      bool exists = response['exists'] == true;
      print("มีโปรไฟล์หรือไม่ (boolean): $exists");

      return exists;
    } catch (e) {
      print('เกิดข้อผิดพลาดในการตรวจสอบโปรไฟล์: $e');
      return false;
    }
  }

// และในส่วนของการจัดการ error
  void signUserIn() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    //try sign in
    try {
      // ล็อกอินด้วย Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      //pop the loading circle
      Navigator.pop(context);
      // ตรวจสอบว่ามีโปรไฟล์แล้วหรือยัง
      if (userCredential.user != null) {
        print("ล็อกอินสำเร็จ: ${userCredential.user!.uid}");
        final hasProfile = await _checkUserProfile(userCredential.user!.uid);
        print("มีโปรไฟล์หรือไม่: $hasProfile");

        if (!hasProfile) {
          // ถ้ายังไม่มีโปรไฟล์ ให้นำทางไปยังหน้าสร้างโปรไฟล์
          print("ไม่พบโปรไฟล์ กำลังนำทางไปหน้าสร้างโปรไฟล์...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreateProfile(
                userId: userCredential.user!.uid,
                isNewUser: true,
              ),
            ),
          );
        } else {
          // ถ้ามีโปรไฟล์แล้ว นำทางไปยังหน้าหลัก
          print("พบโปรไฟล์แล้ว กำลังนำทางไปหน้าหลัก...");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false, // ลบทุกหน้าออกจาก stack
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      //pop the loading circle
      Navigator.pop(context);
      print("Firebase Error Code: ${e.code}"); // ดู error code ที่แท้จริง

      // ใช้ switch case แทนเพื่อครอบคลุม error code ที่เป็นไปได้ทั้งหมด
      switch (e.code) {
        case 'user-not-found':
          showErrorSnackBar('Incorrect Email');
          break;
        case 'wrong-password':
          showErrorSnackBar('Incorrect Password');
          break;
        case 'invalid-email':
          showErrorSnackBar('Invalid Email Format');
          break;
        case 'user-disabled':
          showErrorSnackBar('This account has been disabled');
          break;
        default:
          print("Technical error: ${e.code} - ${e.message}");
          showErrorSnackBar(
              'Login Failed. Please check your Email or Password and try again.');
          break;
      }
    } catch (e) {
      Navigator.pop(context);
      print("General Error: $e");
      showErrorSnackBar('An error occurred. Please try again.');
    }
  }

// แก้ไขฟังก์ชัน Google Sign In ด้วย
  Future<void> _signInWithGoogle() async {
    // แสดง loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final userCredential = await AuthService().signInWithGoogle();

      // ปิด loading circle
      Navigator.pop(context);

      if (userCredential != null && userCredential.user != null) {
        print("Google Sign In สำเร็จ: ${userCredential.user!.uid}");
        // ตรวจสอบว่ามีโปรไฟล์แล้วหรือยัง
        final hasProfile = await _checkUserProfile(userCredential.user!.uid);
        print("มีโปรไฟล์หรือไม่: $hasProfile");

        if (!hasProfile) {
          // ถ้ายังไม่มีโปรไฟล์ ให้นำทางไปยังหน้าสร้างโปรไฟล์
          print("ไม่พบโปรไฟล์ กำลังนำทางไปหน้าสร้างโปรไฟล์...");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreateProfile(
                userId: userCredential.user!.uid,
                isNewUser: true,
              ),
            ),
          );
        } else {
          // ถ้ามีโปรไฟล์แล้ว นำทางไปยังหน้าหลัก
          print("พบโปรไฟล์แล้ว กำลังนำทางไปหน้าหลัก...");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
            (route) => false,
          );
        }
      } else {
        print("Google Sign In ล้มเหลว: userCredential เป็น null");
        showErrorSnackBar('การล็อกอินด้วย Google ล้มเหลว กรุณาลองใหม่อีกครั้ง');
      }
    } catch (e) {
      // ปิด loading circle
      Navigator.pop(context);

      print('Error signing in with Google: $e');
      showErrorSnackBar('การล็อกอินด้วย Google ล้มเหลว: ${e.toString()}');
    }
  }

  //แสดง snackbar error
  void showErrorSnackBar(String message) {
    // ดูว่าเข้าฟังก์ชันนี้หรือไม่
    print("Showing SnackBar: $message");

    // ใช้ Builder เพื่อให้แน่ใจว่า context ถูกต้อง
    ScaffoldMessenger.of(context).clearSnackBars(); // เคลียร์ snackbar เก่าก่อน
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEBEAFF),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //logo
                Image.asset(
                  'assets/images/icon.png',
                  height: 150,
                ),

                SizedBox(height: 50),
                //welcome back, you've been missed
                Text(
                  'Welcome back, you\'ve been missed',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6F45EF),
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 25),
                // username textfield
                LoginRegisTextfield(
                  controller: emailController,
                  hintText: 'Username',
                  obscureText: false,
                ),
                SizedBox(height: 10),
                //password textfield
                LoginRegisTextfield(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                SizedBox(height: 10),
                //forgot password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgetPasswordPage(),
                              ));
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color(0xFF6F45EF)),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                //sign in button
                ButtonLoginRegis(
                  text: 'Sign In',
                  onTap: signUserIn,
                ),
                SizedBox(height: 50),

                // or continue with
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Color(0xFF6F45EF)),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey,
                          thickness: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),

                // google + apple sign in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                        onTap: () => _signInWithGoogle(),
                        imagePath: 'assets/images/google.png'),
                  ],
                ),
                SizedBox(height: 30),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Not a member? '),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Register now',
                          style: TextStyle(
                              color: Color(0xFF6F45EF),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
