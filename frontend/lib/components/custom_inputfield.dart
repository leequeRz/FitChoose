import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final TextEditingController? textController;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final void Function(String)? onChanged;

  const CustomInputField({
    Key? key,
    required this.label,
    this.textController,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // ซ่อนคีย์บอร์ดเมื่อแตะพื้นที่ว่าง
        FocusScope.of(context).unfocus();
      },
      // behavior: HitTestBehavior.translucent ทำให้สามารถรับ gesture ได้แม้จะเป็นพื้นที่โปร่งใส
      behavior: HitTestBehavior.translucent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.purple[900],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: textController,
            validator: validator,
            obscureText: obscureText,
            keyboardType: keyboardType,
            onChanged: onChanged,
            // เพิ่ม onEditingComplete เพื่อซ่อนคีย์บอร์ดเมื่อกด done
            onEditingComplete: () {
              FocusScope.of(context).unfocus();
            },
            // เพิ่ม onTapOutside เพื่อซ่อนคีย์บอร์ดเมื่อแตะด้านนอก
            onTapOutside: (_) {
              FocusScope.of(context).unfocus();
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.purple[200]!,
                  width: 1,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
