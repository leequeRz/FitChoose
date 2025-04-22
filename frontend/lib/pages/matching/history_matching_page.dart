import 'package:flutter/material.dart';
import 'package:fitchoose/services/garment_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitchoose/pages/matching/matching_result.dart';
import 'package:intl/intl.dart';

class HistoryMatchingPage extends StatefulWidget {
  const HistoryMatchingPage({Key? key}) : super(key: key);

  @override
  State<HistoryMatchingPage> createState() => _HistoryMatchingPageState();
}

class _HistoryMatchingPageState extends State<HistoryMatchingPage> {
  final GarmentService _garmentService = GarmentService();
  List<Map<String, dynamic>> matchingHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatchingHistory();
  }

  Future<void> _loadMatchingHistory() async {
    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final history = await _garmentService.getMatchingHistory(userId);
        setState(() {
          matchingHistory = history;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading matching history: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F0FF),
        elevation: 0,
        title: const Text(
          'Matching History',
          style: TextStyle(
            color: Color(0xFF3B1E54),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B1E54)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF9B7EBD)),
            )
          : matchingHistory.isEmpty
              ? const Center(
                  child: Text(
                    'No matching history found',
                    style: TextStyle(
                      color: Color(0xFF3B1E54),
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: matchingHistory.length,
                  itemBuilder: (context, index) {
                    final matching = matchingHistory[index];
                    final date = DateTime.parse(matching['matching_date']);
                    final formattedDate =
                        DateFormat('MMM d, yyyy').format(date);

                    return GestureDetector(
                      onTap: () async {
                        // แสดง loading indicator
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF9B7EBD)),
                          ),
                        );

                        try {
                          // ดึงข้อมูลเสื้อผ้าส่วนบนและส่วนล่างก่อนนำทางไปยังหน้า MatchingResult
                          Map<String, dynamic>? upperGarment;
                          Map<String, dynamic>? lowerGarment;

                          if (matching['garment_top'] != null) {
                            upperGarment = await _garmentService
                                .getGarmentById(matching['garment_top']);
                          }

                          if (matching['garment_bottom'] != null) {
                            lowerGarment = await _garmentService
                                .getGarmentById(matching['garment_bottom']);
                          }

                          // ปิด loading indicator
                          Navigator.pop(context);

                          // นำทางไปยังหน้า MatchingResult พร้อมข้อมูลที่จำเป็น
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchingResult(
                                matchingId: matching['_id'],
                                upperGarment: upperGarment,
                                lowerGarment: lowerGarment,
                                matchingDetail: matching['matching_detail'],
                                matchingResult: matching['matching_result'],
                              ),
                            ),
                          );
                        } catch (e) {
                          // ปิด loading indicator ในกรณีเกิดข้อผิดพลาด
                          Navigator.pop(context);

                          // แสดงข้อความแจ้งเตือน
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Error loading matching details: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: Card(
                        color: const Color(0xFFD4BEE4),
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    matching['matching_result'] ??
                                        'Unknown Style',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3B1E54),
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // ส่วนแสดงรูปเสื้อผ้าส่วนบน (ถ้ามี)
                                  if (matching['garment_top'] != null)
                                    FutureBuilder<Map<String, dynamic>?>(
                                      future: _garmentService.getGarmentById(
                                          matching['garment_top']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2)),
                                          );
                                        }
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              snapshot.data!['garment_image'],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.fill,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Center(
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.black)),
                                        );
                                      },
                                    ),
                                  const SizedBox(width: 12),
                                  // ส่วนแสดงรูปเสื้อผ้าส่วนล่าง (ถ้ามี)
                                  if (matching['garment_bottom'] != null)
                                    FutureBuilder<Map<String, dynamic>?>(
                                      future: _garmentService.getGarmentById(
                                          matching['garment_bottom']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            width: 80,
                                            height: 80,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        strokeWidth: 2)),
                                          );
                                        }
                                        if (snapshot.hasData &&
                                            snapshot.data != null) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              snapshot.data!['garment_image'],
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.fill,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                        return const SizedBox(
                                          width: 80,
                                          height: 80,
                                          child: Center(
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey)),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
