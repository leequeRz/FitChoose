import 'package:fitchoose/components/container_matchingresult.dart';
import 'package:fitchoose/components/pictureselect.dart';
import 'package:fitchoose/components/matchingresult_picturesuggest.dart';
import 'package:fitchoose/services/garment_service.dart';
import 'package:flutter/material.dart';

class MatchingResult extends StatefulWidget {
  // แก้ไขการประกาศพารามิเตอร์ให้ถูกต้อง
  final Map<String, dynamic>? upperGarment;
  final Map<String, dynamic>? lowerGarment;
  final String? matchingId; // เพิ่ม matchingId
  final String? matchingDetail;
  final String? matchingResult;

  const MatchingResult({
    super.key,
    this.upperGarment,
    this.lowerGarment,
    this.matchingId,
    this.matchingDetail,
    this.matchingResult,
  });

  @override
  State<MatchingResult> createState() => _MatchingResultState();
}

class _MatchingResultState extends State<MatchingResult> {
  bool isFavorite = false;

  // เพิ่มตัวแปรที่จำเป็น
  final GarmentService _garmentService = GarmentService();
  String matchingResult = 'Vintage Style'; // ค่าเริ่มต้น
  String matchingDetail =
      'Bringing back or reinterpreting past fashion styles, such as flared jeans that were popular in the 60s and have become trendy again in the present day.'; // ค่าเริ่มต้น
  Map<String, dynamic>? upperGarment;
  Map<String, dynamic>? lowerGarment;

  final List<String> clothingItems = [
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
    'assets/images/test.png',
  ];

  @override
  void initState() {
    super.initState();

    // กำหนดค่าเริ่มต้นจาก widget
    upperGarment = widget.upperGarment;
    lowerGarment = widget.lowerGarment;

    // ใช้ค่าที่ส่งมาถ้ามี
    if (widget.matchingResult != null) {
      matchingResult = widget.matchingResult!;
    }

    if (widget.matchingDetail != null) {
      matchingDetail = widget.matchingDetail!;
    }

    // ตรวจสอบสถานะ favorite
    _checkFavoriteStatus();

    // ถ้าไม่มีข้อมูลที่ส่งมา ให้ดึงข้อมูลจาก API
    if (widget.matchingId != null &&
        (widget.upperGarment == null ||
            widget.lowerGarment == null ||
            widget.matchingDetail == null ||
            widget.matchingResult == null)) {
      _loadMatchingDetails();
    }
  }

  // เพิ่มเมธอดสำหรับตรวจสอบสถานะ favorite
  Future<void> _checkFavoriteStatus() async {
    if (widget.matchingId != null) {
      try {
        final favorites = await _garmentService.getFavorites();
        final isFav = favorites.any((fav) => fav['_id'] == widget.matchingId);
        setState(() {
          isFavorite = isFav;
        });
      } catch (e) {
        print('Error checking favorite status: $e');
      }
    }
  }

  Future<void> _loadMatchingDetails() async {
    try {
      // ดึงข้อมูล matching จาก API
      final matchingData =
          await _garmentService.getMatchingById(widget.matchingId!);

      setState(() {
        matchingResult = matchingData['matching_result'] ?? 'Unknown Style';
        matchingDetail = matchingData['matching_detail'] ?? '';

        // ดึงข้อมูลเสื้อผ้าถ้ายังไม่มี
        if (widget.upperGarment == null &&
            matchingData['garment_top'] != null) {
          _loadUpperGarment(matchingData['garment_top']);
        }

        if (widget.lowerGarment == null &&
            matchingData['garment_bottom'] != null) {
          _loadLowerGarment(matchingData['garment_bottom']);
        }
      });
    } catch (e) {
      print('Error loading matching details: $e');
    }
  }

// เพิ่มเมธอดสำหรับโหลดข้อมูลเสื้อผ้าส่วนบน
  Future<void> _loadUpperGarment(String garmentId) async {
    try {
      final garmentData = await _garmentService.getGarmentById(garmentId);
      if (garmentData != null) {
        setState(() {
          upperGarment = garmentData;
        });
      }
    } catch (e) {
      print('Error loading upper garment: $e');
    }
  }

  // เพิ่มเมธอดสำหรับโหลดข้อมูลเสื้อผ้าส่วนล่าง
  Future<void> _loadLowerGarment(String garmentId) async {
    try {
      final garmentData = await _garmentService.getGarmentById(garmentId);
      if (garmentData != null) {
        setState(() {
          lowerGarment = garmentData;
        });
      }
    } catch (e) {
      print('Error loading lower garment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่ามีเสื้อผ้าที่เลือกหรือไม่
    String? upperImageUrl = widget.upperGarment?['garment_image'];
    String? lowerImageUrl = widget.lowerGarment?['garment_image'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text(
          'Matching +',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B1E54),
          ),
        ),
        backgroundColor: const Color(0xFFF5F0FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Matching Result',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF9B7EBD),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 36),
                  // แสดงรูปเสื้อผ้าที่เลือก
                  if (upperImageUrl != null)
                    Center(
                      child: PictureSelect(
                        imageUrl: upperImageUrl,
                        width: 160,
                        height: 160,
                      ),
                    ),
                  if (lowerImageUrl != null)
                    Center(
                      child: PictureSelect(
                        imageUrl: lowerImageUrl,
                        width: 160,
                        height: 160,
                      ),
                    ),
                  // ถ้าไม่มีรูปเสื้อผ้าที่เลือก ให้แสดงรูปเดิม
                  if (upperImageUrl == null && lowerImageUrl == null)
                    Center(
                      child: PictureSelect(
                        imageUrl: 'assets/images/test.png',
                        width: 160,
                        height: 160,
                      ),
                    ),
                  SizedBox(height: 36),
                  StyleDescriptionCard(
                    title: matchingResult,
                    description: matchingDetail,
                    isFavorite: isFavorite,
                    onFavoriteTap: () async {
                      if (widget.matchingId != null) {
                        bool success;
                        if (isFavorite) {
                          success = await _garmentService
                              .removeFromFavorites(widget.matchingId!);
                        } else {
                          success = await _garmentService
                              .addToFavorites(widget.matchingId!);
                        }

                        if (success) {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 24),
                  MatchingPictureSuggest(
                      title: 'Matching Outfits',
                      imageUrls: [
                        'assets/images/test.png',
                        'assets/images/test.png'
                      ],
                      onItemTap: (index) {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
