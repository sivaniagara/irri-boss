import 'package:flutter/material.dart';

class ControllerSectionHeader extends StatelessWidget {
  final String title;

  const ControllerSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF145DA0),
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),
      ),
    );
  }
}
