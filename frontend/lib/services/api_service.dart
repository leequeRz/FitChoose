import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;

class ApiService {
  // Base URL ของ API - เลือกตามสภาพแวดล้อมที่รัน
  late final String baseUrl;

  ApiService() {
    // ตรวจสอบว่ารันบนอะไร และกำหนด baseUrl ตามนั้น
    if (Platform.isAndroid) {
      // สำหรับ Android Emulator
      baseUrl = 'http://10.0.2.2:8000';
    } else if (Platform.isIOS) {
      // สำหรับ iOS Simulator
      baseUrl = 'http://localhost:8000';
    } else {
      // สำหรับ Web หรืออื่นๆ
      baseUrl = 'http://localhost:8000';
    }

    print('API Service initialized with baseUrl: $baseUrl');
  }

  // สร้างผู้ใช้ใหม่
  Future<Map<String, dynamic>> createUser({
    required String user_id,
    required String username,
    required String gender,
    String? imageUrl,
  }) async {
    try {
      print('Sending request to: $baseUrl/users/create');
      print('Request body: ${jsonEncode({
            'user_id': user_id,
            'username': username,
            'gender': gender,
            'image_url': imageUrl,
          })}');

      final response = await http.post(
        Uri.parse('$baseUrl/users/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': user_id,
          'username': username,
          'gender': gender,
          'image_url': imageUrl,
        }),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      print('Error in API call: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // ดึงข้อมูลผู้ใช้ตาม ID
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      print('Error getting user: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  // ตรวจสอบว่ามีโปรไฟล์อยู่แล้วหรือไม่
  Future<Map<String, dynamic>> checkUserExists(String firebaseUid) async {
    try {
      print('Checking if user exists: $firebaseUid');
      final response = await http.get(
        Uri.parse('$baseUrl/users/check/$firebaseUid'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Decoded data: $data');
        return data;
      } else {
        print(
            'Failed to check user: ${response.statusCode} - ${response.body}');
        return {'exists': false};
      }
    } catch (e) {
      print('Error checking user: $e');
      return {'exists': false};
    }
  }

  // เพิ่มฟังก์ชันอัปเดตข้อมูลผู้ใช้
  Future<Map<String, dynamic>> updateUser(
      String userId, Map<String, dynamic> userData) async {
    try {
      print('Updating user: $userId with data: $userData');
      final response = await http.put(
        Uri.parse('$baseUrl/users/update-by-firebase-uid/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(userData),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

// เพิ่มฟังก์ชันอัปเดตรูปภาพโปรไฟล์
  Future<Map<String, dynamic>> updateProfileImage(
      String userId, String imageUrl) async {
    try {
      print('Updating profile image for user: $userId');
      return await updateUser(userId, {'image_url': imageUrl});
    } catch (e) {
      print('Error updating profile image: $e');
      throw Exception('Failed to update profile image: $e');
    }
  }

// เพิ่มเมธอดสำหรับจัดการ garments ถ้ายังไม่มี
  Future<Map<String, dynamic>> createGarment(
      Map<String, dynamic> garmentData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/garments/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(garmentData),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create garment: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getGarmentsByType(
      String userId, String garmentType) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/garments/user/$userId/type/$garmentType'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to get garments: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<bool> deleteGarment(String garmentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/garments/$garmentId'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // แก้ไขฟังก์ชัน post - ย้ายเข้ามาในคลาส
  Future<dynamic> post(String endpoint, dynamic data) async {
    try {
      print('POST request to $endpoint with data: $data');
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to post data: ${response.body}');
      }
    } catch (e) {
      print('Error in API post: $e');
      rethrow;
    }
  }

  // เพิ่มฟังก์ชัน get สำหรับการดึงข้อมูล
  Future<dynamic> get(String endpoint) async {
    try {
      print('GET request to $endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get data: ${response.body}');
      }
    } catch (e) {
      print('Error in API get: $e');
      rethrow;
    }
  }
}
