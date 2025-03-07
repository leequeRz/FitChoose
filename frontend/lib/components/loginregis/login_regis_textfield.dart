import 'package:flutter/material.dart';

class LoginRegisTextfield extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const LoginRegisTextfield(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF6F45EF)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF6F45EF)),
          ),
          fillColor: Color(0xFFF2F1FF),
          filled: true,
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF6F45EF)),
          prefixIcon: Icon(
            Icons.person,
            color: Color(0xFF6F45EF),
          ),
        ),
      ),
    );
  }
}
