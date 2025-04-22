import 'package:flutter/material.dart';
import 'package:fitchoose/services/garment_service.dart';

class WardropeDress extends StatefulWidget {
  const WardropeDress({super.key});

  @override
  State<WardropeDress> createState() => _WardropeDressState();
}

class _WardropeDressState extends State<WardropeDress> {
  final GarmentService _garmentService = GarmentService();
  bool isLoading = true;
  List<Map<String, dynamic>> garments = [];
  bool isDeleteMode = false;
  Set<String> selectedGarments = {};

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
      final items = await _garmentService.getGarmentsByType('dress');
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

  Future<void> _deleteSelectedGarments() async {
    if (selectedGarments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items selected')),
      );
      return;
    }

    // Show confirmation dialog
    bool confirmDelete = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: Text(
                  'Are you sure you want to delete ${selectedGarments.length} selected item(s)?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmDelete) {
      return;
    }

    try {
      bool allSuccess = true;
      for (String garmentId in selectedGarments) {
        final garment = garments.firstWhere((g) => g['_id'] == garmentId);
        final success = await _garmentService.deleteGarment(
            garmentId, garment['garment_image'] ?? '');
        if (!success) {
          allSuccess = false;
        }
      }

      if (allSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('All selected garments deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Some garments could not be deleted')),
        );
      }

      // Reset selection and reload
      setState(() {
        selectedGarments.clear();
        isDeleteMode = false;
      });
      _loadGarments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _toggleDeleteMode() {
    setState(() {
      isDeleteMode = !isDeleteMode;
      if (!isDeleteMode) {
        selectedGarments.clear();
      }
    });
  }

  void _toggleGarmentSelection(String garmentId) {
    setState(() {
      if (selectedGarments.contains(garmentId)) {
        selectedGarments.remove(garmentId);
      } else {
        selectedGarments.add(garmentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dress'),
        backgroundColor: const Color(0xFFF5F0FF),
        actions: [
          // เพิ่มปุ่มลบที่มุมขวาบน
          IconButton(
            icon: Icon(isDeleteMode ? Icons.close : Icons.delete_outline),
            onPressed: _toggleDeleteMode,
          ),
          if (isDeleteMode)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _deleteSelectedGarments,
            ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F0FF),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : garments.isEmpty
              ? const Center(
                  child: Text(
                    'No Dress items found',
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
                    final garmentId = garment['_id'] ?? '';
                    final isSelected = selectedGarments.contains(garmentId);

                    return GestureDetector(
                      onTap: isDeleteMode
                          ? () => _toggleGarmentSelection(garmentId)
                          : null,
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: double.infinity,
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
                              border: isDeleteMode && isSelected
                                  ? Border.all(color: Colors.red, width: 3)
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                garment['garment_image'] ?? '',
                                fit: BoxFit.fill,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
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
                          if (isDeleteMode && isSelected)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
