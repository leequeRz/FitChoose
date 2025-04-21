// profile_name_widget.dart
import 'package:flutter/material.dart';

class ProfileNameSection extends StatelessWidget {
  final String name;
  final VoidCallback onEditPressed;

  const ProfileNameSection({
    super.key,
    required this.name,
    required this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          // Name Section
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3B1E54)),
            ),
          ),
          // Edit Button
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey),
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }
}

// edit_name_dialog.dart
class EditNameDialog extends StatefulWidget {
  final String initialName;

  const EditNameDialog({
    super.key,
    required this.initialName,
  });

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Name'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          labelText: 'Name',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
