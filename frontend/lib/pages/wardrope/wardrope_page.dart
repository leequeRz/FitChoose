import 'package:fitchoose/widgets/wardrobe_picture_guide_popup.dart';
import 'package:flutter/material.dart';
import 'package:fitchoose/pages/wardrope/wardrope_dress.dart';
import 'package:fitchoose/pages/wardrope/wardrope_lower.dart';
import 'package:fitchoose/pages/wardrope/wardrope_upper.dart';
import 'package:fitchoose/services/garment_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:fitchoose/widgets/app_guide_popup.dart';

class WardropePage extends StatefulWidget {
  const WardropePage({super.key});

  @override
  State<WardropePage> createState() => _WardropePageState();
}

class _WardropePageState extends State<WardropePage> {
  final GarmentService _garmentService = GarmentService();
  final ImagePicker _picker = ImagePicker();
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
      // _showWardrobePictureGuide();
      _showAppGuide();
    });
  }

  // เพิ่มฟังก์ชันสำหรับแสดง App Guide popup
  void _showAppGuide() {
    showDialog(
      context: context,
      barrierDismissible: true, // อนุญาตให้ปิดโดยการแตะพื้นหลัง
      builder: (BuildContext context) {
        return AppGuidePopup(
          onClose: () {
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

// เพิ่มฟังก์ชันสำหรับแสดง popup
  void _showWardrobePictureGuide() {
    showDialog(
      context: context,
      barrierDismissible: true, // อนุญาตให้ปิดโดยการแตะพื้นหลัง
      builder: (BuildContext context) {
        return WardrobePictureGuidePopup(
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

// ถ่ายภาพและอัปโหลดโดยใช้ YOLO
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (photo != null) {
      await _processImageWithYolo(File(photo.path));
    }
  }

  // เลือกรูปภาพและอัปโหลดโดยใช้ YOLO
  Future<void> _uploadPhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (image != null) {
      await _processImageWithYolo(File(image.path));
    }
  }

  // ประมวลผลรูปภาพด้วย YOLO และบันทึกผลลัพธ์
  Future<void> _processImageWithYolo(File imageFile) async {
    setState(() {
      isLoading = true;
    });

    try {
      // แสดง dialog กำลังประมวลผล
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing image...')
            ],
          ),
        ),
      );

      // เรียกใช้ YOLO API
      final result = await _garmentService.detectGarment(imageFile);
      print('YOLO API result: $result');

      // ปิด dialog
      Navigator.of(context).pop();

      if (result['message'] == 'success' && result['detections'] != null) {
        final detections = result['detections'] as List<dynamic>;
        print('Detections: $detections');

        if (detections.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Not found image')),
          );
          return;
        }

        // บันทึกเสื้อผ้าที่ตรวจจับได้
        final savedTypes =
            await _garmentService.saveDetectedGarments(detections);
        print('Saved types: $savedTypes');

        if (savedTypes.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Image saved successfully: ${savedTypes.join(", ")}')),
          );

          // รีเฟรชหน้าจอเพื่อแสดงเสื้อผ้าใหม่
          await _loadGarmentCounts();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save clothing')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Something went wrong: ${result['message'] ?? "Unknown error"}')),
        );
      }
    } catch (e) {
      print('Error processing image with YOLO: $e');

      // ปิด dialog ถ้ายังแสดงอยู่
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
                            _showWardrobePictureGuide();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9B7EBD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Wardrobe Guide',
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
                    const SizedBox(height: 10),
                    Center(
                      child: const Text(
                        'เลือกวิธีการอัปโหลด',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B1E54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
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
