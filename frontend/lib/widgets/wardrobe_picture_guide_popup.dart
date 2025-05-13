import 'package:flutter/material.dart';

class WardrobePictureGuidePopup extends StatelessWidget {
  final VoidCallback onClose;

  const WardrobePictureGuidePopup({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF9D94FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'วิธีการอัปโหลดรูปเสื้อผ้าที่ดี',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          _buildSingleImageExample(),
          const SizedBox(height: 16),
          const Text(
            'คำแนะนำ: ถ่ายรูปเสื้อผ้าของคุณบนพื้นผิวเรียบ ให้เห็นรูปร่างชัดเจน ไม่มีเงาหรือแสงสะท้อน และถ่ายจากด้านหน้าเพื่อให้ระบบลองเสื้อผ้าเสมือนจริงทำงานได้อย่างมีประสิทธิภาพสูงสุด',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleImageExample() {
    return Column(
      children: [
        const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 30,
        ),
        const SizedBox(height: 8),
        Container(
          width: 150,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/good_wardrobe.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom,
                    size: 50,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ตัวอย่างรูปเสื้อผ้าที่ดี',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
