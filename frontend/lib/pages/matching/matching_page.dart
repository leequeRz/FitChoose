import 'package:fitchoose/pages/matching/favorites_page.dart';
import 'package:fitchoose/pages/matching/history_matching_page.dart';
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

  // เพิ่มฟังก์ชัน dispose เพื่อล้างค่าเมื่อออกจากหน้า
  @override
  void dispose() {
    // ล้างค่าตัวแปรเมื่อออกจากหน้า
    selectedUpperGarment = null;
    selectedLowerGarment = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // รีเซ็ตการเลือกเสื้อผ้าเมื่อหน้าถูกแสดงอีกครั้ง
    _resetSelection();
  }

  // เพิ่มฟังก์ชันรีเซ็ตการเลือกเสื้อผ้า
  void _resetSelection() {
    setState(() {
      selectedUpperGarment = null;
      selectedLowerGarment = null;
    });
  }

  // เพิ่มฟังก์ชันโหลดเสื้อผ้าจาก Wardrobe
  Future<void> _loadGarments() async {
    setState(() {
      isLoading = true;
      // รีเซ็ตการเลือกเสื้อผ้าเมื่อโหลดข้อมูลใหม่
      selectedUpperGarment = null;
      selectedLowerGarment = null;
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
        title: const Text(
          'Select Upper Garment',
          style:
              TextStyle(color: Color(0xFF9B7EBD), fontWeight: FontWeight.bold),
        ),
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
                    border: Border.all(
                        color: Color(0xFF9B7EBD),
                        width: 2), // เปลี่ยนสีขอบเป็นสีม่วง
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
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
        title: const Text(
          'Select Lower Garment',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9B7EBD)),
        ),
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
                    border: Border.all(
                        color: const Color(0xFF9B7EBD),
                        width: 2), // เปลี่ยนสีขอบเป็นสีม่วง
                    borderRadius: BorderRadius.circular(12), // เพิ่มขอบมน
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      garment['garment_image'] ?? '',
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
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
          // ลดขนาด padding ด้านข้างลงเพื่อแก้ปัญหา overflow ด้านขวา
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with title and buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ลดขนาดตัวอักษรของหัวข้อลงเล็กน้อย
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Matching +',
                          style: TextStyle(
                            fontSize: 32, // ลดจาก 32
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B1E54),
                          ),
                        ),
                        Text(
                          'Matching Your Outfits',
                          style: TextStyle(
                            fontSize: 18, // ลดจาก 18
                            color: Color(0xFF9B7EBD),
                          ),
                        ),
                      ],
                    ),
                    // ปรับขนาดและระยะห่างของปุ่ม
                    Row(
                      children: [
                        // Reset button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedUpperGarment = null;
                              selectedLowerGarment = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Selection reset successfully'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6), // ลดจาก 8
                            margin: const EdgeInsets.only(right: 8), // ลดจาก 12
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B7EBD).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.refresh_rounded,
                              color: Color(0xFF9B7EBD),
                              size: 24, // ลดจาก 28
                            ),
                          ),
                        ),
                        // History button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HistoryMatchingPage(),
                              ),
                            ).then((_) {
                              _resetSelection();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6), // ลดจาก 8
                            margin: const EdgeInsets.only(right: 8), // ลดจาก 12
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B7EBD).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.history_rounded,
                              color: Color(0xFF9B7EBD),
                              size: 24, // ลดจาก 28
                            ),
                          ),
                        ),
                        // Heart button
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FavoritesPage()),
                            ).then((_) {
                              _resetSelection();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6), // ลดจาก 8
                            decoration: BoxDecoration(
                              color: const Color(0xFF9B7EBD).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFF9B7EBD),
                              size: 24, // ลดจาก 28
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // แก้ไข GestureDetector สำหรับเลือกเสื้อผ้าส่วนบน
                GestureDetector(
                  onTap: _selectUpperGarment,
                  child: Center(
                    child: Container(
                      width: 230,
                      // ลดความสูงลงเล็กน้อย
                      height: 170,
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
                                height: 170,
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
                const SizedBox(height: 16), // ลดระยะห่างลง
                const Center(
                  child: Text('OR',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16), // ลดระยะห่างลง
                // แก้ไข GestureDetector สำหรับเลือกเสื้อผ้าส่วนล่าง
                GestureDetector(
                  onTap: _selectLowerGarment,
                  child: Center(
                    child: Container(
                      width: 230,
                      // ลดความสูงลงเล็กน้อย
                      height: 170,
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
                                height: 170,
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
                // ลดระยะห่างด้านบนของปุ่ม Matching
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 30, bottom: 20), // เพิ่ม margin ด้านล่าง
                    width: 200,
                    height: 50, // ลดความสูงของปุ่ม
                    child: ElevatedButton(
                      onPressed: () async {
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

                        // บันทึกประวัติการทำ matching
                        try {
                          final userId = FirebaseAuth.instance.currentUser?.uid;
                          if (userId != null) {
                            // แสดง loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF9B7EBD)),
                              ),
                            );

                            // สร้างข้อมูล matching
                            final matchingData = {
                              'user_id': userId,
                              'garment_top': selectedUpperGarment?['_id'],
                              'garment_bottom': selectedLowerGarment?['_id'],
                              'matching_result':
                                  'Vintage Style', // ตัวอย่างผลลัพธ์
                              'matching_detail':
                                  'Bringing back or reinterpreting past fashion styles, such as flared jeans that were popular in the 60s and have become trendy again in the present day.',
                              'matching_date': DateTime.now().toIso8601String(),
                              'is_favorite': false,
                            };

                            print('Sending matching data: $matchingData');

                            // บันทึกข้อมูล matching
                            final response = await _garmentService
                                .saveMatching(matchingData);

                            // ปิด loading indicator
                            Navigator.pop(context);

                            print('Received response: $response');

                            // ตรวจสอบและดึง matchingId จาก response
                            String? matchingId;
                            if (response != null) {
                              if (response is Map<String, dynamic>) {
                                // ถ้า response เป็น Map และมี key 'matching_id'
                                if (response.containsKey('matching_id')) {
                                  matchingId = response['matching_id'];
                                }
                                // ถ้า response เป็น Map และมี key '_id'
                                else if (response.containsKey('_id')) {
                                  matchingId = response['_id'];
                                }
                                // ถ้า response เป็น Map และมี key 'data' ที่มี '_id'
                                else if (response.containsKey('data') &&
                                    response['data'] is Map &&
                                    response['data'].containsKey('_id')) {
                                  matchingId = response['data']['_id'];
                                }

                                print('Extracted Matching ID: $matchingId');

                                if (matchingId != null) {
                                  // ส่งข้อมูลเสื้อผ้าที่เลือกไปยังหน้า MatchingResult
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MatchingResult(
                                        upperGarment: selectedUpperGarment,
                                        lowerGarment: selectedLowerGarment,
                                        matchingId: matchingId,
                                      ),
                                    ),
                                  ).then((_) {
                                    // เมื่อกลับมาจากหน้า MatchingResult ให้รีเซ็ตการเลือกเสื้อผ้า
                                    setState(() {
                                      selectedUpperGarment = null;
                                      selectedLowerGarment = null;
                                    });
                                  });
                                } else {
                                  // กรณีไม่สามารถดึง matchingId ได้
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Failed to get matching ID'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else {
                                // กรณีไม่ได้รับ response
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Failed to save matching data'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            } else {
                              // กรณีไม่ได้ล็อกอิน
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please login to use matching feature'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            // กรณีไม่ได้ล็อกอิน
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please login to use matching feature'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          print('Error saving matching history: $e');
                          // ปิด loading indicator ถ้ายังแสดงอยู่
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);

                          // แสดงข้อความแจ้งเตือน
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              duration: const Duration(seconds: 2),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B7EBD),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 12, // ลดระยะห่างแนวตั้ง
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
      ),
    );
  }
}
