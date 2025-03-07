import 'package:flutter/material.dart';
import 'package:fitchoose/pages/wardrope/wardrope_dress.dart';
import 'package:fitchoose/pages/wardrope/wardrope_lower.dart';
import 'package:fitchoose/pages/wardrope/wardrope_upper.dart';

class WardropePage extends StatelessWidget {
  const WardropePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF), // Light purple background
      body: SafeArea(
        child: Padding(
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
              const Text(
                'Your Outfits',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF9B7EBD), // Medium purple
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _buildCategoryCard(
                      context: context,
                      destination: const WardropeUpper(),
                      icon: Icons.accessibility_new,
                      title: 'Upper-Body',
                      itemCount: 6,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryCard(
                      context: context,
                      destination: const WardropeLower(),
                      icon: Icons.accessibility,
                      title: 'Lower-Body',
                      itemCount: 6,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryCard(
                      context: context,
                      destination: const WardropeDress(),
                      icon: Icons.accessibility_outlined,
                      title: 'Dress',
                      itemCount: 6,
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
                      onTap: () {
                        // Handle camera action
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.upload,
                      label: 'Upload Photo',
                      isPrimary: false,
                      onTap: () {
                        // Handle upload action
                      },
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
        );
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
