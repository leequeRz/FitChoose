import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FavoritesCard extends StatelessWidget {
  final String upperImagePath;
  final String lowerImagePath;
  final DateTime dateAdded;

  const FavoritesCard({
    Key? key,
    required this.upperImagePath,
    required this.lowerImagePath,
    required this.dateAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // คำนวณขนาดรูปภาพตามขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    // กำหนดให้รูปภาพมีขนาดประมาณ 40% ของความกว้างหน้าจอ
    // หักลบ padding และระยะห่างระหว่างรูป
    final imageSize = (screenWidth - 32 - 48) * 0.4;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8DDF0),
        borderRadius: BorderRadius.circular(16.0),
      ),
      // ใช้ FittedBox เพื่อให้ content ปรับขนาดอัตโนมัติ
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Images row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Upper body image
                SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      upperImagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Plus sign
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    '+',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
                // Lower body image
                SizedBox(
                  width: imageSize,
                  height: imageSize,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      lowerImagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date added
            Text(
              'Date added : ${DateFormat('dd/MM/yyyy').format(dateAdded)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
