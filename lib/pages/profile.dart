import 'package:fitchoose/components/pictureselect.dart';
import 'package:fitchoose/components/profilename_section.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = 'Nan';

  Future<void> _showEditDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => EditNameDialog(initialName: userName),
    );

    if (result != null) {
      setState(() {
        userName = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F0FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B1E54), // Deep purple
                ),
              ),
              const Text(
                'Your Profile',
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF9B7EBD), // Deep purple
                ),
              ),
              const SizedBox(height: 24),
              ProfileNameSection(
                name: userName,
                onEditPressed: _showEditDialog,
              ),
              const SizedBox(height: 12),
              Center(
                child: PictureSelect(
                  imageUrl: 'assets/images/test.png',
                  width: 230,
                  height: 300,
                ),
              ),
              const SizedBox(height: 36),
              Text(
                'Gender',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B1E54)),
              ),
              SizedBox(height: 12),
              Container(
                width: 160,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFD4BEE4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: const Text(
                    'Female',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
