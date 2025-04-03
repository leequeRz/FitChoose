import 'package:flutter/material.dart';
import 'package:fitchoose/services/garment_service.dart';

class WardropeLower extends StatefulWidget {
  const WardropeLower({super.key});

  @override
  State<WardropeLower> createState() => _WardropeLowerState();
}

class _WardropeLowerState extends State<WardropeLower> {
  final GarmentService _garmentService = GarmentService();
  bool isLoading = true;
  List<Map<String, dynamic>> garments = [];

  @override
  void initState() {
    super.initState();
    _loadGarments();
  }

  Future<void> _loadGarments() async {
    setState(() {
      isLoading = true;
    });

    try {
      final items = await _garmentService.getGarmentsByType('lower');
      setState(() {
        garments = items;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading garments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteGarment(String garmentId, String imageUrl) async {
    try {
      final success = await _garmentService.deleteGarment(garmentId, imageUrl);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Garment deleted successfully')),
        );
        _loadGarments(); // โหลดข้อมูลใหม่
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete garment')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lower-Body'),
        backgroundColor: const Color(0xFFEBEAFF),
      ),
      backgroundColor: const Color(0xFFF5F0FF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : garments.isEmpty
              ? const Center(
                  child: Text(
                    'No Lower-Body items found',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: garments.length,
                  itemBuilder: (context, index) {
                    final garment = garments[index];
                    return GestureDetector(
                      onLongPress: () {
                        _showDeleteDialog(
                          garment['_id'] ?? '',
                          garment['garment_image'] ?? '',
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            garment['garment_image'] ?? '',
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Future<void> _showDeleteDialog(String garmentId, String imageUrl) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Garment'),
          content: const Text('Are you sure you want to delete this garment?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteGarment(garmentId, imageUrl);
              },
            ),
          ],
        );
      },
    );
  }
}
