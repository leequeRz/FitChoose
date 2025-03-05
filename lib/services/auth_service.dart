import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  //Google Sign In
  signInWithGoogle() async {
    // สร้าง instance ของ GoogleSignIn ที่จะบังคับให้แสดงหน้าเลือกบัญชีทุกครั้ง
    final GoogleSignIn googleSignIn = GoogleSignIn(
      forceCodeForRefreshToken: true,
    );

    // ถ้ามีการ sign in อยู่แล้ว ให้ sign out ก่อน
    await googleSignIn.signOut();

    // เริ่มกระบวนการ sign in แบบ interactive
    final GoogleSignInAccount? gUser = await googleSignIn.signIn();

    // ถ้าผู้ใช้ยกเลิกการเลือกบัญชี
    if (gUser == null) {
      return null;
    }

    // ขอรายละเอียดการยืนยันตัวตนจากการร้องขอ
    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    // สร้าง credential ใหม่สำหรับผู้ใช้
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    // สุดท้าย ทำการ sign in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
