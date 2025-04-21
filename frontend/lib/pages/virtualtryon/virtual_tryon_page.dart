import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:fitchoose/services/garment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VirtualTryOnPage extends StatefulWidget {
  const VirtualTryOnPage({super.key});

  @override
  _VirtualTryOnPageState createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage>
    with WidgetsBindingObserver {
  String selectedCategory = 'Upper-Body';
  bool isLoading = true;
  final GarmentService _garmentService = GarmentService();

  // เปลี่ยนโครงสร้างข้อมูลเพื่อรองรับข้อมูลจาก API
  final Map<String, List<Map<String, dynamic>>> clothingItems = {
    'Upper-Body': [],
    'Lower-Body': [],
    'Dress': [],
  };

  File? _image;

  @override
  void initState() {
    super.initState();
    // เพิ่ม observer เพื่อตรวจจับเมื่อแอปกลับมาที่หน้านี้
    WidgetsBinding.instance.addObserver(this);
    _loadGarments();
  }

  @override
  void dispose() {
    // ลบ observer เมื่อออกจากหน้านี้
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // เพิ่มฟังก์ชันเพื่อตรวจจับเมื่อแอปกลับมาที่หน้านี้
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // รีโหลดข้อมูลเมื่อแอปกลับมาทำงาน
      _loadGarments();
    }
  }

  // เพิ่มฟังก์ชันสำหรับโหลดข้อมูลเสื้อผ้า
  Future<void> _loadGarments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // ดึงข้อมูลเสื้อผ้าแต่ละประเภท
        final upperGarments = await _garmentService.getGarmentsByType('upper');
        final lowerGarments = await _garmentService.getGarmentsByType('lower');
        final dressGarments = await _garmentService.getGarmentsByType('dress');

        // ตรวจสอบว่าหน้านี้ยังคงอยู่ในสแต็ค (ป้องกันการเรียก setState หลังจาก dispose)
        if (mounted) {
          setState(() {
            clothingItems['Upper-Body'] = upperGarments;
            clothingItems['Lower-Body'] = lowerGarments;
            clothingItems['Dress'] = dressGarments;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading garments: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // เพิ่มปุ่มหรือฟังก์ชันสำหรับอัปโหลดรูปภาพไปยัง Wardrobe ที่นี่
      // หลังจากอัปโหลดเสร็จ ให้เรียก _loadGarments() เพื่อรีโหลดข้อมูล
    }
  }

  // เพิ่มฟังก์ชันเพื่อรีเฟรชข้อมูลเมื่อกดปุ่ม
  Future<void> _refreshData() async {
    await _loadGarments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF), // Light purple background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          // เพิ่ม SingleChildScrollView เพื่อให้สามารถเลื่อนได้เมื่อเนื้อหาเกินขนาดหน้าจอ
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Virtual Try-on',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B1E54), // Deep purple
                          ),
                        ),
                        Text(
                          'Customize your outfit effortlessly',
                          style: TextStyle(
                            fontSize: 18,
                            color: Color(0xFF9B7EBD), // Medium purple
                          ),
                        ),
                      ],
                    ),
                    // เพิ่มปุ่มรีเฟรช
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF9B7EBD)),
                      onPressed: _refreshData,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: pickImage,
                  child: Center(
                    child: Container(
                      width: 260,
                      // ลดความสูงลงเล็กน้อย
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: _image == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_outlined,
                                  size: 60,
                                  color: Color(0xFF9B7EBD),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Upload Your Picture',
                                  style: TextStyle(
                                    color: Color(0xFF9B7EBD),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                _image!,
                                width: 260,
                                height: 300,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (String category in [
                        'Upper-Body',
                        'Lower-Body',
                        'Dress'
                      ])
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: CategoryButton(
                            text: category,
                            isSelected: selectedCategory == category,
                            onTap: () {
                              setState(() {
                                selectedCategory = category;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // เปล่าจาก Container ที่มี GridView เป็น Column ที่มี Text และ ListView แนวนอน
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCategory,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B1E54),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 180, // ปรับความสูงตามความเหมาะสม
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF9B7EBD)))
                          : clothingItems[selectedCategory]!.isEmpty
                              ? Center(
                                  child: Text(
                                    'No ${selectedCategory} items found',
                                    style: TextStyle(
                                      color: Color(0xFF9B7EBD),
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      clothingItems[selectedCategory]?.length ??
                                          0,
                                  itemBuilder: (context, index) {
                                    final garment =
                                        clothingItems[selectedCategory]![index];
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 16.0),
                                      child: ClothingItemCard(
                                        imageUrl: garment['garment_image'],
                                        width:
                                            150, // กำหนดความกว้างของแต่ละรายการ
                                        height:
                                            180, // กำหนดความสูงของแต่ละรายการ
                                      ),
                                    );
                                  },
                                ),
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

// Category Button Widget
class CategoryButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE6D8F5) : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color:
                isSelected ? const Color(0xFF9B7EBD) : const Color(0xFFCBB6E5),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// Clothing Item Card Widget - ปรับเพื่อรองรับ URL แทน asset path และเพิ่มพารามิเตอร์ width, height
class ClothingItemCard extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onDeleteTap;
  final double width;
  final double height;

  const ClothingItemCard({
    Key? key,
    required this.imageUrl,
    this.onDeleteTap,
    this.width = double.infinity,
    this.height = double.infinity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F1FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAE2F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
