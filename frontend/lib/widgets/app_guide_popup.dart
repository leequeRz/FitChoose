import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppGuidePopup extends StatefulWidget {
  final VoidCallback onClose;

  const AppGuidePopup({Key? key, required this.onClose}) : super(key: key);

  @override
  State<AppGuidePopup> createState() => _AppGuidePopupState();
}

class _AppGuidePopupState extends State<AppGuidePopup> {
  bool _dontShowAgain = false;
  int _currentPage = 0;
  final PageController _pageController = PageController();

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome to FitChoose!',
      'description':
          'An application that helps you manage your wardrobe, try on clothes virtually, and match outfits easily.',
      'icon': Icons.home,
    },
    {
      'title': 'Wardrobe',
      'description':
          'View clothes by category and upload new items by taking photos or selecting from gallery. Press the Picture Guide button for photography tips.',
      'icon': Icons.checkroom,
    },
    {
      'title': 'Virtual Try-On',
      'description':
          'Try on clothes virtually on your photo. Select clothing type, tap on the image to try, pull down to refresh, and press the History button to view history.',
      'icon': Icons.accessibility_new,
    },
    {
      'title': 'Matching',
      'description':
          'Match suitable outfits. Select tops or bottoms, press the Matching button to see results, History button to view history, and Liked button for favorites.',
      'icon': Icons.style,
    },
    {
      'title': 'Profile',
      'description':
          'View and edit your personal information, change profile picture, and customize application settings.',
      'icon': Icons.person,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95, // Set maximum width
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? const Color(0xFF9B7EBD)
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _dontShowAgain,
                  onChanged: (value) {
                    setState(() {
                      _dontShowAgain = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF9B7EBD),
                ),
                const Text('Don\'t show again'),
                const Spacer(),
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'Back',
                      style: TextStyle(color: Color(0xFF9B7EBD)),
                    ),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      if (_dontShowAgain) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('dontShowGuide', true);
                      }
                      widget.onClose();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF9B7EBD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Got it',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> pageData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          pageData['icon'],
          size: 80,
          color: const Color(0xFF9B7EBD),
        ),
        const SizedBox(height: 20),
        Text(
          pageData['title'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B1E54),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            pageData['description'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF9B7EBD),
            ),
          ),
        ),
      ],
    );
  }
}
