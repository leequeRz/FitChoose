import 'package:flutter/material.dart';

class ContainerHome extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? subtitleColor;
  final Color? iconColor;
  final double iconSize;

  const ContainerHome({
    Key? key,
    this.title = 'Favorite',
    this.subtitle = 'Your Favorite Matching.',
    this.icon = Icons.favorite,
    this.backgroundColor,
    this.titleColor,
    this.subtitleColor,
    this.iconColor,
    this.iconSize = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // ครอบด้วย SafeArea ป้องกันไม่ให้ชนขอบจอ
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFF5F0FF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$title ',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: titleColor ?? Colors.purple[900],
                    ),
                  ),
                ),
                Icon(
                  icon,
                  color: iconColor ?? Color(0xFF9B7EBD),
                  size: iconSize,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 18,
                color: subtitleColor ?? Color(0xFF9B7EBD),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
