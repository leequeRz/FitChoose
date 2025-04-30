import 'package:flutter/material.dart';
import 'package:fitchoose/pages/wardrope/wardrope_dress.dart';
import 'package:fitchoose/pages/wardrope/wardrope_lower.dart';
import 'package:fitchoose/pages/wardrope/wardrope_upper.dart';
import 'package:fitchoose/services/garment_service.dart';
import 'package:fitchoose/services/api_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fitchoose/widgets/profile_picture_guide_popup.dart';

class WardropePage extends StatefulWidget {
  const WardropePage({super.key});

  @override
  State<WardropePage> createState() => _WardropePageState();
}

class _WardropePageState extends State<WardropePage> {
  final GarmentService _garmentService = GarmentService();
  final ApiService _apiService = ApiService();
  // final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  // จำนวนเสื้อผ้าในแต่ละหมวดหมู่
  int upperCount = 0;
  int lowerCount = 0;
  int dressCount = 0;

  @override
  void initState() {
    super.initState();
    _loadGarmentCounts();
    // แสดง popup หลังจากที่ widget ถูกสร้างเสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showProfilePictureGuide();
    });
  }

// เพิ่มฟังก์ชันสำหรับแสดง popup
  void _showProfilePictureGuide() {
    showDialog(
      context: context,
      barrierDismissible: true, // อนุญาตให้ปิดโดยการแตะพื้นหลัง
      builder: (BuildContext context) {
        return ProfilePictureGuidePopup(
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  // โหลดจำนวนเสื้อผ้าในแต่ละหมวดหมู่
  Future<void> _loadGarmentCounts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final upperItems = await _garmentService.countGarmentsByType('upper');
      final lowerItems = await _garmentService.countGarmentsByType('lower');
      final dressItems = await _garmentService.countGarmentsByType('dress');

      setState(() {
        upperCount = upperItems;
        lowerCount = lowerItems;
        dressCount = dressItems;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading garment counts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // แสดงกล่องโต้ตอบเพื่อเลือกประเภทเสื้อผ้า
  Future<String?> _showGarmentTypeDialog() async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Garment Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.accessibility_new),
                title: const Text('Upper-Body'),
                onTap: () => Navigator.pop(context, 'upper'),
              ),
              ListTile(
                leading: const Icon(Icons.accessibility),
                title: const Text('Lower-Body'),
                onTap: () => Navigator.pop(context, 'lower'),
              ),
              ListTile(
                leading: const Icon(Icons.accessibility_outlined),
                title: const Text('Dress'),
                onTap: () => Navigator.pop(context, 'dress'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ถ่ายภาพและอัปโหลด
  Future<void> _takePhoto() async {
    setState(() {
      isLoading = true;
    });

    try {
      // ใช้ฟังก์ชันใหม่จาก GarmentService โดยไม่ต้องระบุประเภทเสื้อผ้า
      // โมเดลจะตรวจจับประเภทเสื้อผ้าเอง
      final imageFile = await _garmentService.captureGarmentImage();
      if (imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่ได้ถ่ายรูป')),
        );
        return;
      }

      // อัปโหลดรูปภาพและให้โมเดลตรวจจับประเภทเสื้อผ้า
      await _processAndUploadImage(imageFile);
    } catch (e) {
      print('เกิดข้อผิดพลาดในการถ่ายรูป: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // เลือกรูปภาพและอัปโหลด
  Future<void> _uploadPhoto() async {
    setState(() {
      isLoading = true;
    });

    try {
      // ใช้ฟังก์ชันใหม่จาก GarmentService โดยไม่ต้องระบุประเภทเสื้อผ้า
      final imageFile = await _garmentService.pickGarmentImageFromGallery();
      if (imageFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่ได้เลือกรูปภาพ')),
        );
        return;
      }

      // อัปโหลดรูปภาพและให้โมเดลตรวจจับประเภทเสื้อผ้า
      await _processAndUploadImage(imageFile);
    } catch (e) {
      print('เกิดข้อผิดพลาดในการอัปโหลดรูปภาพ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // ฟังก์ชันใหม่สำหรับประมวลผลและอัปโหลดรูปภาพ
  Future<void> _processAndUploadImage(File imageFile) async {
    try {
      // อัปโหลดรูปภาพไปยัง Firebase Storage
      final imageUrl =
          await _garmentService.uploadGarmentImage(imageFile, "auto");
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถอัปโหลดรูปภาพได้')),
        );
        return;
      }

      // ส่งรูปภาพไปให้ YOLO ตรวจจับประเภทเสื้อผ้า
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อน')),
        );
        return;
      }

      // เรียกใช้ API YOLO เพื่อตรวจจับประเภทเสื้อผ้า
      final yoloResult = await _apiService.processImageWithYOLO(imageUrl);

      if (yoloResult != null &&
          yoloResult['detections'] != null &&
          yoloResult['detections'].isNotEmpty) {
        // ดึงประเภทเสื้อผ้าจากผลลัพธ์ YOLO
        final detections = yoloResult['detections'] as List;
        String garmentType = "upper"; // ค่าเริ่มต้น

        // ตรวจสอบประเภทเสื้อผ้าจากผลลัพธ์ YOLO
        for (var detection in detections) {
          final className = detection['class'].toString().toLowerCase();
          if (className.contains('dress')) {
            garmentType = "dress";
            break;
          } else if (className.contains('lower') ||
              className.contains('pants') ||
              className.contains('skirt')) {
            garmentType = "lower";
            break;
          } else if (className.contains('upper') ||
              className.contains('shirt') ||
              className.contains('top')) {
            garmentType = "upper";
            break;
          }
        }

        // เพิ่มข้อมูลเสื้อผ้าลงในฐานข้อมูล
        final success = await _garmentService.addGarment(
          garmentType: garmentType,
          garmentImage: imageUrl,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('เพิ่มเสื้อผ้าประเภท $garmentType สำเร็จ')),
          );

          // โหลดจำนวนเสื้อผ้าใหม่
          await _loadGarmentCounts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่สามารถบันทึกข้อมูลเสื้อผ้าได้')),
          );
        }
      } else {
        // ถ้าไม่สามารถตรวจจับประเภทเสื้อผ้าได้ ให้แสดง dialog ให้ผู้ใช้เลือกเอง
        final garmentType = await _showGarmentTypeDialog();
        if (garmentType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่ได้เลือกประเภทเสื้อผ้า')),
          );
          return;
        }

        // เพิ่มข้อมูลเสื้อผ้าลงในฐานข้อมูล
        final success = await _garmentService.addGarment(
          garmentType: garmentType,
          garmentImage: imageUrl,
        );

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('เพิ่มเสื้อผ้าสำเร็จ')),
          );

          // โหลดจำนวนเสื้อผ้าใหม่
          await _loadGarmentCounts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่สามารถบันทึกข้อมูลเสื้อผ้าได้')),
          );
        }
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดในการประมวลผลรูปภาพ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
      );
    }
  }
  // อัปโหลดรูปภาพไปยัง Firebase Storage และบันทึกข้อมูลใน MongoDB
  // Future<void> _uploadImage(File imageFile, String garmentType) async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     // อัปโหลดรูปภาพไปยัง Firebase Storage
  //     final imageUrl =
  //         await _garmentService.uploadGarmentImage(imageFile, garmentType);

  //     if (imageUrl != null) {
  //       // บันทึกข้อมูลใน MongoDB
  //       final success = await _garmentService.addGarment(
  //         garmentType: garmentType,
  //         garmentImage: imageUrl,
  //       );

  //       if (success) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Garment added successfully')),
  //         );

  //         // โหลดจำนวนเสื้อผ้าใหม่
  //         await _loadGarmentCounts();
  //       } else {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Failed to add garment')),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Failed to upload image')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Error uploading image: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}')),
  //     );
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF), // Light purple background
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Wardrobe',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B1E54), // Deep purple
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Outfits',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF9B7EBD), // Medium purple
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showProfilePictureGuide();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B7EBD),
                          ),
                          child: Text(
                            'Picture Guide',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildCategoryCard(
                            context: context,
                            destination: const WardropeUpper(),
                            icon: Icons.accessibility_new,
                            title: 'Upper-Body',
                            itemCount: upperCount,
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryCard(
                            context: context,
                            destination: const WardropeLower(),
                            icon: Icons.accessibility,
                            title: 'Lower-Body',
                            itemCount: lowerCount,
                          ),
                          const SizedBox(height: 16),
                          _buildCategoryCard(
                            context: context,
                            destination: const WardropeDress(),
                            icon: Icons.accessibility_outlined,
                            title: 'Dress',
                            itemCount: dressCount,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.camera_alt,
                            label: 'Take a Photo',
                            isPrimary: true,
                            onTap: _takePhoto,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.upload,
                            label: 'Upload Photo',
                            isPrimary: false,
                            onTap: _uploadPhoto,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required Widget destination,
    required IconData icon,
    required String title,
    required int itemCount,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        ).then((_) => _loadGarmentCounts()); // โหลดข้อมูลใหม่เมื่อกลับมา
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFF3B1E54),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B1E54),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$itemCount items',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF9B7EBD),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isPrimary ? const Color(0xFF9B7EBD) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : const Color(0xFF9B7EBD),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : const Color(0xFF9B7EBD),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
