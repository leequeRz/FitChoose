import 'package:fitchoose/pages/matching/favorites_page.dart';
import 'package:fitchoose/pages/matching/matching_result.dart';
import 'package:flutter/material.dart';
import 'package:fitchoose/services/garment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MatchingPage extends StatefulWidget {
  const MatchingPage({super.key});

  @override
  State<MatchingPage> createState() => _MatchingPageState();
}

class _MatchingPageState extends State<MatchingPage> {
  final GarmentService _garmentService = GarmentService();

  // เพิ่มตัวแปรเก็บเสื้อผ้าที่เลือก
  Map<String, dynamic>? selectedUpperGarment;
  Map<String, dynamic>? selectedLowerGarment;

  // เพิ่มตัวแปรเก็บรายการเสื้อผ้า
  List<Map<String, dynamic>> upperGarments = [];
  List<Map<String, dynamic>> lowerGarments = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGarments();
  }

  // เพิ่มฟังก์ชันโหลดเสื้อผ้าจาก Wardrobe
  Future<void> _loadGarments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // ดึงข้อมูลเสื้อผ้าแต่ละประเภท
        final uppers = await _garmentService.getGarmentsByType('upper');
        final lowers = await _garmentService.getGarmentsByType('lower');

        setState(() {
          upperGarments = uppers;
          lowerGarments = lowers;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading garments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // เพิ่มฟังก์ชันเปิด dialog เลือกเสื้อผ้าส่วนบน
  Future<void> _selectUpperGarment() async {
    // เพิ่มการรีโหลดข้อมูลก่อนแสดง dialog
    await _loadGarments();

    // แสดง loading dialog ระหว่างโหลดข้อมูล
    if (isLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF9B7EBD)),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    }

    if (upperGarments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No upper garments found in your wardrobe')),
      );
      return;
    }

    // เพิ่ม print เพื่อตรวจสอบข้อมูล
    print('Upper garments count: ${upperGarments.length}');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Upper Garment'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: upperGarments.length,
            itemBuilder: (context, index) {
              final garment = upperGarments[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedUpperGarment = garment;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(
                    garment['garment_image'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  // เพิ่มฟังก์ชันเปิด dialog เลือกเสื้อผ้าส่วนล่าง
  Future<void> _selectLowerGarment() async {
    // เพิ่มการรีโหลดข้อมูลก่อนแสดง dialog
    await _loadGarments();

    // แสดง loading dialog ระหว่างโหลดข้อมูล
    if (isLoading) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF9B7EBD)),
        ),
      );
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    }

    if (lowerGarments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('No lower garments found in your wardrobe')),
      );
      return;
    }

    // เพิ่ม print เพื่อตรวจสอบข้อมูล
    print('Lower garments count: ${lowerGarments.length}');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Lower Garment'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: lowerGarments.length,
            itemBuilder: (context, index) {
              final garment = lowerGarments[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedLowerGarment = garment;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.network(
                    garment['garment_image'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and heart button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Matching +',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B1E54),
                        ),
                      ),
                      Text(
                        'Matching Your Outfits',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF9B7EBD),
                        ),
                      ),
                    ],
                  ),
                  // Heart button
                  GestureDetector(
                    onTap: () {
                      // Add navigation to favorites page here
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FavoritesPage()));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B7EBD).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFF9B7EBD),
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              // แก้ไข GestureDetector สำหรับเลือกเสื้อผ้าส่วนบน
              GestureDetector(
                onTap:
                    _selectUpperGarment, // เปลี่ยนจาก pickImage เป็น _selectUpperGarment
                child: Center(
                  child: Container(
                    width: 230,
                    height: 190,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4BEE4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: selectedUpperGarment == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Select Your',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Upper-Body',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              selectedUpperGarment!['garment_image'],
                              width: 230,
                              height: 190,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text('OR',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 24),
              // แก้ไข GestureDetector สำหรับเลือกเสื้อผ้าส่วนล่าง
              GestureDetector(
                onTap:
                    _selectLowerGarment, // เปลี่ยนจาก pickImage เป็น _selectLowerGarment
                child: Center(
                  child: Container(
                    width: 230,
                    height: 190,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4BEE4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: selectedLowerGarment == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Select Your',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Lower-Body',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              selectedLowerGarment!['garment_image'],
                              width: 230,
                              height: 190,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 60),
                  width: 200,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // ตรวจสอบว่ามีการเลือกเสื้อผ้าอย่างน้อย 1 ชิ้น
                      if (selectedUpperGarment == null &&
                          selectedLowerGarment == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please select at least one garment')),
                        );
                        return;
                      }

                      // ส่งข้อมูลเสื้อผ้าที่เลือกไปยังหน้า MatchingResult
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MatchingResult(
                            upperGarment: selectedUpperGarment,
                            lowerGarment: selectedLowerGarment,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF9B7EBD),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Matching',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
