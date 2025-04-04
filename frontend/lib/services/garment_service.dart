import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:fitchoose/services/api_service.dart';

class GarmentService {
  final ApiService _apiService = ApiService();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // อัปโหลดรูปภาพเสื้อผ้าไปยัง Firebase Storage
  Future<String?> uploadGarmentImage(File imageFile, String garmentType) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      final userId = user.uid;

      // สร้างชื่อไฟล์ที่ไม่ซ้ำกัน
      final fileName =
          'garment_${userId}_${garmentType}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // กำหนด path ใน Firebase Storage
      final storageRef = _storage.ref().child('garment_images/$fileName');

      // อัปโหลดไฟล์
      final uploadTask = storageRef.putFile(imageFile);

      // รอจนกว่าการอัปโหลดจะเสร็จสิ้น
      final snapshot = await uploadTask;

      // รับ URL ของรูปภาพ
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('Garment image uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading garment image: $e');
      return null;
    }
  }

  // เพิ่มเสื้อผ้าใหม่ลงใน MongoDB
  Future<bool> addGarment({
    required String garmentType,
    required String garmentImage,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;

      final userId = user.uid;
      final baseUrl = _apiService.baseUrl;

      final response = await http.post(
        Uri.parse('$baseUrl/garments/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'garment_type': garmentType,
          'garment_image': garmentImage,
          'created_at': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding garment: $e');
      return false;
    }
  }

  // ดึงข้อมูลเสื้อผ้าตามประเภท
  Future<List<Map<String, dynamic>>> getGarmentsByType(
      String garmentType) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return [];

      final userId = user.uid;
      final baseUrl = _apiService.baseUrl;

      final response = await http.get(
        Uri.parse('$baseUrl/garments/user/$userId/type/$garmentType'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting garments: $e');
      return [];
    }
  }

  // ลบเสื้อผ้า
  Future<bool> deleteGarment(String garmentId, String imageUrl) async {
    try {
      final baseUrl = _apiService.baseUrl;

      // ลบข้อมูลจาก MongoDB
      final response = await http.delete(
        Uri.parse('$baseUrl/garments/$garmentId'),
      );

      if (response.statusCode == 200) {
        // ลบรูปภาพจาก Firebase Storage
        if (imageUrl.isNotEmpty) {
          try {
            final ref = _storage.refFromURL(imageUrl);
            await ref.delete();
          } catch (e) {
            print('Error deleting garment image: $e');
          }
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error deleting garment: $e');
      return false;
    }
  }

  // นับจำนวนเสื้อผ้าในแต่ละประเภท
  Future<int> countGarmentsByType(String garmentType) async {
    final garments = await getGarmentsByType(garmentType);
    return garments.length;
  }
}
