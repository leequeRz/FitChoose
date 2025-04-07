import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitchoose/components/loginregis/button_login_regis.dart';
import 'package:fitchoose/components/loginregis/login_regis_textfield.dart';
import 'package:fitchoose/components/loginregis/square_tile.dart';
import 'package:fitchoose/pages/create_profile.dart'; // เพิ่ม import สำหรับหน้า create_profile
import 'package:fitchoose/services/auth_service.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // sign user up method
  void signUserUp() async {
    //show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    //try creating the user
    try {
      //check if password is confirmed
      if (passwordController.text == confirmPasswordController.text) {
        // สร้างผู้ใช้ใหม่
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // ปิด loading dialog
        Navigator.pop(context);

        // ถ้าสร้างผู้ใช้สำเร็จ ให้นำทางไปยังหน้า create_profile
        if (userCredential.user != null) {
          // นำทางไปยังหน้า create_profile
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreateProfile(
                userId: userCredential.user!.uid,
                isNewUser: true,
              ),
            ),
          );
        }
      } else {
        // ปิด loading dialog
        Navigator.pop(context);
        showErrorSnackBar('Passwords don\'t match');
      }
    } on FirebaseAuthException catch (e) {
      //pop the loading circle
      Navigator.pop(context);
      print("Firebase Error Code: ${e.code}"); // ดู error code ที่แท้จริง

      // ใช้ switch case แทนเพื่อครอบคลุม error code ที่เป็นไปได้ทั้งหมด
      switch (e.code) {
        case 'email-already-in-use':
          showErrorSnackBar('Email already in use');
          break;
        case 'weak-password':
          showErrorSnackBar('Password is too weak');
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
              'Registration Failed. Please check your Email or Password and try again.');
          break;
      }
    } catch (e) {
      Navigator.pop(context);
      print("General Error: $e");
      showErrorSnackBar('An error occurred. Please try again.');
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
                //Let's create an account for you!
                Text(
                  'Let\'s create an account for you!',
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

                //confirm password textfield
                LoginRegisTextfield(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                SizedBox(height: 25),

                //sign in button
                ButtonLoginRegis(
                  text: 'Sign Up',
                  onTap: signUserUp,
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
                        onTap: () => AuthService().signInWithGoogle(),
                        imagePath: 'assets/images/google.png'),
                  ],
                ),
                SizedBox(height: 30),

                //not a member? register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?'),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: const Text('Login Now',
                          style: TextStyle(
                              color: Color(0xFF6F45EF),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
