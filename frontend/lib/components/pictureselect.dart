import 'package:flutter/material.dart';

class PictureSelect extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const PictureSelect({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: imageUrl.startsWith('http') || imageUrl.startsWith('https')
            ? Image.network(
                imageUrl,
                fit: BoxFit.fill,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  print('Error loading image: $error');
                  return Image.asset(
                    'assets/images/test.png',
                    fit: BoxFit.cover,
                  );
                },
              )
            : Image.asset(
                imageUrl,
                fit: BoxFit.fill,
              ),
      ),
    );
  }
}
