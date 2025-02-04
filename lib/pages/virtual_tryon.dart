import 'package:flutter/material.dart';

class VirtualTryOnPage extends StatefulWidget {
  const VirtualTryOnPage({super.key});

  @override
  State<VirtualTryOnPage> createState() => _VirtualTryOnPageState();
}

class _VirtualTryOnPageState extends State<VirtualTryOnPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Virtual Try-On'));
  }
}
