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
}
