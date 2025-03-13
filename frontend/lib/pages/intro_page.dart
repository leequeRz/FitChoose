import 'package:fitchoose/pages/auth/auth_gate.dart';
import 'package:flutter/material.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();

    // ใช้ addPostFrameCallback เพื่อให้ context ใช้งานได้แน่นอน
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted) {
          // ตรวจสอบว่า widget ยังอยู่ใน tree หรือไม่
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AuthGate()), // เปลี่ยนเป็นหน้าถัดไป
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF6F45EF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/icon.png',
            ),
            Text('FitChoose',
                style: TextStyle(
                  fontSize: 50,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                )),
          ],
        ),
      ),
    );
  }
}
