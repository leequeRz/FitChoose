import 'package:flutter/material.dart';
import 'package:fitchoose/services/garment_service.dart';
import 'package:intl/intl.dart';
import 'package:fitchoose/pages/matching/matching_result.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final GarmentService _garmentService = GarmentService();
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    try {
      final favoritesList = await _garmentService.getFavorites();
      setState(() {
        favorites = favoritesList;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
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
          'Favorites',
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
          : favorites.isEmpty
              ? const Center(
                  child: Text(
                    'No favorites found',
                    style: TextStyle(
                      color: Color(0xFF3B1E54),
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final matching = favorites[index];
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      matching['matching_detail'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.favorite,
                                        color: Colors.red),
                                    onPressed: () async {
                                      // ลบออกจาก favorites
                                      final success = await _garmentService
                                          .removeFromFavorites(matching['_id']);
                                      if (success) {
                                        setState(() {
                                          favorites.removeAt(index);
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Removed from favorites'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
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
